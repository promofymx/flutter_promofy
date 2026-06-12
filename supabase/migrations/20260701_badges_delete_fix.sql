-- Fix: el remoto bloquea DELETE sin WHERE (sql_safe_updates). Recrea
-- compute_establishment_badges con "DELETE ... WHERE true".

CREATE OR REPLACE FUNCTION public.compute_establishment_badges()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE v_count integer;
BEGIN
  DELETE FROM public.establishment_badges WHERE true;

  WITH base AS (
    SELECT e.id,
           COALESCE(NULLIF(TRIM(e.municipality), ''), '(sin municipio)') AS municipality,
           ST_Y(e.location::geometry) AS lat,
           ST_X(e.location::geometry) AS lng,
           e.google_rating,
           e.google_reviews,
           (SELECT COUNT(*) FROM public.user_favorite_establishments f
              WHERE f.establishment_id = e.id)                                       AS favs,
           (SELECT COUNT(*) FROM public.user_favorite_establishments f
              WHERE f.establishment_id = e.id AND f.created_at >= now() - interval '7 days') AS trending,
           (SELECT COUNT(*) FROM public.loyalty_visit_log v
              WHERE v.establishment_id = e.id)                                       AS visits,
           (SELECT COUNT(*) FROM public.promotions p
              WHERE p.establishment_id = e.id AND p.is_active = true)                AS promos
    FROM public.establishments e
    WHERE e.is_active = true AND e.location IS NOT NULL
  ),
  muni AS (
    SELECT municipality, COUNT(*) AS n, AVG(lat) AS clat, AVG(lng) AS clng
    FROM base GROUP BY municipality
  ),
  withpos AS (
    SELECT b.*, m.n, m.clat, m.clng,
           sqrt(power(b.lat - m.clat, 2) + power(b.lng - m.clng, 2))      AS dist,
           degrees(atan2(b.lng - m.clng, b.lat - m.clat))                 AS ang
    FROM base b JOIN muni m USING (municipality)
  ),
  thr AS (
    SELECT municipality,
           percentile_cont(0.30) WITHIN GROUP (ORDER BY dist) AS centro_thr
    FROM withpos GROUP BY municipality
  ),
  zoned AS (
    SELECT w.*,
      CASE
        WHEN w.n <= 100              THEN 'Única'
        WHEN w.dist <= t.centro_thr  THEN 'Centro'
        ELSE (CASE
          WHEN (((w.ang)::int % 360 + 360) % 360) >= 315
            OR (((w.ang)::int % 360 + 360) % 360) <  45  THEN 'Norte'
          WHEN (((w.ang)::int % 360 + 360) % 360) <  135 THEN 'Oriente'
          WHEN (((w.ang)::int % 360 + 360) % 360) <  225 THEN 'Sur'
          ELSE 'Poniente'
        END)
      END AS zone
    FROM withpos w JOIN thr t USING (municipality)
  ),
  candidates AS (
    SELECT id, municipality, zone, 'fav'      AS badge, favs::numeric AS metric_value FROM zoned WHERE favs   > 0
    UNION ALL
    SELECT id, municipality, zone, 'visited'  AS badge, visits::numeric              FROM zoned WHERE visits > 0
    UNION ALL
    SELECT id, municipality, zone, 'rating'   AS badge,
           (COALESCE(google_rating,0) + LEAST(COALESCE(google_reviews,0),99999)::numeric/1000000) FROM zoned WHERE google_rating IS NOT NULL
    UNION ALL
    SELECT id, municipality, zone, 'trending' AS badge, trending::numeric            FROM zoned WHERE trending > 0
    UNION ALL
    SELECT id, municipality, zone, 'promos'   AS badge, promos::numeric              FROM zoned WHERE promos > 0
  ),
  ranked AS (
    SELECT id, municipality, zone, badge, metric_value,
           ROW_NUMBER() OVER (PARTITION BY municipality, zone, badge
                              ORDER BY metric_value DESC) AS rnk
    FROM candidates
  )
  INSERT INTO public.establishment_badges
        (establishment_id, badge, municipality, zone, rank, metric_value)
  SELECT id, badge, municipality, zone, rnk, metric_value
  FROM ranked WHERE rnk <= 3;

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;
