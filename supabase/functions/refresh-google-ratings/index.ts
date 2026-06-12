// Refresca la calificación de Google (rating + #reseñas) de los establecimientos.
// Procesa un lote por corrida (los más viejos primero), respetando el crédito
// gratis de Google ($200/mes). 50/día ≈ 1,500/mes ≈ todos los prospectos.
//
// Requiere el secreto GOOGLE_PLACES_KEY (Places API New habilitada).
//   supabase secrets set GOOGLE_PLACES_KEY=AIza...
//
// Place Details (New):
//   GET https://places.googleapis.com/v1/places/{PLACE_ID}
//   headers: X-Goog-Api-Key, X-Goog-FieldMask: rating,userRatingCount

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const BATCH = Number(Deno.env.get('RATING_BATCH') ?? '50');

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

Deno.serve(async () => {
  try {
    const admin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );
    const key = Deno.env.get('GOOGLE_PLACES_KEY');
    if (!key) return json({ ok: false, error: 'Falta el secreto GOOGLE_PLACES_KEY' }, 500);

    // Los más viejos primero (nulls al frente = nunca refrescados).
    const { data: rows, error } = await admin
      .from('establishments')
      .select('id, place_id, rating_updated_at')
      .not('place_id', 'is', null)
      .order('rating_updated_at', { ascending: true, nullsFirst: true })
      .limit(BATCH);
    if (error) return json({ ok: false, error: error.message }, 500);

    const now = new Date().toISOString();
    let updated = 0, failed = 0;

    for (const e of rows ?? []) {
      try {
        const r = await fetch(
          `https://places.googleapis.com/v1/places/${encodeURIComponent(e.place_id)}`,
          {
            headers: {
              'X-Goog-Api-Key': key,
              'X-Goog-FieldMask': 'rating,userRatingCount',
            },
          },
        );
        if (!r.ok) {
          // Marca timestamp para que rote y no se atore en place_id inválidos.
          await admin.from('establishments').update({ rating_updated_at: now }).eq('id', e.id);
          failed++;
          continue;
        }
        const d = await r.json();
        await admin.from('establishments').update({
          google_rating: d.rating ?? null,
          google_reviews: d.userRatingCount ?? null,
          rating_updated_at: now,
        }).eq('id', e.id);
        updated++;
      } catch (_) {
        await admin.from('establishments').update({ rating_updated_at: now }).eq('id', e.id);
        failed++;
      }
    }

    return json({ ok: true, processed: (rows ?? []).length, updated, failed });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});
