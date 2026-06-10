// Edge Function: notify-signup
// Disparada por Database Webhooks de Supabase. Envía:
//   • Correo de BIENVENIDA al usuario nuevo (profiles INSERT)
//   • ALERTA al admin (nuevo usuario/dueño, pago/renovación, recarga de ads)
// Usa Resend para el envío (desde @promofy.fun).
//
// Secrets requeridos (Supabase → Edge Functions → Secrets):
//   RESEND_API_KEY   — API key de https://resend.com
//   WEBHOOK_SECRET   — secreto compartido con los Database Webhooks
//   (SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY ya están disponibles)

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY")!;
const WEBHOOK_SECRET  = Deno.env.get("WEBHOOK_SECRET") ?? "";
const SUPABASE_URL    = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY     = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const FROM_EMAIL   = "Promofy <hola@promofy.fun>";
const ADMIN_EMAIL  = "promofymx@gmail.com";
const APP_NAME     = "Promofy";
const BRAND        = "#F26522";

const admin = createClient(SUPABASE_URL, SERVICE_KEY);

// ── Helper: enviar correo vía Resend ────────────────────────────────────────
async function sendEmail(to: string, subject: string, html: string): Promise<boolean> {
  try {
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${RESEND_API_KEY}`,
        "Content-Type":  "application/json",
      },
      body: JSON.stringify({ from: FROM_EMAIL, to, subject, html }),
    });
    if (!res.ok) {
      console.error("Resend error:", res.status, await res.text());
      return false;
    }
    return true;
  } catch (e) {
    console.error("sendEmail error:", e);
    return false;
  }
}

// ── Plantillas ──────────────────────────────────────────────────────────────
function welcomeHtml(name: string, isOwner: boolean): string {
  const hi = name ? `¡Hola, ${name}!` : "¡Hola!";
  const body = isOwner
    ? `Tu cuenta de <b>negocio</b> en ${APP_NAME} ya está lista. Desde la app puedes crear promociones,
       lanzar tu programa de lealtad y atraer más clientes con publicidad segmentada.`
    : `Gracias por unirte a ${APP_NAME}. Descubre las mejores promociones cerca de ti,
       junta sellos de lealtad y aprovecha beneficios exclusivos.`;
  return `
  <div style="font-family:Arial,Helvetica,sans-serif;max-width:520px;margin:0 auto;color:#222">
    <div style="background:${BRAND};border-radius:16px 16px 0 0;padding:28px;text-align:center">
      <span style="font-size:40px">🎟️</span>
      <h1 style="color:#fff;margin:8px 0 0;font-size:22px">${APP_NAME}</h1>
    </div>
    <div style="border:1px solid #eee;border-top:none;border-radius:0 0 16px 16px;padding:28px">
      <h2 style="margin:0 0 12px;font-size:20px">${hi}</h2>
      <p style="font-size:15px;line-height:1.6;color:#444">${body}</p>
      <p style="font-size:13px;color:#888;margin-top:24px">
        ¿Dudas? Responde a este correo o escríbenos a
        <a href="mailto:${ADMIN_EMAIL}" style="color:${BRAND}">${ADMIN_EMAIL}</a>.
      </p>
      <p style="font-size:12px;color:#aaa;margin-top:20px">— El equipo de ${APP_NAME}</p>
    </div>
  </div>`;
}

function adminHtml(title: string, detail: string): string {
  const when = new Date().toLocaleString("es-MX", { timeZone: "America/Mexico_City" });
  return `
  <div style="font-family:Arial,Helvetica,sans-serif;max-width:520px;margin:0 auto;color:#222">
    <h2 style="color:${BRAND};margin:0 0 8px">${title}</h2>
    <p style="font-size:15px;line-height:1.5;color:#333">${detail}</p>
    <p style="font-size:12px;color:#999;margin-top:16px">🕐 ${when} · Alerta automática de ${APP_NAME}</p>
  </div>`;
}

// ── Enriquecer datos (nombre de plan, establecimiento, etc.) ────────────────
async function getOne(table: string, col: string, val: unknown, select: string) {
  if (val === null || val === undefined) return null;
  const { data } = await admin.from(table).select(select).eq(col, val as string).limit(1).maybeSingle();
  return data as Record<string, unknown> | null;
}

serve(async (req) => {
  try {
    // ── Seguridad: secreto compartido ──
    const secret = req.headers.get("x-webhook-secret") ?? new URL(req.url).searchParams.get("secret");
    if (WEBHOOK_SECRET && secret !== WEBHOOK_SECRET) {
      return new Response("forbidden", { status: 401 });
    }

    const body = await req.json().catch(() => ({}));

    // ── Modo PRUEBA: enviar un correo de muestra y devolver el resultado real
    //    de Resend. Uso: { test:true, email:"...", name:"...", owner:true|false }
    if (body?.test === true && body?.email) {
      const r = await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${RESEND_API_KEY}`,
          "Content-Type":  "application/json",
        },
        body: JSON.stringify({
          from:    FROM_EMAIL,
          to:      body.email,
          subject: body.owner
            ? "¡Bienvenido a Promofy para negocios! 🎉 (prueba)"
            : "¡Bienvenido a Promofy! 🎟️ (prueba)",
          html:    welcomeHtml(body.name ?? "", body.owner === true),
        }),
      });
      const txt = await r.text();
      return new Response(JSON.stringify({ resend_status: r.status, resend_body: txt }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    const table: string = body?.table ?? "";
    const type:  string = body?.type  ?? "";
    const rec:   Record<string, unknown> = body?.record ?? {};

    // ── 1) Nuevo perfil → bienvenida al usuario + alerta al admin ──
    if (table === "profiles" && type === "INSERT") {
      const isOwner = rec.role === "business_owner";
      const name    = (rec.full_name as string) || "";

      // Email del usuario (vive en auth.users)
      const { data: authData } = await admin.auth.admin.getUserById(rec.id as string);
      const email = authData?.user?.email ?? null;

      if (email) {
        await sendEmail(
          email,
          isOwner ? `¡Bienvenido a Promofy para negocios! 🎉` : `¡Bienvenido a Promofy! 🎟️`,
          welcomeHtml(name, isOwner),
        );
      }

      const quien = (name || "Sin nombre") + (email ? ` · ${email}` : "") +
                    (rec.phone ? ` · ${rec.phone}` : "");
      await sendEmail(
        ADMIN_EMAIL,
        isOwner ? "Promofy · 🏪 Nuevo DUEÑO de negocio" : "Promofy · 🆕 Nuevo usuario",
        adminHtml(isOwner ? "🏪 Nuevo DUEÑO de negocio" : "🆕 Nuevo usuario registrado", quien),
      );
      return new Response("ok", { status: 200 });
    }

    // ── 2) Suscripción → primer plan (dueño nuevo) o renovación ──
    if (table === "user_subscriptions" && type === "INSERT") {
      const plan = await getOne("membership_plans", "id", rec.plan_id, "name,price_mxn");
      const user = await getOne("profiles", "id", rec.user_id, "full_name");
      const planTxt = plan ? `${plan.name} ($${plan.price_mxn})` : `plan ${rec.plan_id}`;
      const nombre  = (user?.full_name as string) || String(rec.user_id);
      await sendEmail(
        ADMIN_EMAIL,
        "Promofy · 💳 Membresía",
        adminHtml("💳 Pago / membresía", `${nombre} — ${planTxt} · estado: ${rec.status}`),
      );
      return new Response("ok", { status: 200 });
    }

    // ── 3) Recarga de publicidad (solo compras) ──
    if (table === "ad_credit_txns" && type === "INSERT" && rec.type === "purchase") {
      const est = await getOne("establishments", "id", rec.establishment_id, "name");
      await sendEmail(
        ADMIN_EMAIL,
        "Promofy · 📣 Recarga de publicidad",
        adminHtml("📣 Recarga de publicidad",
          `${(est?.name as string) ?? "Establecimiento"} recargó $${rec.amount_mxn}`),
      );
      return new Response("ok", { status: 200 });
    }

    return new Response("ignored", { status: 200 });
  } catch (err) {
    console.error("notify-signup error:", err);
    // Responder 200 para que el webhook no reintente en bucle.
    return new Response("error-handled", { status: 200 });
  }
});
