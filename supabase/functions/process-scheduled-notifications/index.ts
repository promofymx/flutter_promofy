// supabase/functions/process-scheduled-notifications/index.ts
//
// Procesa notificaciones programadas pendientes.
// Se ejecuta cada minuto mediante Deno.cron().
// Soporta filtros por: género, edad, inactividad, plataforma, establecimiento.
//
// Secrets requeridos:
//   FIREBASE_SERVICE_ACCOUNT → JSON de la cuenta de servicio de Firebase

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// ── Helpers JWT (idénticos a las otras funciones) ─────────────────────────────

function base64urlEncode(data: string | ArrayBuffer): string {
  const bytes = typeof data === 'string'
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

async function getAccessToken(sa: { client_email: string; private_key: string }): Promise<string> {
  const now     = Math.floor(Date.now() / 1000);
  const header  = { alg: 'RS256', typ: 'JWT' };
  const payload = {
    iss: sa.client_email, sub: sa.client_email,
    aud: 'https://oauth2.googleapis.com/token',
    iat: now, exp: now + 3600,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
  };
  const h64  = base64urlEncode(JSON.stringify(header));
  const p64  = base64urlEncode(JSON.stringify(payload));
  const input = `${h64}.${p64}`;
  const key = await crypto.subtle.importKey(
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
      assertion: jwt,
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
      headers: { 'Authorization': `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message: {
          token,
          notification: { title, body },
          data: {
            type:                'scheduled',
            notification_log_id: logId,
          },
          android: { notification: { sound: 'default', click_action: 'FLUTTER_NOTIFICATION_CLICK' } },
          apns:    { payload: { aps: { sound: 'default' } } },
        },
      }),
    },
  );
  return res.ok;
}

// ── Obtener tokens según filtros ───────────────────────────────────────────────

async function getTokensForFilters(
  admin: ReturnType<typeof createClient>,
  filters: Record<string, unknown>,
): Promise<string[]> {
  // Si no hay filtros → todos los tokens
  if (!filters || Object.keys(filters).length === 0) {
    const { data, error } = await admin.from('device_tokens').select('token');
    if (error || !data) return [];
    return data.map((r: { token: string }) => r.token);
  }

  // Con filtros → RPC count_notification_recipients adaptada para devolver tokens
  // Usamos la tabla directamente con los filtros aplicados
  const { data, error } = await admin.rpc('get_tokens_for_filters', {
    p_gender:             filters.gender             ?? null,
    p_age_min:            filters.age_min            ?? null,
    p_age_max:            filters.age_max            ?? null,
    p_inactive_days:      filters.inactive_days      ?? null,
    p_establishment_id:   filters.establishment_id   ?? null,
    p_platform:           filters.platform           ?? null,
    p_characteristic_ids: filters.characteristic_ids ?? null,
  });
  if (error || !data) return [];
  return (data as { token: string }[]).map((r) => r.token);
}

// ── Calcular próximo envío ────────────────────────────────────────────────────

function nextSendAt(lastSent: Date, recurrence: string | null): Date | null {
  if (!recurrence) return null;
  const d = new Date(lastSent);
  if (recurrence === 'daily')   d.setDate(d.getDate() + 1);
  if (recurrence === 'weekly')  d.setDate(d.getDate() + 7);
  if (recurrence === 'monthly') d.setMonth(d.getMonth() + 1);
  return d;
}

// ── Proceso principal ──────────────────────────────────────────────────────────

async function processPending(): Promise<{ processed: number }> {
  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  );

  const now = new Date().toISOString();

  // Leer notificaciones pendientes con next_send_at ≤ ahora
  const { data: scheduled, error } = await admin
    .from('scheduled_notifications')
    .select('*')
    .in('status', ['pending', 'active'])
    .lte('next_send_at', now);

  if (error || !scheduled || scheduled.length === 0) return { processed: 0 };

  const sa = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT')!) as {
    project_id: string; client_email: string; private_key: string;
  };
  const accessToken = await getAccessToken(sa);
  const projectId   = sa.project_id;

  for (const sn of scheduled) {
    try {
      const tokens = await getTokensForFilters(admin, sn.filters ?? {});

      // Insertar log primero para obtener el ID (se incluye en el payload FCM)
      const { data: logRow } = await admin.from('notification_logs').insert({
        title:                     sn.title,
        body:                      sn.body,
        target_type:               'scheduled',
        sent_count:                0,
        failed_count:              0,
        filters:                   sn.filters,
        scheduled_notification_id: sn.id,
      }).select('id').single();
      const logId: string = logRow?.id ?? '';

      let sent = 0; let failed = 0;
      // Enviar en lotes de 500
      for (let i = 0; i < tokens.length; i += 500) {
        const batch = tokens.slice(i, i + 500);
        const results = await Promise.allSettled(
          batch.map((t) => sendToToken(t, sn.title, sn.body, accessToken, projectId, logId)),
        );
        for (const r of results) {
          if (r.status === 'fulfilled' && r.value) sent++;
          else failed++;
        }
      }

      // Actualizar log con conteos reales
      if (logId) {
        await admin.from('notification_logs')
          .update({ sent_count: sent, failed_count: failed })
          .eq('id', logId);
      }

      // Actualizar estado de la notificación programada
      const sentAt  = new Date();
      const nextAt  = nextSendAt(sentAt, sn.recurrence);
      await admin.from('scheduled_notifications').update({
        status:       nextAt ? 'active' : 'sent',
        last_sent_at: sentAt.toISOString(),
        next_send_at: nextAt?.toISOString() ?? null,
        run_count:    (sn.run_count ?? 0) + 1,
        total_sent:   (sn.total_sent ?? 0) + sent,
        total_failed: (sn.total_failed ?? 0) + failed,
      }).eq('id', sn.id);
    } catch (err) {
      console.error(`Error procesando scheduled ${sn.id}:`, err);
      await admin.from('scheduled_notifications')
        .update({ status: 'cancelled' })
        .eq('id', sn.id);
    }
  }

  return { processed: scheduled.length };
}

// ── Cron (cada minuto) + handler HTTP (para llamadas manuales) ────────────────

// Cron nativo de Deno/Supabase — se ejecuta automáticamente cada minuto
Deno.cron('process-scheduled-notifications', '* * * * *', processPending);

// También responde a HTTP para poder llamarlo manualmente desde el panel
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
    const result = await processPending();
    return new Response(JSON.stringify(result), {
      status:  200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status:  500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
});
