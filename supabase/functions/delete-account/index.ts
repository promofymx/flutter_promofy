// supabase/functions/delete-account/index.ts
// Elimina permanentemente la cuenta del usuario autenticado y todos sus datos.
// Lo invoca la app desde Perfil → "Eliminar cuenta".
//
// Flujo:
//   1. Identifica al usuario a partir de su JWT (header Authorization).
//   2. Con el service role: libera negocios, borra el perfil y la cuenta de auth.
//      La mayoría de tablas dependientes se limpian solas por ON DELETE CASCADE.
//
// Secrets requeridos (ya disponibles por defecto en Edge Functions):
//   SUPABASE_URL · SUPABASE_ANON_KEY · SUPABASE_SERVICE_ROLE_KEY

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Headers': 'authorization, content-type, apikey',
};

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json', ...corsHeaders },
  });
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) return json({ error: 'No autorizado' }, 401);

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;

    // 1. Cliente con el token del usuario → identifica quién llama
    const userClient = createClient(
      supabaseUrl,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } },
    );
    const { data: { user }, error: userErr } = await userClient.auth.getUser();
    if (userErr || !user) return json({ error: 'Sesión inválida' }, 401);
    const userId = user.id;

    // 2. Cliente admin (service role) → borra datos y la cuenta
    const admin = createClient(
      supabaseUrl,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    // Best-effort: liberar negocios y limpiar datos directos del usuario.
    // (Tablas con FK ON DELETE CASCADE a auth.users/profiles se limpian solas.)
    await admin.from('establishments').update({ owner_id: null }).eq('owner_id', userId);
    await admin.from('device_tokens').delete().eq('user_id', userId);
    await admin.from('profiles').delete().eq('id', userId);

    // Borra la cuenta de auth (Google / email). Invalida la sesión actual.
    const { error: delErr } = await admin.auth.admin.deleteUser(userId);
    if (delErr) throw delErr;

    return json({ success: true }, 200);
  } catch (err) {
    console.error('delete-account error:', err);
    return json({ error: String(err) }, 500);
  }
});
