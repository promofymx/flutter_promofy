-- ════════════════════════════════════════════════════════════════════════════
-- Franjas horarias en el feed de establecimientos (Lugares).
-- Agrega filter_time_band: 'desayuno' | 'comida' | 'cena' | 'madrugada'.
-- Usa el horario del día actual (hora México) desde establishments.schedule (JSON
-- con {dia: {open, close, closed}}) y verifica traslape con la franja.
--
-- Se eliminan los 2 overloads anteriores y se deja UNO solo (10 params + franja),
-- para evitar ambigüedad en llamadas por nombre de parámetro.
-- ════════════════════════════════════════════════════════════════════════════

DROP FUNCTION IF EXISTS public.get_establishments_by_distance(
  double precision, double precision, double precision, text, boolean, uuid, integer, integer);
DROP FUNCTION IF EXISTS public.get_establishments_by_distance(
  double precision, double precision, double precision, text, boolean, integer, integer[], uuid, integer, integer);

CREATE OR REPLACE FUNCTION public.get_establishments_by_distance(
  user_lat double precision,
  user_lng double precision,
  radius_km double precision DEFAULT 50,
  search_query text DEFAULT NULL,
  flash_only boolean DEFAULT false,
  filter_category_id integer DEFAULT NULL,
  filter_characteristic_ids integer[] DEFAULT NULL,
  current_user_id uuid DEFAULT NULL,
  page_number integer DEFAULT 0,
  page_size integer DEFAULT 20,
  filter_time_band text DEFAULT NULL
)
RETURNS TABLE(id uuid, name text, logo_url text, address text, lat double precision, lng double precision, distance_meters double precision, is_favorited boolean, active_promos_count bigint, has_flash_promos boolean)
LANGUAGE sql
STABLE SECURITY DEFINER
AS $function$
  SELECT
    e.id,
    e.name,
    e.logo_url,
    COALESCE(e.address, e.street, '')  AS address,
    ST_Y(e.location::geometry)         AS lat,
    ST_X(e.location::geometry)         AS lng,
    ST_Distance(
      e.location::geography,
      ST_MakePoint(user_lng, user_lat)::geography
    ) AS distance_meters,
    COALESCE(
      (SELECT true FROM user_favorite_establishments ufe
       WHERE ufe.user_id = current_user_id
         AND ufe.establishment_id = e.id),
      false
    ) AS is_favorited,
    (SELECT COUNT(*) FROM promotions p
     WHERE p.establishment_id = e.id) AS active_promos_count,
    EXISTS (
      SELECT 1 FROM promotions p
      WHERE p.establishment_id = e.id
        AND p.type = 'flash'
        AND now() BETWEEN p.flash_starts_at AND p.flash_ends_at
    ) AS has_flash_promos
  FROM establishments e
  CROSS JOIN LATERAL (
    SELECT (e.schedule -> (CASE EXTRACT(ISODOW FROM (now() AT TIME ZONE 'America/Mexico_City'))::int
              WHEN 1 THEN 'monday'   WHEN 2 THEN 'tuesday' WHEN 3 THEN 'wednesday'
              WHEN 4 THEN 'thursday' WHEN 5 THEN 'friday'  WHEN 6 THEN 'saturday'
              WHEN 7 THEN 'sunday' END)) AS day_sched
  ) sch
  WHERE e.is_active = true
    AND e.location IS NOT NULL
    AND ST_DWithin(
      e.location::geography,
      ST_MakePoint(user_lng, user_lat)::geography,
      radius_km * 1000
    )
    AND (search_query IS NULL OR search_query = ''
         OR e.name ILIKE '%' || search_query || '%')
    AND (flash_only = false OR EXISTS (
      SELECT 1 FROM promotions p
      WHERE p.establishment_id = e.id
        AND p.type = 'flash'
        AND now() BETWEEN p.flash_starts_at AND p.flash_ends_at
    ))
    AND (filter_category_id IS NULL
         OR e.category_id = filter_category_id)
    AND (filter_characteristic_ids IS NULL OR EXISTS (
      SELECT 1 FROM establishment_characteristics ec
      WHERE ec.establishment_id = e.id
        AND ec.characteristic_id = ANY(filter_characteristic_ids)
    ))
    AND (
      e.adult_promotions = false
      OR (
        current_user_id IS NOT NULL
        AND EXISTS (
          SELECT 1 FROM profiles up
          WHERE  up.id         = current_user_id
            AND  up.birth_date IS NOT NULL
            AND  up.birth_date <= CURRENT_DATE - INTERVAL '18 years'
        )
      )
    )
    -- ── Franja horaria: horario del día actual traslapa con la franja ──
    AND (filter_time_band IS NULL OR (
      sch.day_sched IS NOT NULL
      AND COALESCE((sch.day_sched->>'closed')::boolean, false) = false
      AND (sch.day_sched->>'open')  IS NOT NULL
      AND (sch.day_sched->>'close') IS NOT NULL
      AND (sch.day_sched->>'open')::time  < (CASE filter_time_band
            WHEN 'desayuno'  THEN time '12:00'
            WHEN 'comida'    THEN time '18:00'
            WHEN 'cena'      THEN time '23:59:59'
            WHEN 'madrugada' THEN time '06:00'
            ELSE time '23:59:59' END)
      AND (sch.day_sched->>'close')::time > (CASE filter_time_band
            WHEN 'desayuno'  THEN time '06:00'
            WHEN 'comida'    THEN time '12:00'
            WHEN 'cena'      THEN time '18:00'
            WHEN 'madrugada' THEN time '00:00'
            ELSE time '00:00' END)
    ))
  ORDER BY distance_meters ASC
  LIMIT page_size OFFSET page_number * page_size;
$function$;

GRANT EXECUTE ON FUNCTION public.get_establishments_by_distance TO authenticated, anon;
