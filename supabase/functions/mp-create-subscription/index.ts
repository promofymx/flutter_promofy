// Edge Function: mp-create-subscription
// Inicia una suscripción recurrente en MercadoPago (Preapproval API inline).
// Devuelve el init_point para que el usuario autorice el cobro mensual en WebView.
// Requiere env vars: MERCADOPAGO_ACCESS_TOKEN, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const MP_TOKEN     = Deno.env.get("MERCADOPAGO_ACCESS_TOKEN")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY  = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

// MercadoPago no permite cobros recurrentes menores a este monto (MXN).
const MP_MIN_MXN = 10;

const cors = {
  "Access-Control-Allow-Origin":  "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });

  try {
    // ── 1. Autenticación ───────────────────────────────────────────────────
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return json({ error: "No autorizado" }, 401);

    const admin = createClient(SUPABASE_URL, SERVICE_KEY);
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await admin.auth.getUser(token);
    if (authError || !user) return json({ error: "Token inválido" }, 401);

    // ── 2. Validar body ────────────────────────────────────────────────────
    const { plan_id } = await req.json() as { plan_id: number };
    if (!plan_id) return json({ error: "plan_id requerido" }, 400);

    // ── 3. Obtener plan ────────────────────────────────────────────────────
    const { data: plan, error: planErr } = await admin
      .from("membership_plans")
      .select("id, name, price_mxn")
      .eq("id", plan_id)
      .eq("is_active", true)
      .single();

    if (planErr || !plan) return json({ error: "Plan no encontrado" }, 404);

    // ── 3b. Precio especial asignado al CORREO del cliente (automático) ─────
    //     El superadmin asigna un descuento a un correo. Si el usuario que se
    //     suscribe tiene uno asignado y vigente, se aplica solo. Sin códigos
    //     ni campos visibles para el público.
    let amount          = Number(plan.price_mxn);
    let freeTrialMonths = 0;
    let discountCodeId: string | null = null;

    const email = (user.email ?? "").trim().toLowerCase();
    if (email) {
      const { data: dc } = await admin
        .from("discount_codes")
        .select("*")
        .eq("assigned_email", email)
        .eq("is_active", true)
        .or(`applies_to_plan_id.is.null,applies_to_plan_id.eq.${plan_id}`)
        .order("created_at", { ascending: false })
        .limit(1)
        .maybeSingle();

      if (dc) {
        const notExpired = !dc.expires_at || new Date(dc.expires_at) > new Date();
        const underMax   = dc.max_uses == null || dc.used_count < dc.max_uses;

        // ¿ya lo canjeó este usuario?
        const { data: red } = await admin
          .from("discount_code_redemptions")
          .select("id")
          .eq("code_id", dc.id)
          .eq("user_id", user.id)
          .maybeSingle();

        if (notExpired && underMax && !red) {
          discountCodeId = dc.id;
          if (dc.discount_type === "percent") {
            amount = Math.round(amount * (1 - Math.min(Number(dc.discount_value), 100) / 100) * 100) / 100;
          } else if (dc.discount_type === "fixed") {
            amount = Math.max(amount - Number(dc.discount_value), 0);
          } else if (dc.discount_type === "free_months") {
            freeTrialMonths = Math.floor(Number(dc.discount_value));
          }

          // Seguridad: MP no permite cobro recurrente en $0 (salvo free_trial).
          // MercadoPago no acepta cobros recurrentes menores a $10 MXN.
          // Si el descuento deja el precio por debajo, se cobra el mínimo ($10).
          if (freeTrialMonths === 0 && amount < MP_MIN_MXN) {
            amount = MP_MIN_MXN;
          }
        }
      }
    }

    // ── 4. Verificar si ya hay una suscripción activa o pendiente ──────────
    const { data: existing } = await admin
      .from("user_subscriptions")
      .select("id, status, plan_id, mp_preapproval_id")
      .eq("user_id", user.id)
      .in("status", ["authorized", "pending"])
      .maybeSingle();

    if (existing) {
      // Ya activa → no se puede volver a suscribir.
      if (existing.status === "authorized") {
        return json({
          error:  "Ya tienes una suscripción activa.",
          status: "authorized",
        }, 409);
      }

      // status === "pending": auto-reparar consultando el estado real en MP.
      if (existing.mp_preapproval_id) {
        try {
          const checkRes = await fetch(
            `https://api.mercadopago.com/preapproval/${existing.mp_preapproval_id}`,
            { headers: { "Authorization": `Bearer ${MP_TOKEN}` } },
          );
          if (checkRes.ok) {
            const pre = await checkRes.json();

            // a) Ya fue autorizada en MP (webhook perdido) → sincronizar y avisar.
            if (pre.status === "authorized") {
              await admin
                .from("user_subscriptions")
                .update({ status: "authorized" })
                .eq("id", existing.id);
              return json({
                error:  "Ya tienes una suscripción activa.",
                status: "authorized",
              }, 409);
            }

            // b) Sigue pendiente, mismo plan Y mismo monto → reanudar el pago.
            //    Si el monto difiere (p. ej. una preaprobación vieja con precio
            //    de prueba), NO se reanuda: se descarta y se crea una nueva al
            //    precio actual del plan.
            const preAmount = Number(pre?.auto_recurring?.transaction_amount);
            if (pre.status === "pending" &&
                pre.init_point &&
                existing.plan_id === plan_id &&
                preAmount === amount) {
              return json({
                init_point:     pre.init_point as string,
                preapproval_id: String(existing.mp_preapproval_id),
              });
            }
          }
        } catch (e) {
          console.error("MP preapproval check error:", e);
        }
      }

      // c) Pendiente cancelado/vencido, de otro plan, o sin poder consultarlo:
      //    borrar la fila atascada y continuar para crear una nueva.
      await admin.from("user_subscriptions").delete().eq("id", existing.id);
    }

    // ── 5. Crear Preaprobación en MercadoPago (inline auto_recurring) ──────
    const mpBody = {
      reason:             `Promofy ${plan.name}`,
      payer_email:        user.email,
      back_url:           "https://promofy.fun/subscription/callback",
      auto_recurring: {
        frequency:          1,
        frequency_type:     "months",
        transaction_amount: amount,
        currency_id:        "MXN",
        ...(freeTrialMonths > 0
          ? { free_trial: { frequency: freeTrialMonths, frequency_type: "months" } }
          : {}),
      },
      external_reference: `sub|${user.id}|${plan_id}`,
      status:             "pending",
    };

    console.log("MP request body:", JSON.stringify(mpBody));

    const mpRes = await fetch("https://api.mercadopago.com/preapproval", {
      method:  "POST",
      headers: {
        "Authorization": `Bearer ${MP_TOKEN}`,
        "Content-Type":  "application/json",
      },
      body: JSON.stringify(mpBody),
    });

    const mpData = await mpRes.json();

    if (!mpRes.ok) {
      console.error("MP preapproval error:", JSON.stringify(mpData));
      const detail = mpData?.message
        ?? mpData?.cause?.[0]?.description
        ?? mpData?.error
        ?? "error desconocido";
      return json({ error: `MercadoPago: ${detail}` }, 502);
    }

    // ── 6. Guardar suscripción pendiente en DB ─────────────────────────────
    const { error: insertErr } = await admin
      .from("user_subscriptions")
      .insert({
        user_id:           user.id,
        plan_id:           plan_id,
        mp_preapproval_id: String(mpData.id),
        status:            "pending",
        ...(discountCodeId ? { discount_code_id: discountCodeId } : {}),
      });

    if (insertErr) {
      console.error("DB insert error:", insertErr.message);
    }

    return json({
      init_point:     mpData.init_point   as string,
      preapproval_id: String(mpData.id),
    });

  } catch (err) {
    console.error("mp-create-subscription error:", err);
    return json({ error: "Error interno del servidor" }, 500);
  }
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}
