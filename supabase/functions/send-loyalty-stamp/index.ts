// supabase/functions/send-loyalty-stamp/index.ts
// Envía una notificación push al CLIENTE cuando el dueño le registra una
// visita (sello) escaneando su QR. El mensaje refleja el progreso de la
// tarjeta, igual que el sheet "¡Visita registrada!" que ve el dueño.
//
// Se invoca desde loyalty_datasource.recordVisit() tras un sello exitoso.
//
// Seguridad: valida que quien llama (JWT) sea el dueño del establecimiento
// dueño del programa. Usa service role para leer device_tokens del cliente.
//
// Secrets requeridos:
//   FIREBASE_SERVICE_ACCOUNT  → JSON de la clave de cuenta de servicio Firebase
//   SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY / SUPABASE_ANON_KEY (automáticos)

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
            payload: { aps: { sound: 'default' } },
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
      program_id,
      client_id,
      program_visits,
      visits_required,
      reward_ready,
    } = await req.json() as {
      program_id:      string;
      client_id:       string;
      program_visits:  number;
      visits_required: number;
      reward_ready:    boolean;
    };

    if (!program_id || !client_id) {
      return new Response(
        JSON.stringify({ error: 'program_id y client_id son requeridos' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } },
      );
    }

    // 1) Identificar al que llama (debe ser el dueño)
    const authHeader = req.headers.get('Authorization') ?? '';
    const userClient = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } },
    );
    const { data: userData } = await userClient.auth.getUser();
    const callerId = userData?.user?.id;
    if (!callerId) {
      return new Response(
        JSON.stringify({ error: 'no autenticado' }),
        { status: 401, headers: { 'Content-Type': 'application/json' } },
      );
    }

    // 2) Service role: validar que el caller es dueño del programa y obtener nombre
    const admin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    const { data: prog, error: progErr } = await admin
      .from('loyalty_programs')
      .select('id, establishment_id, establishments!inner(name, owner_id)')
      .eq('id', program_id)
      .single();
    if (progErr || !prog) {
      return new Response(
        JSON.stringify({ error: 'programa no encontrado' }),
        { status: 404, headers: { 'Content-Type': 'application/json' } },
      );
    }

    // El embed puede venir como objeto o arreglo según la relación
    const est = Array.isArray((prog as Record<string, unknown>).establishments)
      ? (prog as { establishments: { name: string; owner_id: string }[] }).establishments[0]
      : (prog as { establishments: { name: string; owner_id: string } }).establishments;

    if (!est || est.owner_id !== callerId) {
      return new Response(
        JSON.stringify({ error: 'no autorizado' }),
        { status: 403, headers: { 'Content-Type': 'application/json' } },
      );
    }
    const establishmentName = est.name ?? 'tu lugar favorito';

    // 3) Tokens del cliente
    const { data: tokens, error: tokErr } = await admin
      .from('device_tokens')
      .select('token')
      .eq('user_id', client_id);
    if (tokErr) throw tokErr;

    if (!tokens || tokens.length === 0) {
      return new Response(
        JSON.stringify({ sent: 0, message: 'cliente sin dispositivos' }),
        { status: 200, headers: { 'Content-Type': 'application/json' } },
      );
    }

    // 4) Construir mensaje según progreso
    let title: string;
    let body:  string;
    if (reward_ready) {
      title = `🎁 ¡Recompensa lista en ${establishmentName}!`;
      body  = `Completaste tus ${visits_required} sellos. ¡Reclama tu premio!`;
    } else {
      const left = (visits_required ?? 0) - (program_visits ?? 0);
      title = `✅ Visita registrada en ${establishmentName}`;
      body  = left > 0
        ? `Llevas ${program_visits} de ${visits_required} sellos. ¡Te falta${left === 1 ? '' : 'n'} ${left}!`
        : `Llevas ${program_visits} de ${visits_required} sellos.`;
    }

    // 5) Credenciales Firebase y envío
    const serviceAccount = JSON.parse(
      Deno.env.get('FIREBASE_SERVICE_ACCOUNT')!,
    ) as { project_id: string; client_email: string; private_key: string };

    const accessToken = await getAccessToken(serviceAccount);
    const projectId   = serviceAccount.project_id;

    const results = await Promise.allSettled(
      tokens.map(({ token }: { token: string }) =>
        sendToToken(
          token,
          title,
          body,
          {
            type:           'loyalty_stamp',
            program_id:     program_id,
            reward_ready:   String(!!reward_ready),
          },
          accessToken,
          projectId,
        ),
      ),
    );

    const sent   = results.filter((r) => r.status === 'fulfilled' && r.value).length;
    const failed = results.length - sent;

    return new Response(
      JSON.stringify({ sent, failed }),
      { status: 200, headers: { 'Content-Type': 'application/json' } },
    );
  } catch (err) {
    console.error('send-loyalty-stamp error:', err);
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: { 'Content-Type': 'application/json' } },
    );
  }
});
