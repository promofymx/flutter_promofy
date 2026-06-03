// Edge Function: sync-mp-plan-prices
// Sincroniza los precios de membership_plans con los Planes de Preaprobación
// de MercadoPago. Llamar cada vez que se cambie un precio en la DB.
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

    // Obtener todos los planes activos con su ID de MP
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
      if (!plan.mp_preapproval_plan_id) {
        results.push({
          plan_id: plan.id,
          name:    plan.name,
          status:  "skipped",
          reason:  "No tiene mp_preapproval_plan_id — ejecuta setup-mp-plans primero",
        });
        continue;
      }

      // Consultar el precio actual en MP
      const getRes = await fetch(
        `https://api.mercadopago.com/preapproval_plan/${plan.mp_preapproval_plan_id}`,
        { headers: { "Authorization": `Bearer ${MP_TOKEN}` } },
      );

      if (!getRes.ok) {
        results.push({
          plan_id: plan.id,
          name:    plan.name,
          status:  "mp_get_error",
          error:   await getRes.text(),
        });
        continue;
      }

      const mpPlan = await getRes.json();
      const currentPrice = mpPlan?.auto_recurring?.transaction_amount;

      // Si el precio ya es el mismo, no hacer nada
      if (Number(currentPrice) === Number(plan.price_mxn)) {
        results.push({
          plan_id:       plan.id,
          name:          plan.name,
          status:        "already_in_sync",
          price_mxn:     plan.price_mxn,
        });
        continue;
      }

      // Actualizar el precio en MP
      const patchRes = await fetch(
        `https://api.mercadopago.com/preapproval_plan/${plan.mp_preapproval_plan_id}`,
        {
          method:  "PATCH",
          headers: {
            "Authorization": `Bearer ${MP_TOKEN}`,
            "Content-Type":  "application/json",
          },
          body: JSON.stringify({
            auto_recurring: {
              transaction_amount: Number(plan.price_mxn),
              currency_id:        "MXN",
            },
          }),
        },
      );

      const patchData = await patchRes.json();

      if (!patchRes.ok) {
        console.error(`Error actualizando plan ${plan.name}:`, JSON.stringify(patchData));
        results.push({
          plan_id:    plan.id,
          name:       plan.name,
          status:     "mp_patch_error",
          error:      patchData,
          price_old:  currentPrice,
          price_new:  plan.price_mxn,
        });
      } else {
        console.log(`Plan ${plan.name}: $${currentPrice} → $${plan.price_mxn} MXN`);
        results.push({
          plan_id:    plan.id,
          name:       plan.name,
          status:     "updated",
          price_old:  currentPrice,
          price_new:  plan.price_mxn,
        });
      }
    }

    const updated = results.filter((r) => r.status === "updated").length;
    const synced  = results.filter((r) => r.status === "already_in_sync").length;

    return json({ updated, already_in_sync: synced, results });

  } catch (err) {
    console.error("sync-mp-plan-prices error:", err);
    return json({ error: String(err) }, 500);
  }
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}
