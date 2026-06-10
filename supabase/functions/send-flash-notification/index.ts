// supabase/functions/send-flash-notification/index.ts
// Envía notificaciones push a usuarios que tienen como favorito
// el establecimiento que acaba de crear una promo flash.
//
// Se llama desde el BusinessCubit tras createPromo() cuando type == 'flash'.
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
      promo_name,
      promo_description,
    } = await req.json() as {
      establishment_id:  string;
      promo_name:        string;
      promo_description: string;
    };

    if (!establishment_id || !promo_name) {
      return new Response(
        JSON.stringify({ error: 'establishment_id y promo_name son requeridos' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } },
      );
    }

    // Cliente Supabase con service role para leer device_tokens
    const admin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    // 1) Usuarios que tienen el ESTABLECIMIENTO como favorito
    const { data: favs, error: favErr } = await admin
      .from('user_favorite_establishments')
      .select('user_id')
      .eq('establishment_id', establishment_id);
    if (favErr) throw favErr;

    // 1b) + usuarios que favoritearon una PROMO de este establecimiento
    const { data: promos } = await admin
      .from('promotions')
      .select('id')
      .eq('establishment_id', establishment_id);
    const promoIds = (promos ?? []).map((p: { id: string }) => p.id);
    const { data: promoFavs } = promoIds.length === 0
      ? { data: [] as { user_id: string }[] }
      : await admin
          .from('user_favorite_promotions')
          .select('user_id')
          .in('promotion_id', promoIds);

    // Unir ambos grupos y deduplicar
    const userIds = [...new Set([
      ...(favs ?? []).map((f: { user_id: string }) => f.user_id),
      ...(promoFavs ?? []).map((f: { user_id: string }) => f.user_id),
    ])];

    // 2) Tokens de dispositivo de esos usuarios
    const { data: tokens, error } = userIds.length === 0
      ? { data: [] as { token: string }[], error: null }
      : await admin.from('device_tokens').select('token').in('user_id', userIds);
    if (error) throw error;

    const notifTitle = `⚡ ${promo_name}`;
    const notifBody  = promo_description.length > 80
      ? `${promo_description.substring(0, 77)}...`
      : promo_description;

    // Campanita in-app: guardar la notificación para cada usuario destinatario.
    if (userIds.length > 0) {
      try {
        await admin.rpc('enqueue_user_notifications', {
          p_user_ids: userIds,
          p_title:    notifTitle,
          p_body:     notifBody,
          p_type:     'flash_promo',
          p_data:     { establishment_id },
        });
      } catch (_) { /* no crítico */ }
    }

    // Insertar log primero para obtener el ID (se incluye en payload FCM)
    let logId = '';
    try {
      const { data: logRow } = await admin.from('notification_logs').insert({
        title:            notifTitle,
        body:             notifBody,
        target_type:      'flash_promo',
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
            type:                'flash_promo',
            establishment_id:    establishment_id,
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
    console.error('send-flash-notification error:', err);
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: { 'Content-Type': 'application/json' } },
    );
  }
});
