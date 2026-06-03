// Edge Function: mp-webhook
// Recibe notificaciones de MercadoPago y las procesa:
//   • payment                       → acredita saldo de anuncios al establecimiento
//   • subscription_preapproval      → actualiza estado de suscripción de plan
//   • subscription_authorized_payment → extiende vigencia de suscripción
// Requiere env vars: MERCADOPAGO_ACCESS_TOKEN, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const MP_TOKEN     = Deno.env.get("MERCADOPAGO_ACCESS_TOKEN")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY  = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

serve(async (req) => {
  // Siempre responder 200 para que MP no reintente indefinidamente.
  try {
    let type: string | null      = null;
    let resourceId: string | null = null;

    if (req.method === "POST") {
      const body = await req.json().catch(() => ({}));
      console.log("MP webhook body:", JSON.stringify(body));

      // Formato 1 — webhook global: {"type":"payment","data":{"id":"..."}}
      type       = body?.type ?? null;
      resourceId = body?.data?.id ?? null;

      // Formato 2 — notification_url: {"topic":"payment","resource":"https://.../123"}
      if (!type && body?.topic) {
        type = body.topic;
      }
      if (!resourceId && body?.resource) {
        const parts = String(body.resource).split("/");
        resourceId  = parts[parts.length - 1] || null;
      }

    } else if (req.method === "GET") {
      const url  = new URL(req.url);
      // Formato global GET
      type       = url.searchParams.get("type") ?? url.searchParams.get("topic");
      resourceId = url.searchParams.get("data.id") ?? url.searchParams.get("id");
      console.log("MP webhook GET params:", url.search);
    }

    console.log("Parsed → type:", type, "| resourceId:", resourceId);

    if (!type || !resourceId) {
      return new Response("OK", { status: 200 });
    }

    const supabase = createClient(SUPABASE_URL, SERVICE_KEY);

    // ══════════════════════════════════════════════════════════════════════
    // 1. Pago único (Checkout Pro) → crédito de anuncios
    // ══════════════════════════════════════════════════════════════════════
    if (type === "payment") {
      await handlePayment(supabase, resourceId);
      return new Response("OK", { status: 200 });
    }

    // ══════════════════════════════════════════════════════════════════════
    // 2. Cambio de estado en suscripción
    // ══════════════════════════════════════════════════════════════════════
    if (type === "subscription_preapproval") {
      await handleSubscriptionStatus(supabase, resourceId);
      return new Response("OK", { status: 200 });
    }

    // ══════════════════════════════════════════════════════════════════════
    // 3. Cobro mensual de suscripción autorizado
    // ══════════════════════════════════════════════════════════════════════
    if (type === "subscription_authorized_payment") {
      await handleSubscriptionPayment(supabase, resourceId);
      return new Response("OK", { status: 200 });
    }

    return new Response("OK", { status: 200 });
  } catch (e) {
    console.error("mp-webhook error:", e);
    return new Response("OK", { status: 200 });
  }
});

// ── Helpers ────────────────────────────────────────────────────────────────────

/** Acredita saldo de anuncios al establecimiento correspondiente. */
async function handlePayment(
  supabase: ReturnType<typeof createClient>,
  paymentId: string,
) {
  const payRes = await fetch(
    `https://api.mercadopago.com/v1/payments/${paymentId}`,
    { headers: { Authorization: `Bearer ${MP_TOKEN}` } },
  );
  if (!payRes.ok) {
    console.error(`MP payment fetch failed: ${payRes.status}`);
    return;
  }
  const payment = await payRes.json();
  if (payment.status !== "approved") return;

  // external_reference = "establishment_id|amount_mxn|user_id"
  const parts           = (payment.external_reference as string)?.split("|") ?? [];
  const establishmentId = parts[0];
  const amount          = parseFloat(parts[1]);

  if (!establishmentId || isNaN(amount) || amount <= 0) {
    console.error("external_reference inválido:", payment.external_reference);
    return;
  }

  // Idempotencia
  const { data: existing } = await supabase
    .from("ad_credit_txns")
    .select("id")
    .eq("reference_id", String(paymentId))
    .eq("type", "purchase")
    .maybeSingle();

  if (existing) {
    console.log("Pago ya procesado:", paymentId);
    return;
  }

  const { error } = await supabase.rpc("admin_add_credit", {
    p_establishment_id: establishmentId,
    p_amount_mxn:       amount,
    p_description:      `Recarga MercadoPago #${paymentId}`,
    p_added_by:         null,
    p_reference_id:     String(paymentId),
  });
  if (error) {
    console.error("admin_add_credit error:", error);
  } else {
    console.log(`Crédito acreditado: $${amount} MXN → ${establishmentId}`);
  }
}

/** Actualiza el estado de una suscripción cuando MP envía cambio de estado. */
async function handleSubscriptionStatus(
  supabase: ReturnType<typeof createClient>,
  preapprovalId: string,
) {
  const res = await fetch(
    `https://api.mercadopago.com/preapproval/${preapprovalId}`,
    { headers: { Authorization: `Bearer ${MP_TOKEN}` } },
  );
  if (!res.ok) {
    console.error(`MP preapproval fetch failed: ${res.status}`);
    return;
  }
  const sub = await res.json();

  // sub.status: pending | authorized | paused | cancelled
  const newStatus: string = sub.status ?? "pending";

  // Calcular fechas de periodo
  const now      = new Date();
  const nextMonth = new Date(now);
  nextMonth.setMonth(nextMonth.getMonth() + 1);

  const updates: Record<string, unknown> = { status: newStatus };

  if (newStatus === "authorized") {
    updates.current_period_start = now.toISOString();
    updates.current_period_end   = nextMonth.toISOString();
  } else if (newStatus === "cancelled" || newStatus === "paused") {
    // Mantener la fecha de fin actual — no borrarla
    // (paused y cancelled también limpian el plan en profiles — ver más abajo)
  }

  // Intentar actualizar por mp_preapproval_id primero
  const { data: existing, error: fetchErr } = await supabase
    .from("user_subscriptions")
    .select("id, user_id")
    .eq("mp_preapproval_id", preapprovalId)
    .maybeSingle();

  if (existing) {
    const { error } = await supabase
      .from("user_subscriptions")
      .update(updates)
      .eq("id", existing.id);

    if (error) {
      console.error("Error actualizando suscripción:", error);
    } else {
      console.log(`Suscripción ${preapprovalId} → ${newStatus}`);
    }

    // Si se autorizó, actualizar plan_id en profiles
    if (newStatus === "authorized") {
      const { data: subRow } = await supabase
        .from("user_subscriptions")
        .select("plan_id")
        .eq("id", existing.id)
        .single();

      if (subRow?.plan_id) {
        await supabase
          .from("profiles")
          .update({ plan_id: subRow.plan_id })
          .eq("id", existing.user_id);
      }
    }

    // Si se canceló o pausó, limpiar plan en profiles
    if (newStatus === "cancelled" || newStatus === "paused") {
      await supabase
        .from("profiles")
        .update({ plan_id: null })
        .eq("id", existing.user_id);
    }

  } else {
    // La suscripción no existe en DB aún (raro, pero puede pasar).
    // Intentar crear con external_reference = "sub|user_id|plan_id"
    const extRef = sub.external_reference as string | undefined;
    if (extRef) {
      const parts  = extRef.split("|");
      const userId = parts[1];
      const planId = parseInt(parts[2] ?? "0", 10);
      if (userId && planId) {
        await supabase.from("user_subscriptions").insert({
          user_id:           userId,
          plan_id:           planId,
          mp_preapproval_id: preapprovalId,
          status:            newStatus,
          ...(newStatus === "authorized" ? {
            current_period_start: now.toISOString(),
            current_period_end:   nextMonth.toISOString(),
          } : {}),
        });
        if (newStatus === "authorized") {
          await supabase
            .from("profiles")
            .update({ plan_id: planId })
            .eq("id", userId);
        }
      }
    }
    if (fetchErr) console.error("fetchErr:", fetchErr);
  }
}

/** Extiende la vigencia de la suscripción al recibir cada cobro mensual. */
async function handleSubscriptionPayment(
  supabase: ReturnType<typeof createClient>,
  authorizedPaymentId: string,
) {
  const res = await fetch(
    `https://api.mercadopago.com/authorized_payments/${authorizedPaymentId}`,
    { headers: { Authorization: `Bearer ${MP_TOKEN}` } },
  );
  if (!res.ok) {
    console.error(`MP authorized_payment fetch failed: ${res.status}`);
    return;
  }
  const ap = await res.json();
  if (ap.status !== "processed") return;

  const preapprovalId: string = ap.preapproval_id;
  if (!preapprovalId) return;

  // Idempotencia — el mismo pago no debe extender 2 veces
  const { data: sub } = await supabase
    .from("user_subscriptions")
    .select("id, current_period_end, last_authorized_payment_id")
    .eq("mp_preapproval_id", preapprovalId)
    .maybeSingle();

  if (!sub) {
    console.error("Suscripción no encontrada para preapproval:", preapprovalId);
    return;
  }

  if (sub.last_authorized_payment_id === String(authorizedPaymentId)) {
    console.log("Cobro mensual ya procesado:", authorizedPaymentId);
    return;
  }

  const base = sub.current_period_end
    ? new Date(sub.current_period_end)
    : new Date();
  const nextPeriodEnd = new Date(base);
  nextPeriodEnd.setMonth(nextPeriodEnd.getMonth() + 1);

  const { error } = await supabase
    .from("user_subscriptions")
    .update({
      status:                      "authorized",
      current_period_end:          nextPeriodEnd.toISOString(),
      current_period_start:        base.toISOString(),
      last_authorized_payment_id:  String(authorizedPaymentId),
    })
    .eq("id", sub.id);

  if (error) {
    console.error("Error extendiendo suscripción:", error);
  } else {
    console.log(`Suscripción ${preapprovalId} extendida hasta ${nextPeriodEnd.toISOString()}`);
  }
}
