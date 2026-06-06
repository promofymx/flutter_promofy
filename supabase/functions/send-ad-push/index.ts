// Edge Function: send-ad-push
// Envía el push de una campaña de publicidad (format='push') a la audiencia
// segmentada y cobra por envío del saldo del establecimiento.
// Lo invoca la app al crear/lanzar una campaña con formato "Notif. push".
//
// Secrets: FIREBASE_SERVICE_ACCOUNT, MERCADOPAGO no aplica, SUPABASE_*

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const cors = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Headers': 'authorization, content-type, apikey',
};

// ── FCM helpers ────────────────────────────────────────────────────────────────
function b64url(data: string | ArrayBuffer): string {
  const bytes = typeof data === 'string' ? new TextEncoder().encode(data) : new Uint8Array(data);
  let s = ''; bytes.forEach((b) => (s += String.fromCharCode(b)));
  return btoa(s).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
}
function pem2ab(pem: string): ArrayBuffer {
  const b64 = pem.replace(/-----BEGIN PRIVATE KEY-----/g, '')
    .replace(/-----END PRIVATE KEY-----/g, '').replace(/\s/g, '');
  const bin = atob(b64); const u = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) u[i] = bin.charCodeAt(i);
  return u.buffer;
}
async function accessToken(sa: { client_email: string; private_key: string }): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const h = b64url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const p = b64url(JSON.stringify({
    iss: sa.client_email, sub: sa.client_email,
    aud: 'https://oauth2.googleapis.com/token', iat: now, exp: now + 3600,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
  }));
  const key = await crypto.subtle.importKey('pkcs8', pem2ab(sa.private_key),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' }, false, ['sign']);
  const sig = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', key, new TextEncoder().encode(`${h}.${p}`));
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion: `${h}.${p}.${b64url(sig)}` }),
  });
  return (await res.json()).access_token as string;
}
async function sendTo(token: string, title: string, body: string, data: Record<string, string>, at: string, project: string): Promise<boolean> {
  const r = await fetch(`https://fcm.googleapis.com/v1/projects/${project}/messages:send`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${at}`, 'Content-Type': 'application/json' },
    body: JSON.stringify({ message: { token, notification: { title, body }, data,
      android: { notification: { sound: 'default', click_action: 'FLUTTER_NOTIFICATION_CLICK' } },
      apns: { payload: { aps: { sound: 'default' } } } } }),
  });
  return r.ok;
}

// ── Handler ─────────────────────────────────────────────────────────────────────
function json(b: unknown, s = 200) {
  return new Response(JSON.stringify(b), { status: s, headers: { ...cors, 'Content-Type': 'application/json' } });
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });
  try {
    const auth = req.headers.get('Authorization');
    if (!auth) return json({ error: 'No autorizado' }, 401);

    const admin = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
    const { data: { user } } = await admin.auth.getUser(auth.replace('Bearer ', ''));
    if (!user) return json({ error: 'Sesión inválida' }, 401);

    const { campaign_id } = await req.json() as { campaign_id: string };
    if (!campaign_id) return json({ error: 'campaign_id requerido' }, 400);

    // Campaña + establecimiento
    const { data: c } = await admin.from('ad_campaigns').select('*').eq('id', campaign_id).single();
    if (!c) return json({ error: 'Campaña no encontrada' }, 404);
    if (c.format !== 'push') return json({ error: 'La campaña no es de tipo push' }, 400);

    const { data: est } = await admin.from('establishments')
      .select('name, owner_id').eq('id', c.establishment_id).single();
    if (!est) return json({ error: 'Establecimiento no encontrado' }, 404);
    if (est.owner_id !== user.id) return json({ error: 'No autorizado' }, 403);

    // Precio por envío + saldo
    const { data: pr } = await admin.from('ad_pricing').select('price_mxn').eq('format', 'push').single();
    const price = Number(pr?.price_mxn ?? 0);
    const { data: cr } = await admin.from('ad_credits').select('balance_mxn').eq('establishment_id', c.establishment_id).single();
    const balance = Number(cr?.balance_mxn ?? 0);
    if (price <= 0 || balance < price) {
      return json({ sent: 0, message: 'Sin saldo suficiente para enviar el push' });
    }
    const affordable = Math.floor(balance / price);

    // Audiencia segmentada (género + edad)
    const { data: rows } = await admin.rpc('get_tokens_for_filters', {
      p_gender:             c.target_gender === 'all' ? null : c.target_gender,
      p_age_min:            c.target_min_age ?? null,
      p_age_max:            c.target_max_age ?? null,
      p_inactive_days:      null,
      p_establishment_id:   null,
      p_platform:           null,
      p_characteristic_ids: null,
    });
    const tokens: string[] = ((rows as { token: string }[]) ?? []).map((r) => r.token);
    if (tokens.length === 0) return json({ sent: 0, message: 'Sin audiencia para los filtros' });

    const batch = tokens.slice(0, Math.min(affordable, 500));

    const title = `📣 ${est.name}`;
    const body  = c.name as string;

    // Log
    const { data: logRow } = await admin.from('notification_logs').insert({
      title, body, target_type: 'ad_push', sent_count: 0, failed_count: 0,
      created_by: user.id, establishment_id: c.establishment_id,
    }).select('id').single();
    const logId = (logRow as { id: string } | null)?.id ?? '';

    const sa = JSON.parse(Deno.env.get('FIREBASE_SERVICE_ACCOUNT')!) as
      { project_id: string; client_email: string; private_key: string };
    const at = await accessToken(sa);

    const results = await Promise.allSettled(batch.map((t) =>
      sendTo(t, title, body, { type: 'ad_push', campaign_id, establishment_id: c.establishment_id, notification_log_id: logId }, at, sa.project_id)));
    const sent = results.filter((r) => r.status === 'fulfilled' && r.value).length;
    const failed = results.length - sent;

    // Cobro por los envíos exitosos
    if (sent > 0) await admin.rpc('debit_ad_push', { p_campaign_id: campaign_id, p_count: sent });

    if (logId) {
      try { await admin.from('notification_logs').update({ sent_count: sent, failed_count: failed }).eq('id', logId); } catch (_) {}
    }
    // Push es de un solo disparo → marcar completada
    try { await admin.from('ad_campaigns').update({ status: 'completed', updated_at: new Date().toISOString() }).eq('id', campaign_id); } catch (_) {}

    return json({ sent, failed, charged: sent * price });
  } catch (err) {
    console.error('send-ad-push error:', err);
    return json({ error: String(err) }, 500);
  }
});
