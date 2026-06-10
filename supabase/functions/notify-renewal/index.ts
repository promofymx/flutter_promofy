// Edge Function: notify-renewal
// Envía aviso push a usuarios cuya suscripción vence en ~5 días.
// Se invoca diariamente desde pg_cron (ver SQL abajo).
//
// Secrets requeridos:
//   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, FIREBASE_SERVICE_ACCOUNT

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY  = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const FROM_EMAIL     = "Promofy <hola@promofy.fun>";

// ── Email (Resend) ────────────────────────────────────────────────────────────
async function sendEmail(to: string, subject: string, html: string): Promise<boolean> {
  if (!RESEND_API_KEY) return false;
  try {
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${RESEND_API_KEY}`,
        "Content-Type":  "application/json",
      },
      body: JSON.stringify({ from: FROM_EMAIL, to, subject, html }),
    });
    if (!res.ok) { console.error("Resend error:", res.status, await res.text()); return false; }
    return true;
  } catch (e) {
    console.error("sendEmail error:", e);
    return false;
  }
}

function renewalEmailHtml(name: string): string {
  const hi = name ? `Hola ${name},` : "Hola,";
  return `
  <div style="font-family:Arial,sans-serif;max-width:480px;margin:0 auto;color:#1a1a1a">
    <h2 style="color:#F26522">Tu membresía Promofy vence pronto 🔔</h2>
    <p>${hi}</p>
    <p>Tu membresía está por terminar en <strong>aproximadamente 5 días</strong>.
       Para no perder tus beneficios, asegúrate de tener saldo disponible en tu método de pago
       para que se renueve automáticamente.</p>
    <p>Si quieres revisar o cambiar tu plan, entra a tu panel en
       <a href="https://promofy.fun/planes" style="color:#F26522">promofy.fun</a>.</p>
    <p style="color:#888;font-size:12px;margin-top:24px">Promofy · Promociones que sí funcionan</p>
  </div>`;
}

// ── FCM helpers (reutilizados del patrón broadcast) ───────────────────────────

function base64urlEncode(data: string | ArrayBuffer): string {
  const bytes =
    typeof data === "string"
      ? new TextEncoder().encode(data)
      : new Uint8Array(data);
  let str = "";
  bytes.forEach((b) => (str += String.fromCharCode(b)));
  return btoa(str).replace(/\+/g, "-").replace(/\//g, "_").replace(/=/g, "");
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\s/g, "");
  const binary = atob(b64);
  const bytes  = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes.buffer;
}

async function getAccessToken(sa: {
  client_email: string;
  private_key:  string;
}): Promise<string> {
  const now     = Math.floor(Date.now() / 1000);
  const header  = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss:   sa.client_email,
    sub:   sa.client_email,
    aud:   "https://oauth2.googleapis.com/token",
    iat:   now,
    exp:   now + 3600,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  };
  const h64   = base64urlEncode(JSON.stringify(header));
  const p64   = base64urlEncode(JSON.stringify(payload));
  const input = `${h64}.${p64}`;
  const key   = await crypto.subtle.importKey(
    "pkcs8", pemToArrayBuffer(sa.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, false, ["sign"],
  );
  const sig = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(input),
  );
  const jwt = `${input}.${base64urlEncode(sig)}`;
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion:  jwt,
    }),
  });
  const { access_token } = await res.json() as { access_token: string };
  return access_token;
}

async function sendFcm(
  token:       string,
  title:       string,
  body:        string,
  accessToken: string,
  projectId:   string,
): Promise<boolean> {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data:    { type: "renewal_reminder" },
          android: { notification: { sound: "default", click_action: "FLUTTER_NOTIFICATION_CLICK" } },
          apns:    { payload: { aps: { sound: "default" } } },
        },
      }),
    },
  );
  return res.ok;
}

// ── Handler principal ─────────────────────────────────────────────────────────

serve(async (req) => {
  // Seguridad: solo llamadas internas (pg_net) o con service-role header
  const authHeader = (req.headers.get("Authorization") ?? "").replace("Bearer ", "");
  if (authHeader !== SERVICE_KEY) {
    return new Response(JSON.stringify({ error: "No autorizado" }), { status: 401 });
  }

  try {
    const admin = createClient(SUPABASE_URL, SERVICE_KEY);

    // ── 1. Suscripciones que vencen en 5 días (ventana de ±12h) ──────────────
    const now        = new Date();
    const windowFrom = new Date(now.getTime() + 4.5 * 24 * 60 * 60 * 1000); // +4.5d
    const windowTo   = new Date(now.getTime() + 5.5 * 24 * 60 * 60 * 1000); // +5.5d

    const { data: subs, error: subsErr } = await admin
      .from("user_subscriptions")
      .select("user_id, current_period_end, profiles(display_name)")
      .eq("status", "authorized")
      .gte("current_period_end", windowFrom.toISOString())
      .lte("current_period_end", windowTo.toISOString());

    if (subsErr) throw subsErr;
    if (!subs || subs.length === 0) {
      console.log("notify-renewal: sin vencimientos en 5 días");
      return new Response(JSON.stringify({ notified: 0 }), { status: 200 });
    }

    const userIds = subs.map((s: { user_id: string }) => s.user_id);
    const nameById: Record<string, string> = {};
    for (const s of subs as { user_id: string; profiles?: { display_name?: string } | { display_name?: string }[] }[]) {
      const p = Array.isArray(s.profiles) ? s.profiles[0] : s.profiles;
      nameById[s.user_id] = p?.display_name ?? "";
    }
    console.log(`notify-renewal: ${userIds.length} suscripciones próximas a vencer`);

    const title = "Tu membresía vence en 5 días 🔔";
    const body  = "Asegúrate de tener tu saldo disponible para que se renueve automáticamente.";

    // ── 1b. Campanita in-app + correo (Resend) ────────────────────────────────
    try {
      await admin.rpc("enqueue_user_notifications", {
        p_user_ids: userIds,
        p_title:    title,
        p_body:     body,
        p_type:     "renewal_reminder",
        p_data:     {},
      });
    } catch (e) { console.error("enqueue_user_notifications error:", e); }

    // Correos: resolver email de cada usuario vía auth admin y enviar con Resend.
    let emailed = 0;
    for (const uid of userIds) {
      try {
        const { data: u } = await admin.auth.admin.getUserById(uid);
        const email = u?.user?.email;
        if (email) {
          const ok = await sendEmail(email, "Tu membresía Promofy vence pronto", renewalEmailHtml(nameById[uid]));
          if (ok) emailed++;
        }
      } catch (e) { console.error("email lookup/send error:", e); }
    }
    console.log(`notify-renewal: emails enviados=${emailed}`);

    // ── 2. Tokens de esos usuarios ────────────────────────────────────────────
    const { data: tokens, error: tokErr } = await admin
      .from("device_tokens")
      .select("user_id, token")
      .in("user_id", userIds);

    if (tokErr) throw tokErr;
    if (!tokens || tokens.length === 0) {
      console.log("notify-renewal: sin tokens registrados para esos usuarios");
      return new Response(JSON.stringify({ notified: 0 }), { status: 200 });
    }

    // ── 3. Enviar FCM ─────────────────────────────────────────────────────────
    const sa = JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT")!) as {
      project_id:   string;
      client_email: string;
      private_key:  string;
    };
    const accessToken = await getAccessToken(sa);
    const projectId   = sa.project_id;

    let sent = 0, failed = 0;
    for (const { token } of tokens as { user_id: string; token: string }[]) {
      const ok = await sendFcm(token, title, body, accessToken, projectId);
      ok ? sent++ : failed++;
    }

    console.log(`notify-renewal: sent=${sent} failed=${failed}`);
    return new Response(JSON.stringify({ notified: sent, failed }), { status: 200 });

  } catch (err) {
    console.error("notify-renewal error:", err);
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 });
  }
});
