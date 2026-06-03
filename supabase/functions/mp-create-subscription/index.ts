// Edge Function: mp-create-subscription
// Inicia una suscripción recurrente en MercadoPago (Preapproval API inline).
// Devuelve el init_point para que el usuario autorice el cobro mensual en WebView.
// Requiere env vars: MERCADOPAGO_ACCESS_TOKEN, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const MP_TOKEN     = Deno.env.get("MERCADOPAGO_ACCESS_TOKEN")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY  = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

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

    // ── 4. Verificar si ya hay una suscripción activa o pendiente ──────────
    const { data: existing } = await admin
      .from("user_subscriptions")
      .select("id, status, plan_id")
      .eq("user_id", user.id)
      .in("status", ["authorized", "pending"])
      .maybeSingle();

    if (existing) {
      return json({
        error: existing.status === "authorized"
          ? "Ya tienes una suscripción activa."
          : "Ya tienes una suscripción en proceso de pago.",
        status: existing.status,
      }, 409);
    }

    // ── 5. Crear Preaprobación en MercadoPago (inline auto_recurring) ──────
    const mpBody = {
      reason:             `Promofy ${plan.name}`,
      payer_email:        user.email,
      back_url:           "https://promofy.fun/subscription/callback",
      auto_recurring: {
        frequency:          1,
        frequency_type:     "months",
        transaction_amount: Number(plan.price_mxn),
        currency_id:        "MXN",
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
      return json({ error: "Error al crear suscripción en MercadoPago" }, 502);
    }

    // ── 6. Guardar suscripción pendiente en DB ─────────────────────────────
    const { error: insertErr } = await admin
      .from("user_subscriptions")
      .insert({
        user_id:           user.id,
        plan_id:           plan_id,
        mp_preapproval_id: String(mpData.id),
        status:            "pending",
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
