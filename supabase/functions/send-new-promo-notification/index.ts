// supabase/functions/send-new-promo-notification/index.ts
// Envía notificaciones push a usuarios que tienen como favorito
// el establecimiento que acaba de crear una promo normal.
//
// Se llama desde el BusinessCubit tras createPromo() cuando type == 'normal'.
//
// Secrets requeridos:
//   FIREBASE_SERVICE_ACCOUNT  → JSON de la clave de cuenta de servicio de Firebase

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// ── Helpers JWT para FCM v1 API ───────────────────────────────────────────────

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
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes.buffer;
}

async function getAccessToken(serviceAccount: {
  client_email: string;
  private_key: string;
}): Promise<string> {
  const now = Math.floor(Date.now() / 1000);

  const header  = { alg: 'RS256', typ: 'JWT' };
  const payload = {
    iss:   serviceAccount.client_email,
    sub:   serviceAccount.client_email,
    aud:   'https://oauth2.googleapis.com/token',
    iat:   now,
    exp:   now + 3600,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
  };

  const headerB64  = base64urlEncode(JSON.stringify(header));
  const payloadB64 = base64urlEncode(JSON.stringify(payload));
  const input      = `${headerB64}.${payloadB64}`;

  const keyData = pemToArrayBuffer(serviceAccount.private_key);
  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    keyData,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );

  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    new TextEncoder().encode(input),
  );

  const jwt = `${input}.${base64urlEncode(signature)}`;

  const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion:  jwt,
    }),
  });

  const { access_token } = await tokenRes.json() as { access_token: string };
  return access_token;
}

// ── Envío de notificación individual ─────────────────────────────────────────

async function sendToToken(
  token:       string,
  title:       string,
  body:        string,
  data:        Record<string, string>,
  accessToken: string,
  projectId:   string,
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
            notification: {
              sound:        'default',
              click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
          },
          apns: {
            payload: {
              aps: { sound: 'default' },
            },
          },
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
    const {
      establishment_id,
      promo_id,
      promo_name,
    } = await req.json() as {
      establishment_id: string;
      promo_id:         string;
      promo_name:       string;
    };

    if (!establishment_id || !promo_id || !promo_name) {
      return new Response(
        JSON.stringify({ error: 'establishment_id, promo_id y promo_name son requeridos' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } },
      );
    }

    // Cliente Supabase con service role
    const admin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    // Obtener nombre del establecimiento
    const { data: estRow, error: estError } = await admin
      .from('establishments')
      .select('name')
      .eq('id', establishment_id)
      .single();

    if (estError || !estRow) {
      return new Response(
        JSON.stringify({ error: 'Establecimiento no encontrado' }),
        { status: 404, headers: { 'Content-Type': 'application/json' } },
      );
    }

    const establishmentName = (estRow as { name: string }).name;

    // Obtener primera plantilla activa de tipo 'normal'
    const { data: templateRow, error: templateError } = await admin
      .from('notification_templates')
      .select('title, body')
      .eq('promo_type', 'normal')
      .eq('is_active', true)
      .order('sort_order', { ascending: true })
      .limit(1)
      .single();

    if (templateError || !templateRow) {
      return new Response(
        JSON.stringify({ error: 'No hay plantillas de notificación disponibles' }),
        { status: 500, headers: { 'Content-Type': 'application/json' } },
      );
    }

    const template = templateRow as { title: string; body: string };

    // Reemplazar variables en plantilla
    const notifTitle = template.title
      .replace(/{establishment_name}/g, establishmentName)
      .replace(/{promo_name}/g, promo_name);
    const notifBody = template.body
      .replace(/{establishment_name}/g, establishmentName)
      .replace(/{promo_name}/g, promo_name);

    // 1) Usuarios que tienen el establecimiento como favorito
    const { data: favs, error: favErr } = await admin
      .from('user_favorite_establishments')
      .select('user_id')
      .eq('establishment_id', establishment_id);
    if (favErr) throw favErr;
    const userIds = (favs ?? []).map((f: { user_id: string }) => f.user_id);

    // 2) Tokens de dispositivo de esos usuarios
    const { data: tokens, error: tokensError } = userIds.length === 0
      ? { data: [] as { token: string }[], error: null }
      : await admin.from('device_tokens').select('token').in('user_id', userIds);
    if (tokensError) throw tokensError;

    // Insertar log primero para obtener el ID (se incluye en payload FCM)
    let logId = '';
    try {
      const { data: logRow } = await admin.from('notification_logs').insert({
        title:            notifTitle,
        body:             notifBody,
        target_type:      'new_promo',
        sent_count:       0,
        failed_count:     0,
        created_by:       null,
        establishment_id: establishment_id,
      }).select('id').single();
      logId = (logRow as { id: string } | null)?.id ?? '';
    } catch (_) { /* el log es opcional */ }

    if (!tokens || tokens.length === 0) {
      return new Response(
        JSON.stringify({ sent: 0, message: 'No hay usuarios con este favorito' }),
        { status: 200, headers: { 'Content-Type': 'application/json' } },
      );
    }

    // Credenciales Firebase
    const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT')!;
    const serviceAccount     = JSON.parse(serviceAccountJson) as {
      project_id:   string;
      client_email: string;
      private_key:  string;
    };

    const accessToken = await getAccessToken(serviceAccount);
    const projectId   = serviceAccount.project_id;

    // Enviar en paralelo (máximo 500 tokens por lote)
    const batch    = tokens.slice(0, 500);
    const results  = await Promise.allSettled(
      batch.map(({ token }) =>
        sendToToken(
          token,
          notifTitle,
          notifBody,
          {
            type:                'new_promo',
            promo_id:            promo_id,
            establishment_id:    establishment_id,
            establishment_name:  establishmentName,
            route:               `/promo/${promo_id}`,
            notification_log_id: logId,
          },
          accessToken,
          projectId,
        ),
      ),
    );

    const sent   = results.filter((r) => r.status === 'fulfilled' && r.value).length;
    const failed = results.length - sent;

    // Actualizar log con conteos reales
    if (logId) {
      try {
        await admin.from('notification_logs')
          .update({ sent_count: sent, failed_count: failed })
          .eq('id', logId);
      } catch (_) { /* no crítico */ }
    }

    return new Response(
      JSON.stringify({ sent, failed }),
      { status: 200, headers: { 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    console.error('send-new-promo-notification error:', err);
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: { 'Content-Type': 'application/json' } },
    );
  }
});
