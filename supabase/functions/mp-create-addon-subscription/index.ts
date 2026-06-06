// Edge Function: mp-create-addon-subscription
// Crea una SUSCRIPCIÓN mensual (preapproval) en MercadoPago para un add-on.
// Cada compra = 1 unidad ($49/mes promo, $199/mes local) hasta que se cancele.
// Requiere: MERCADOPAGO_ACCESS_TOKEN, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const MP_TOKEN     = Deno.env.get("MERCADOPAGO_ACCESS_TOKEN")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY  = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const cors = {
  "Access-Control-Allow-Origin":  "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const LABELS: Record<string, string> = {
  extra_promotion:     "Promoción adicional",
  extra_establishment: "Establecimiento adicional",
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return json({ error: "No autorizado" }, 401);

    const admin = createClient(SUPABASE_URL, SERVICE_KEY);
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await admin.auth.getUser(token);
    if (authError || !user) return json({ error: "Token inválido" }, 401);

    const { add_on_type } = await req.json() as { add_on_type: string };
    if (!LABELS[add_on_type]) return json({ error: "Tipo de add-on inválido" }, 400);

    // Precio desde la base (fuente de verdad)
    const { data: pricing, error: priceErr } = await admin
      .from("addon_pricing")
      .select("price_mxn")
      .eq("type", add_on_type)
      .single();
    if (priceErr || !pricing) return json({ error: "Precio no configurado" }, 404);
    const price = Number(pricing.price_mxn);

    // Crear preapproval mensual en MercadoPago
    const mpBody = {
      reason:      `Promofy · ${LABELS[add_on_type]}`,
      payer_email: user.email,
      back_url:    "https://promofy.fun/subscription/callback",
      auto_recurring: {
        frequency:          1,
        frequency_type:     "months",
        transaction_amount: price,
        currency_id:        "MXN",
      },
      external_reference: `addon|${user.id}|${add_on_type}`,
      status: "pending",
    };

    const mpRes = await fetch("https://api.mercadopago.com/preapproval", {
      method:  "POST",
      headers: { "Authorization": `Bearer ${MP_TOKEN}`, "Content-Type": "application/json" },
      body:    JSON.stringify(mpBody),
    });
    const mpData = await mpRes.json();
    if (!mpRes.ok) {
      console.error("MP addon preapproval error:", JSON.stringify(mpData));
      return json({ error: "Error al crear suscripción del add-on" }, 502);
    }

    // Guardar fila pendiente
    const { error: insErr } = await admin.from("add_on_subscriptions").insert({
      user_id:           user.id,
      add_on_type:       add_on_type,
      mp_preapproval_id: String(mpData.id),
      status:            "pending",
      price_mxn:         price,
    });
    if (insErr) console.error("DB insert add_on_subscriptions:", insErr.message);

    return json({
      init_point:     mpData.init_point as string,
      preapproval_id: String(mpData.id),
    });
  } catch (err) {
    console.error("mp-create-addon-subscription error:", err);
    return json({ error: "Error interno del servidor" }, 500);
  }
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status, headers: { ...cors, "Content-Type": "application/json" },
  });
}
