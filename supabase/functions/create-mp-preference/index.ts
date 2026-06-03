// Edge Function: create-mp-preference
// Crea una preferencia de pago en MercadoPago Checkout Pro.
// Requiere env vars: MERCADOPAGO_ACCESS_TOKEN, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const MP_TOKEN        = Deno.env.get("MERCADOPAGO_ACCESS_TOKEN")!;
const SUPABASE_URL    = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY     = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin":  "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  try {
    const { establishment_id, amount_mxn } = await req.json();

    if (!establishment_id || !amount_mxn || amount_mxn < 50) {
      return new Response(
        JSON.stringify({ error: "establishment_id y amount_mxn (≥50) son requeridos" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // ── Verificar autenticación del usuario ──────────────────────────────────
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "No autorizado" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(SUPABASE_URL, SERVICE_KEY);
    const token    = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await supabase.auth.getUser(token);

    if (authError || !user) {
      return new Response(JSON.stringify({ error: "Token inválido" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // ── Verificar que el usuario es dueño del establecimiento ────────────────
    const { data: est } = await supabase
      .from("establishments")
      .select("id, name")
      .eq("id", establishment_id)
      .eq("owner_id", user.id)
      .maybeSingle();

    if (!est) {
      return new Response(
        JSON.stringify({ error: "Sin acceso a este establecimiento" }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    // ── Crear preferencia en MercadoPago ─────────────────────────────────────
    const webhookUrl = `${SUPABASE_URL}/functions/v1/mp-webhook`;

    const preference = {
      items: [
        {
          id:          "ad_credit",
          title:       `Crédito publicitario – ${est.name}`,
          quantity:    1,
          unit_price:  Number(amount_mxn),
          currency_id: "MXN",
        },
      ],
      // external_reference se usa en el webhook para acreditar al establecimiento correcto
      external_reference: `${establishment_id}|${amount_mxn}|${user.id}`,
      // notification_url garantiza que MP llame al webhook incluso sin config global en el Dashboard
      notification_url: webhookUrl,
      back_urls: {
        success: "https://promofy.fun/payment/success",
        failure: "https://promofy.fun/payment/failure",
        pending: "https://promofy.fun/payment/pending",
      },
      auto_return:          "approved",
      statement_descriptor: "PROMOFY ADS",
    };

    const mpRes = await fetch("https://api.mercadopago.com/checkout/preferences", {
      method:  "POST",
      headers: {
        "Authorization": `Bearer ${MP_TOKEN}`,
        "Content-Type":  "application/json",
      },
      body: JSON.stringify(preference),
    });

    if (!mpRes.ok) {
      const errBody = await mpRes.text();
      throw new Error(`MercadoPago error ${mpRes.status}: ${errBody}`);
    }

    const mpData = await mpRes.json();

    return new Response(
      JSON.stringify({
        preference_id:      mpData.id,
        init_point:         mpData.init_point,         // producción
        sandbox_init_point: mpData.sandbox_init_point, // sandbox (pruebas)
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (e) {
    console.error("create-mp-preference error:", e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
