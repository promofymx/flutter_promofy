// supabase/functions/send-broadcast-notification/index.ts
// Envía una notificación push broadcast con soporte de filtros de segmentación.
// Incluye notification_log_id en el payload FCM para registrar aperturas.
//
// Secrets requeridos:
//   FIREBASE_SERVICE_ACCOUNT → JSON de la cuenta de servicio de Firebase

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// ── JWT / FCM helpers ─────────────────────────────────────────────────────────

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
  const bytes  = new Uint8Array(binary.length);
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
    iss:   sa.client_email,
    sub:   sa.client_email,
    aud:   'https://oauth2.googleapis.com/token',
    iat:   now,
    exp:   now + 3600,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
  };
  const h64   = base64urlEncode(JSON.stringify(header));
  const p64   = base64urlEncode(JSON.stringify(payload));
  const input = `${h64}.${p64}`;
  const key   = await crypto.subtle.importKey(
    'pkcs8', pemToArrayBuffer(sa.private_key),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, ['sign'],
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
  accessToken: string, projectId: string,
  logId: string,
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
          data: {
            type:                 'broadcast',
            notification_log_id:  logId,
          },
          android: { notification: { sound: 'default', click_action: 'FLUTTER_NOTIFICATION_CLICK' } },
          apns:    { payload: { aps: { sound: 'default' } } },
        },
      }),
    },
  );
  return res.ok;
}

// ── Obtener tokens según filtros ──────────────────────────────────────────────

async function getTokens(
  admin:   ReturnType<typeof createClient>,
  filters: Record<string, unknown>,
): Promise<string[]> {
  const hasFilters = filters && Object.keys(filters).some((k) => filters[k] != null);

  if (!hasFilters) {
    const { data, error } = await admin.from('device_tokens').select('token');
    if (error || !data) return [];
    return data.map((r: { token: string }) => r.token);
  }

  const rawCharIds = filters.characteristic_ids as unknown;
  const charIds = Array.isArray(rawCharIds) && rawCharIds.length > 0
    ? rawCharIds.map((id) => parseInt(id as string, 10)).filter((n) => !isNaN(n))
    : null;

  const { data, error } = await admin.rpc('get_tokens_for_filters', {
    p_gender:             filters.gender             ?? null,
    p_age_min:            filters.age_min            ?? null,
    p_age_max:            filters.age_max            ?? null,
    p_inactive_days:      filters.inactive_days      ?? null,
    p_establishment_id:   filters.establishment_id   ?? null,
    p_platform:           filters.platform           ?? null,
    p_characteristic_ids: charIds,
  });
  if (error || !data) return [];
  return (data as { token: string }[]).map((r) => r.token);
}

// ── Handler ───────────────────────────────────────────────────────────────────

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
    const { title, body, sent_by, filters = {} } = await req.json() as {
      title:    string;
      body:     string;
      sent_by:  string;
      filters?: Record<string, unknown>;
    };

    if (!title || !body) {
      return new Response(
        JSON.stringify({ error: 'title y body son requeridos' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } },
      );
    }

    const admin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    // Insertar log primero para obtener el ID (se incluye en el payload FCM)
    const { data: logRow, error: logErr } = await admin
      .from('notification_logs')
      .insert({
        title,
        body,
        target_type:  'broadcast',
        sent_count:   0,
        failed_count: 0,
        created_by:   sent_by || null,
        filters:      Object.keys(filters).length > 0 ? filters : null,
      })
      .select('id')
      .single();

    if (logErr || !logRow) throw logErr ?? new Error('No se pudo crear el log');
    const logId = logRow.id as string;

    const tokens = await getTokens(admin, filters);

    if (tokens.length === 0) {
      return new Response(
        JSON.stringify({ sent: 0, failed: 0, message: 'Sin dispositivos para los filtros indicados' }),
        { status: 200, headers: { 'Content-Type': 'application/json' } },
      );
    }

    // Campanita in-app: mapear tokens → user_ids (en lotes) y guardar la notif.
    try {
      const ids = new Set<string>();
      for (let i = 0; i < tokens.length; i += 150) {
        const chunk = tokens.slice(i, i + 150);
        const { data: ut } = await admin
          .from('device_tokens').select('user_id').in('token', chunk);
        for (const r of (ut ?? []) as { user_id: string }[]) ids.add(r.user_id);
      }
      if (ids.size > 0) {
        await admin.rpc('enqueue_user_notifications', {
          p_user_ids: [...ids],
          p_title:    title,
          p_body:     body,
          p_type:     'broadcast',
          p_data:     {},
        });
      }
    } catch (_) { /* no crítico */ }

    const sa = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT')!) as {
      project_id: string; client_email: string; private_key: string;
    };
    const accessToken = await getAccessToken(sa);
    const projectId   = sa.project_id;

    let sent = 0, failed = 0;
    for (let i = 0; i < tokens.length; i += 500) {
      const batch   = tokens.slice(i, i + 500);
      const results = await Promise.allSettled(
        batch.map((t) => sendToToken(t, title, body, accessToken, projectId, logId)),
      );
      for (const r of results) {
        if (r.status === 'fulfilled' && r.value) sent++;
        else failed++;
      }
    }

    // Actualizar log con conteos reales
    await admin.from('notification_logs')
      .update({ sent_count: sent, failed_count: failed })
      .eq('id', logId);

    return new Response(
      JSON.stringify({ sent, failed }),
      { status: 200, headers: { 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    console.error('send-broadcast-notification error:', err);
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: { 'Content-Type': 'application/json' } },
    );
  }
});
