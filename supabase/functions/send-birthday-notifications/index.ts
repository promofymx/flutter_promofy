// supabase/functions/send-birthday-notifications/index.ts
// Envía notificaciones push a todos los usuarios que cumplen años HOY.
//
// Llamada por pg_cron cada día a las 09:00 CDMX (15:00 UTC):
//   SELECT net.http_post(url, headers, body) AS request_id;
//
// Secrets requeridos:
//   FIREBASE_SERVICE_ACCOUNT → JSON de la cuenta de servicio de Firebase

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// ── Helpers JWT / FCM (idénticos a send-flash-notification) ──────────────────

function base64urlEncode(data: string | ArrayBuffer): string {
  const bytes =
    typeof data === 'string'
      ? new TextEncoder().encode(data)
      : new Uint8Array(data);
  let str = '';
  bytes.forEach((b) => (str += String.fromCharCode(b)));
  return btoa(str).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/g, '')
    .replace(/-----END PRIVATE KEY-----/g, '')
    .replace(/\s/g, '');
  const binary = atob(b64);
  const bytes   = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes.buffer;
}

async function getAccessToken(sa: {
  client_email: string;
  private_key:  string;
}): Promise<string> {
  const now     = Math.floor(Date.now() / 1000);
  const header  = { alg: 'RS256', typ: 'JWT' };
  const payload = {
    iss: sa.client_email, sub: sa.client_email,
    aud: 'https://oauth2.googleapis.com/token',
    iat: now, exp: now + 3600,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
  };

  const h = base64urlEncode(JSON.stringify(header));
  const p = base64urlEncode(JSON.stringify(payload));
  const input = `${h}.${p}`;

  const key = await crypto.subtle.importKey(
    'pkcs8', pemToArrayBuffer(sa.private_key),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false, ['sign'],
  );
  const sig = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', key, new TextEncoder().encode(input));
  const jwt = `${input}.${base64urlEncode(sig)}`;

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion:  jwt,
    }),
  });
  const { access_token } = await res.json() as { access_token: string };
  return access_token;
}

async function sendToToken(
  token: string, title: string, body: string,
  data: Record<string, string>, accessToken: string, projectId: string,
): Promise<boolean> {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type':  'application/json',
      },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data,
          android: {
            notification: { sound: 'default', click_action: 'FLUTTER_NOTIFICATION_CLICK' },
          },
          apns: { payload: { aps: { sound: 'default' } } },
        },
      }),
    },
  );
  return res.ok;
}

// ── Handler principal ─────────────────────────────────────────────────────────

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin':  '*',
        'Access-Control-Allow-Headers': 'authorization, content-type',
      },
    });
  }

  try {
    const admin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    // ── Usuarios con cumpleaños HOY ───────────────────────────────────────────
    // birth_date es de tipo DATE (YYYY-MM-DD).
    // Comparamos solo mes y día, independientemente del año.
    const { data: birthdayUsers, error: bErr } = await admin
      .from('profiles')
      .select('id')
      .not('birth_date', 'is', null)
      .filter('birth_date', 'ilike', `%-${
        // Formato: MM-DD del día actual en UTC
        String(new Date().getUTCMonth() + 1).padStart(2, '0') + '-' +
        String(new Date().getUTCDate()).padStart(2, '0')
      }`);

    if (bErr) throw bErr;
    if (!birthdayUsers || birthdayUsers.length === 0) {
      return new Response(
        JSON.stringify({ sent: 0, message: 'No hay cumpleañeros hoy' }),
        { status: 200, headers: { 'Content-Type': 'application/json' } },
      );
    }

    const userIds = birthdayUsers.map((u: { id: string }) => u.id);

    // ── Tokens de dispositivo de los cumpleañeros ─────────────────────────────
    const { data: tokenRows, error: tErr } = await admin
      .from('device_tokens')
      .select('token')
      .in('user_id', userIds);

    if (tErr) throw tErr;
    if (!tokenRows || tokenRows.length === 0) {
      return new Response(
        JSON.stringify({ sent: 0, message: 'Cumpleañeros sin token' }),
        { status: 200, headers: { 'Content-Type': 'application/json' } },
      );
    }

    // ── Plantilla de notificación ─────────────────────────────────────────────
    const { data: tplRow } = await admin
      .from('notification_templates')
      .select('title, body')
      .eq('promo_type', 'birthday')
      .eq('is_active', true)
      .order('sort_order')
      .limit(1)
      .maybeSingle();

    const notifTitle = (tplRow as { title: string } | null)?.title
      ?? '¡Felicidades! 🎂';
    const notifBody  = (tplRow as { body: string } | null)?.body
      ?? '¡Hoy es tu día! Mira todos los lugares que te quieren consentir 🎁';

    // ── Log ───────────────────────────────────────────────────────────────────
    const { data: logRow } = await admin.from('notification_logs').insert({
      title:        notifTitle,
      body:         notifBody,
      target_type:  'birthday',
      sent_count:   0,
      failed_count: 0,
      created_by:   null,
    }).select('id').single().catch(() => ({ data: null }));
    const logId: string = (logRow as { id: string } | null)?.id ?? '';

    // ── Credenciales Firebase ────────────────────────────────────────────────
    const sa = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT')!) as {
      project_id: string; client_email: string; private_key: string;
    };
    const accessToken = await getAccessToken(sa);
    const projectId   = sa.project_id;

    // ── Envío en lotes de 500 ────────────────────────────────────────────────
    const batch   = tokenRows.slice(0, 500);
    const results = await Promise.allSettled(
      batch.map(({ token }: { token: string }) =>
        sendToToken(token, notifTitle, notifBody, {
          type:                'birthday',
          notification_log_id: logId,
        }, accessToken, projectId),
      ),
    );

    const sent   = results.filter((r) => r.status === 'fulfilled' && (r as PromiseFulfilledResult<boolean>).value).length;
    const failed = results.length - sent;

    if (logId) {
      await admin.from('notification_logs')
        .update({ sent_count: sent, failed_count: failed })
        .eq('id', logId)
        .catch(() => {});
    }

    return new Response(
      JSON.stringify({ sent, failed, birthday_users: userIds.length }),
      { status: 200, headers: { 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    console.error('send-birthday-notifications error:', err);
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: { 'Content-Type': 'application/json' } },
    );
  }
});
