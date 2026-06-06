// Edge Function: mp-cancel-addon
// Cancela la suscripción mensual de un add-on (preapproval) en MercadoPago
// y la marca como cancelada en la base. El usuario solo cancela las suyas.
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

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return json({ error: "No autorizado" }, 401);

    const admin = createClient(SUPABASE_URL, SERVICE_KEY);
    const token = authHeader.replace("Bearer ", "");
    const { data: { user }, error: authError } = await admin.auth.getUser(token);
    if (authError || !user) return json({ error: "Token inválido" }, 401);

    const { add_on_subscription_id } = await req.json() as { add_on_subscription_id: string };
    if (!add_on_subscription_id) return json({ error: "id requerido" }, 400);

    // Verificar que el add-on sea del usuario
    const { data: sub, error: subErr } = await admin
      .from("add_on_subscriptions")
      .select("id, user_id, mp_preapproval_id, status")
      .eq("id", add_on_subscription_id)
      .single();
    if (subErr || !sub) return json({ error: "Add-on no encontrado" }, 404);
    if (sub.user_id !== user.id) return json({ error: "No autorizado" }, 403);

    // Cancelar el preapproval en MercadoPago
    if (sub.mp_preapproval_id) {
      const mpRes = await fetch(
        `https://api.mercadopago.com/preapproval/${sub.mp_preapproval_id}`,
        {
          method:  "PUT",
          headers: { "Authorization": `Bearer ${MP_TOKEN}`, "Content-Type": "application/json" },
          body:    JSON.stringify({ status: "cancelled" }),
        },
      );
      if (!mpRes.ok) {
        const t = await mpRes.text();
        console.error("MP cancel preapproval error:", t);
        return json({ error: "No se pudo cancelar en MercadoPago" }, 502);
      }
    }

    // Marcar cancelado en la base
    const { error: updErr } = await admin
      .from("add_on_subscriptions")
      .update({ status: "cancelled", updated_at: new Date().toISOString() })
      .eq("id", add_on_subscription_id);
    if (updErr) console.error("DB update add_on_subscriptions:", updErr.message);

    return json({ success: true });
  } catch (err) {
    console.error("mp-cancel-addon error:", err);
    return json({ error: "Error interno del servidor" }, 500);
  }
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status, headers: { ...cors, "Content-Type": "application/json" },
  });
}
