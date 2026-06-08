-- ════════════════════════════════════════════════════════════════════════════
-- Franjas horarias en el feed de promociones (Inicio).
-- Agrega filter_time_band: 'desayuno' | 'comida' | 'cena' | 'madrugada'.
-- Una promo entra en la franja si su [start_time, end_time] se traslapa con el
-- rango de la franja. NULL = sin filtro (igual que antes).
--
-- Se DROP+CREATE para no dejar overloads ambiguos (la app llama por nombre de
-- parámetro; el nuevo parámetro va con DEFAULT NULL, así la llamada actual sigue
-- funcionando sin cambios hasta que el cliente lo envíe).
-- ════════════════════════════════════════════════════════════════════════════

DROP FUNCTION IF EXISTS public.get_promotions_by_distance(
  double precision, double precision, double precision, integer, integer, uuid,
  boolean, boolean, text, text[], integer, text, text, boolean, uuid);

CREATE OR REPLACE FUNCTION public.get_promotions_by_distance(
  user_lat double precision,
  user_lng double precision,
  radius_km double precision DEFAULT 10,
  page_size integer DEFAULT 10,
  page_number integer DEFAULT 0,
  current_user_id uuid DEFAULT NULL,
  filter_active_now boolean DEFAULT false,
  filter_flash_only boolean DEFAULT false,
  filter_category_id text DEFAULT NULL,
  filter_characteristic_ids text[] DEFAULT NULL,
  filter_day_of_week integer DEFAULT NULL,
  filter_payment_method text DEFAULT NULL,
  search_query text DEFAULT NULL,
  filter_favorites_only boolean DEFAULT false,
  filter_establishment_id uuid DEFAULT NULL,
  filter_time_band text DEFAULT NULL
)
RETURNS TABLE(id uuid, establishment_id uuid, establishment_name text, establishment_logo text, name text, description text, active_days integer[], start_time time without time zone, end_time time without time zone, is_adult_only boolean, type text, flash_starts_at timestamp with time zone, flash_ends_at timestamp with time zone, photo_url text, distance_meters double precision, favorites_count bigint, avg_rating double precision, is_favorited boolean, category_id integer, category_name text)
LANGUAGE sql
SECURITY DEFINER
AS $function$
  SELECT
    p.id,
    e.id                                                        AS establishment_id,
    e.name                                                      AS establishment_name,
    e.logo_url                                                  AS establishment_logo,
    p.name,
    p.description,
    p.active_days,
    p.start_time,
    p.end_time,
    p.is_adult_only,
    p.type,
    p.flash_starts_at,
    p.flash_ends_at,
    p.photo_url,
    ST_Distance(
      e.location::geography,
      ST_MakePoint(user_lng, user_lat)::geography
    )                                                           AS distance_meters,
    COUNT(ufp.promotion_id)::bigint                             AS favorites_count,
    p.avg_rating,
    COALESCE(BOOL_OR(ufp.user_id = current_user_id), false)    AS is_favorited,
    p.category_id,
    pc.name                                                     AS category_name
  FROM   promotions p
  JOIN   establishments e ON e.id = p.establishment_id
  LEFT   JOIN user_favorite_promotions ufp ON ufp.promotion_id = p.id
  LEFT   JOIN public.categories         pc ON pc.id = p.category_id
  LEFT   JOIN public.profiles           up ON up.id = current_user_id
  WHERE
    ST_Distance(
      e.location::geography,
      ST_MakePoint(user_lng, user_lat)::geography
    ) <= radius_km * 1000

    AND p.is_active  = true
    AND p.deleted_at IS NULL
    AND e.is_active  = true

    AND (
      p.is_adult_only = false
      OR (
        up.birth_date IS NOT NULL
        AND up.birth_date <= CURRENT_DATE - INTERVAL '18 years'
      )
    )

    AND (filter_active_now = false OR (
      (NOW() AT TIME ZONE 'America/Mexico_City')::time
        BETWEEN p.start_time AND p.end_time
      AND (EXTRACT(ISODOW FROM (NOW() AT TIME ZONE 'America/Mexico_City')))::int
        = ANY(p.active_days)
    ))

    AND (filter_flash_only = false OR p.type = 'flash')

    AND (filter_category_id IS NULL
         OR p.category_id::text = filter_category_id)

    AND (filter_characteristic_ids IS NULL OR EXISTS (
      SELECT 1 FROM establishment_characteristics ec
      WHERE  ec.establishment_id = e.id
        AND  ec.characteristic_id::text = ANY(filter_characteristic_ids)
    ))

    AND (filter_day_of_week IS NULL
         OR filter_day_of_week = ANY(p.active_days))

    AND (filter_payment_method IS NULL
         OR p.payment_methods @> ARRAY[filter_payment_method])

    AND (search_query IS NULL OR (
      p.name  ILIKE '%' || search_query || '%'
      OR e.name ILIKE '%' || search_query || '%'
    ))

    AND (filter_favorites_only = false OR EXISTS (
      SELECT 1 FROM user_favorite_promotions ufp2
      WHERE  ufp2.promotion_id = p.id
        AND  ufp2.user_id      = current_user_id
    ))

    AND (filter_establishment_id IS NULL
         OR e.id = filter_establishment_id)

    -- ── Franja horaria: traslape de [start_time, end_time] con la franja ──
    AND (filter_time_band IS NULL OR (
      p.start_time IS NOT NULL AND p.end_time IS NOT NULL
      AND p.start_time < (CASE filter_time_band
            WHEN 'desayuno'  THEN time '12:00'
            WHEN 'comida'    THEN time '18:00'
            WHEN 'cena'      THEN time '23:59:59'
            WHEN 'madrugada' THEN time '06:00'
            ELSE time '23:59:59' END)
      AND p.end_time   > (CASE filter_time_band
            WHEN 'desayuno'  THEN time '06:00'
            WHEN 'comida'    THEN time '12:00'
            WHEN 'cena'      THEN time '18:00'
            WHEN 'madrugada' THEN time '00:00'
            ELSE time '00:00' END)
    ))

  GROUP  BY p.id, e.id, e.name, e.logo_url, distance_meters,
            p.category_id, pc.name
  ORDER  BY distance_meters
  LIMIT  page_size
  OFFSET page_number * page_size;
$function$;

GRANT EXECUTE ON FUNCTION public.get_promotions_by_distance TO authenticated, anon;
