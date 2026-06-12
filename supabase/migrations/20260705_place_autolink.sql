-- Auto-vinculación con Google Places para establecimientos que se dan de alta
-- SIN venir de nuestra prospección (place_id NULL). El sistema los busca por
-- nombre + dirección en Google; si hay match confiable, les pega el place_id y
-- la calificación. De ahí en adelante el cron refresh-google-ratings los mantiene.

-- Marca de cuándo se intentó el match (para no re-consultar a Google a diario
-- los que no tienen coincidencia clara).
ALTER TABLE public.establishments
  ADD COLUMN IF NOT EXISTS google_place_match_at timestamptz;

-- ── Candidatos a vincular ─────────────────────────────────────────────────────
-- Si p_id viene, devuelve ese (si aún no tiene place_id). Si no, el lote del día
-- (nunca intentados primero; reintenta los viejos cada 30 días).
CREATE OR REPLACE FUNCTION public.establishments_for_place_match(
  p_id    uuid DEFAULT NULL,
  p_limit int  DEFAULT 20
)
RETURNS TABLE(
  id           uuid,
  name         text,
  street       text,
  municipality text,
  lat          double precision,
  lng          double precision
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT e.id, e.name, e.street, e.municipality,
         ST_Y(e.location::geometry) AS lat,
         ST_X(e.location::geometry) AS lng
  FROM public.establishments e
  WHERE e.place_id IS NULL
    AND e.name IS NOT NULL AND btrim(e.name) <> ''
    AND (
      (p_id IS NOT NULL AND e.id = p_id)
      OR
      (p_id IS NULL AND (e.google_place_match_at IS NULL
                         OR e.google_place_match_at < now() - interval '30 days'))
    )
  ORDER BY e.google_place_match_at ASC NULLS FIRST
  LIMIT p_limit;
$$;

GRANT EXECUTE ON FUNCTION public.establishments_for_place_match(uuid, int)
  TO service_role, authenticated;

-- ── Trigger instantáneo al darse de alta ─────────────────────────────────────
-- Cuando se inserta un establecimiento SIN place_id (alta propia del dueño, no
-- siembra), dispara la edge function para ese id. Es async (pg_net encola y no
-- bloquea el insert). Los sembrados ya traen place_id → el WHEN evita que dispare.
CREATE OR REPLACE FUNCTION public.trg_autolink_google_place()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM net.http_post(
    url     := 'https://hfmvelirrcawsxaudhfl.supabase.co/functions/v1/match-google-places',
    headers := jsonb_build_object(
      'Content-Type',  'application/json',
      'Authorization', 'Bearer ' || current_setting('app.service_role_key', true)
    ),
    body    := jsonb_build_object('establishment_id', NEW.id)
  );
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RETURN NEW;  -- nunca romper el alta por esto
END;
$$;

DROP TRIGGER IF EXISTS autolink_google_place_on_insert ON public.establishments;
CREATE TRIGGER autolink_google_place_on_insert
  AFTER INSERT ON public.establishments
  FOR EACH ROW
  WHEN (NEW.place_id IS NULL)
  EXECUTE FUNCTION public.trg_autolink_google_place();
