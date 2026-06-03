// Edge Function: setup-mp-plans
// Función administrativa (llamar UNA vez): crea un Plan de Preaprobación en
// MercadoPago por cada fila activa de `membership_plans` y guarda el ID.
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

  // Solo accesible con la service role key
  const authHeader = req.headers.get("Authorization") ?? "";
  if (authHeader.replace("Bearer ", "") !== SERVICE_KEY) {
    return json({ error: "No autorizado" }, 401);
  }

  try {
    const supabase = createClient(SUPABASE_URL, SERVICE_KEY);

    // Obtener todos los planes activos
    const { data: plans, error } = await supabase
      .from("membership_plans")
      .select("id, name, price_mxn, mp_preapproval_plan_id")
      .eq("is_active", true)
      .order("sort_order");

    if (error || !plans) {
      return json({ error: "Error al obtener los planes" }, 500);
    }

    const results = [];

    for (const plan of plans) {
      // Omitir si ya tiene ID de MP
      if (plan.mp_preapproval_plan_id) {
        results.push({
          plan_id:   plan.id,
          name:      plan.name,
          status:    "already_exists",
          mp_plan_id: plan.mp_preapproval_plan_id,
        });
        continue;
      }

      // Crear Plan de Preaprobación en MP
      const mpRes = await fetch("https://api.mercadopago.com/preapproval_plan", {
        method:  "POST",
        headers: {
          "Authorization": `Bearer ${MP_TOKEN}`,
          "Content-Type":  "application/json",
        },
        body: JSON.stringify({
          reason:         `Promofy ${plan.name}`,
          auto_recurring: {
            frequency:          1,
            frequency_type:     "months",
            transaction_amount: Number(plan.price_mxn),
            currency_id:        "MXN",
          },
          back_url: "https://promofy.fun/subscription/callback",
          status:   "active",
        }),
      });

      const mpData = await mpRes.json();

      if (!mpRes.ok) {
        console.error(`Error MP para plan ${plan.name}:`, JSON.stringify(mpData));
        results.push({
          plan_id: plan.id,
          name:    plan.name,
          status:  "mp_error",
          error:   mpData,
        });
        continue;
      }

      // Guardar el ID del plan de MP en Supabase
      const { error: updateError } = await supabase
        .from("membership_plans")
        .update({ mp_preapproval_plan_id: mpData.id })
        .eq("id", plan.id);

      if (updateError) {
        console.error(`Error actualizando plan ${plan.id}:`, updateError);
        results.push({
          plan_id:    plan.id,
          name:       plan.name,
          status:     "db_error",
          mp_plan_id: mpData.id,
          db_error:   updateError.message,
        });
      } else {
        console.log(`Plan ${plan.name} → MP ID ${mpData.id}`);
        results.push({
          plan_id:    plan.id,
          name:       plan.name,
          status:     "created",
          mp_plan_id: mpData.id,
        });
      }
    }

    return json({ results });

  } catch (err) {
    console.error("setup-mp-plans error:", err);
    return json({ error: String(err) }, 500);
  }
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}
