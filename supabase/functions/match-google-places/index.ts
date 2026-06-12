// Vincula establecimientos sin place_id con su ficha de Google Places, buscando
// por nombre + dirección. Matching CONSERVADOR: solo asigna si el nombre coincide
// fuerte Y está cerca geográficamente. Ante la duda, NO asigna (mejor sin
// calificación que con la de otro negocio) y reintenta en 30 días.
//
// Modos:
//   POST {}                          → lote del día (cron)
//   POST {"establishment_id":"..."}  → solo ese (trigger al darse de alta)
//
// Requiere el secreto GOOGLE_PLACES_KEY (mismo de refresh-google-ratings).

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const BATCH = Number(Deno.env.get('PLACE_MATCH_BATCH') ?? '20');
const SEARCH_URL = 'https://places.googleapis.com/v1/places:searchText';

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

// Normaliza: minúsculas, sin acentos, sin signos → palabras.
function norm(s: string): string {
  return (s || '')
    .toLowerCase()
    .normalize('NFD').replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9 ]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

// Similitud de nombres (Jaccard de palabras).
function nameSim(a: string, b: string): number {
  const A = new Set(norm(a).split(' ').filter(Boolean));
  const B = new Set(norm(b).split(' ').filter(Boolean));
  if (!A.size || !B.size) return 0;
  let inter = 0;
  for (const w of A) if (B.has(w)) inter++;
  return inter / (A.size + B.size - inter);
}

function contains(a: string, b: string): boolean {
  const na = norm(a), nb = norm(b);
  if (!na || !nb) return false;
  return na.includes(nb) || nb.includes(na);
}

// Distancia en metros (haversine).
function distM(la1: number, lo1: number, la2: number, lo2: number): number {
  const R = 6371000, toR = (x: number) => (x * Math.PI) / 180;
  const dLa = toR(la2 - la1), dLo = toR(lo2 - lo1);
  const h = Math.sin(dLa / 2) ** 2 +
    Math.cos(toR(la1)) * Math.cos(toR(la2)) * Math.sin(dLo / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(h));
}

interface Est {
  id: string; name: string; street: string | null;
  municipality: string | null; lat: number | null; lng: number | null;
}

async function findMatch(e: Est, key: string) {
  const query = [e.name, e.street, e.municipality].filter(Boolean).join(', ');
  const body: Record<string, unknown> = {
    textQuery: query,
    maxResultCount: 5,
    languageCode: 'es',
    regionCode: 'MX',
  };
  if (e.lat != null && e.lng != null) {
    body.locationBias = {
      circle: { center: { latitude: e.lat, longitude: e.lng }, radius: 2000 },
    };
  }

  const r = await fetch(SEARCH_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': key,
      'X-Goog-FieldMask':
        'places.id,places.displayName,places.location,places.rating,places.userRatingCount',
    },
    body: JSON.stringify(body),
  });
  if (!r.ok) return null;
  const data = await r.json();
  const places: any[] = data.places ?? [];

  let best: any = null, bestScore = -1;
  for (const p of places.slice(0, 5)) {
    const dn = p.displayName?.text ?? '';
    const sim = nameSim(e.name, dn);
    const cont = contains(e.name, dn);
    const strongName = sim >= 0.8 || cont;
    let d: number | null = null;
    if (e.lat != null && e.lng != null && p.location) {
      d = distM(e.lat, e.lng, p.location.latitude, p.location.longitude);
    }

    // Reglas conservadoras de aceptación.
    const veryNear = d != null && d <= 60;                       // misma puerta
    const near     = d != null && d <= 150;                      // misma cuadra
    const nameOk   = sim >= 0.5 || cont;
    const accept =
      (veryNear && nameOk) ||                                    // pegado + plausible
      (near && strongName) ||                                    // cerca + nombre fuerte
      (d == null && strongName && sim >= 0.8);                   // sin coords: nombre casi idéntico

    if (!accept) continue;
    // Puntaje: prioriza cercanía, luego similitud.
    const score = (d != null ? Math.max(0, 1 - d / 200) : 0.4) + sim;
    if (score > bestScore) { bestScore = score; best = p; }
  }
  return best;
}

Deno.serve(async (req) => {
  try {
    const admin = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );
    const key = Deno.env.get('GOOGLE_PLACES_KEY');
    if (!key) return json({ ok: false, error: 'Falta el secreto GOOGLE_PLACES_KEY' }, 500);

    let singleId: string | null = null;
    try {
      const b = await req.json();
      singleId = b?.establishment_id ?? null;
    } catch (_) { /* lote */ }

    const { data: rows, error } = await admin.rpc('establishments_for_place_match', {
      p_id: singleId,
      p_limit: singleId ? 1 : BATCH,
    });
    if (error) return json({ ok: false, error: error.message }, 500);

    const now = new Date().toISOString();
    let linked = 0, nomatch = 0;

    for (const e of (rows ?? []) as Est[]) {
      try {
        const match = await findMatch(e, key);
        if (match?.id) {
          await admin.from('establishments').update({
            place_id: match.id,
            google_rating: match.rating ?? null,
            google_reviews: match.userRatingCount ?? null,
            rating_updated_at: now,
            google_place_match_at: now,
          }).eq('id', e.id);
          linked++;
        } else {
          await admin.from('establishments')
            .update({ google_place_match_at: now }).eq('id', e.id);
          nomatch++;
        }
      } catch (_) {
        await admin.from('establishments')
          .update({ google_place_match_at: now }).eq('id', e.id);
        nomatch++;
      }
    }

    return json({ ok: true, processed: (rows ?? []).length, linked, nomatch });
  } catch (e) {
    return json({ ok: false, error: String(e) }, 500);
  }
});
