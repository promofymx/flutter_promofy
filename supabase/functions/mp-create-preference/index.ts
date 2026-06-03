// Edge Function: mp-create-preference
// Crea una preferencia de pago (Checkout Pro) para add-ons de un solo pago.
// Add-on types disponibles: extra_establishment | extra_promotions
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

// ── Catálogo de add-ons ────────────────────────────────────────────────────────
// Precios en MXN. quantity = unidades que se acreditan al activar el add-on.
const ADD_ONS: Record<string, { title: string; unit_price: number; quantity: number }> = {
  extra_establishment: {
    title:      "1 establecimiento adicional",
    unit_price: 199,
    quantity:   1,
  },
  extra_promotions: {
    title:      "Pack 10 promociones extra",
    unit_price: 49,
    quantity:   10,
  },
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

    // ── 2. Validar add-on ──────────────────────────────────────────────────
    const { add_on_type } = await req.json() as { add_on_type: string };
    const addOn = ADD_ONS[add_on_type];
    if (!addOn) return json({ error: "Tipo de add-on inválido" }, 400);

    // ── 3. Crear registro pendiente en add_on_purchases ───────────────────
    const { data: purchase } = await admin
      .from("add_on_purchases")
      .insert({
        user_id:     user.id,
        add_on_type: add_on_type,
        quantity:    addOn.quantity,
        amount_paid: addOn.unit_price,
        status:      "pending",
      })
      .select("id")
      .single();

    // ── 5. Crear preferencia en MP ─────────────────────────────────────────
    const webhookUrl = `${SUPABASE_URL}/functions/v1/mp-webhook`;

    const mpRes = await fetch("https://api.mercadopago.com/checkout/preferences", {
      method:  "POST",
      headers: {
        "Authorization": `Bearer ${MP_TOKEN}`,
        "Content-Type":  "application/json",
      },
      body: JSON.stringify({
        items: [{
          id:          add_on_type,
          title:       addOn.title,
          quantity:    1,
          unit_price:  addOn.unit_price,
          currency_id: "MXN",
        }],
        payer: { email: user.email },
        back_urls: {
          success: "https://promofy.fun/payment/success",
          failure: "https://promofy.fun/payment/failure",
          pending: "https://promofy.fun/payment/pending",
        },
        auto_return:  "approved",
        metadata: {
          user_id:     user.id,
          add_on_type: add_on_type,
          purchase_id: purchase?.id ?? "",
        },
        notification_url: webhookUrl,
      }),
    });

    const mpData = await mpRes.json();

    if (!mpRes.ok) {
      console.error("MP preference error:", JSON.stringify(mpData));
      return json({ error: "Error al crear preferencia de pago" }, 502);
    }

    return json({
      checkout_url:  mpData.init_point  as string,
      preference_id: mpData.id          as string,
      add_on:        addOn,
    });

  } catch (err) {
    console.error("mp-create-preference error:", err);
    return json({ error: "Error interno del servidor" }, 500);
  }
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}
