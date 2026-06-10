-- Fix definitivo de get_ads_for_user: la tabla establishments NO tiene columnas
-- photo_url, lat ni lng (usa location PostGIS + logo_url). Esto rompía la
-- función desde su creación → los anuncios nunca se mostraban.
--   • photo_url (cover del negocio): no existe → NULL (el logo cubre el anuncio
--     de establecimiento; la foto de la promo cubre el de promoción).
--   • lat/lng → ST_Y/ST_X de location.

CREATE OR REPLACE FUNCTION public.get_ads_for_user(
  p_lat    float8 DEFAULT NULL,
  p_lng    float8 DEFAULT NULL,
  p_format text   DEFAULT NULL,
  p_limit  int    DEFAULT 5
)
RETURNS TABLE (
  id                  uuid,
  establishment_id    uuid,
  format              text,
  establishment_name  text,
  photo_url           text,
  logo_url            text,
  promotion_id        uuid,
  promotion_name      text,
  promotion_photo_url text,
  score               float8
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id uuid := auth.uid();
BEGIN
  RETURN QUERY
  WITH
  user_cats AS (
    SELECT unnest(COALESCE(p.favorite_category_ids, '{}'::int[])) AS cat_id
    FROM   profiles p
    WHERE  p.id = v_user_id
  ),
  candidates AS (
    SELECT
      c.id,
      c.establishment_id,
      c.format,
      c.radius_km,
      c.target_category_ids,
      c.budget_mxn - c.spent_mxn        AS remaining_budget,
      e.name                             AS establishment_name,
      NULL::text                         AS photo_url,
      e.logo_url,
      ST_Y(e.location::geometry)         AS est_lat,
      ST_X(e.location::geometry)         AS est_lng,
      COALESCE(ac.balance_mxn, 0)        AS balance_mxn,
      c.promotion_id,
      pr.name                            AS promotion_name,
      pr.photo_url                       AS promotion_photo_url
    FROM   ad_campaigns c
    JOIN   establishments e   ON e.id  = c.establishment_id
    LEFT JOIN promotions  pr  ON pr.id = c.promotion_id
    LEFT JOIN ad_credits  ac  ON ac.establishment_id = c.establishment_id
    JOIN   ad_pricing     ap  ON ap.format = c.format
    WHERE  c.status = 'active'
      AND  (p_format IS NULL OR c.format = p_format)
      AND  (c.start_date IS NULL OR c.start_date <= current_date)
      AND  (c.end_date   IS NULL OR c.end_date   >= current_date)
      AND  COALESCE(ac.balance_mxn, 0) >= ap.price_mxn
  ),
  scored AS (
    SELECT
      cand.*,
      CASE
        WHEN p_lat IS NULL OR p_lng IS NULL
          OR cand.est_lat IS NULL OR cand.est_lng IS NULL
          THEN 50.0
        WHEN haversine_km(p_lat, p_lng, cand.est_lat, cand.est_lng) >= cand.radius_km
          THEN 0.0
        ELSE GREATEST(0.0,
          (1.0 - haversine_km(p_lat, p_lng, cand.est_lat, cand.est_lng)
                 / cand.radius_km) * 100.0)
      END AS dist_score,
      CASE
        WHEN array_length(cand.target_category_ids, 1) IS NULL
          THEN 50.0
        ELSE LEAST(100.0,
          (SELECT COUNT(*)::float8
           FROM   unnest(cand.target_category_ids) t(cat)
           WHERE  t.cat IN (SELECT cat_id FROM user_cats)
          ) / array_length(cand.target_category_ids, 1) * 100.0)
      END AS cat_score,
      CASE
        WHEN MAX(cand.balance_mxn) OVER () = 0 THEN 0.0
        ELSE cand.balance_mxn / MAX(cand.balance_mxn) OVER () * 100.0
      END AS credits_score
    FROM candidates cand
  )

  SELECT
    s.id,
    s.establishment_id,
    s.format,
    s.establishment_name,
    s.photo_url,
    s.logo_url,
    s.promotion_id,
    s.promotion_name,
    s.promotion_photo_url,
    ROUND((s.dist_score * 0.40 + s.cat_score * 0.35 + s.credits_score * 0.25)::numeric, 4)::float8
      AS score
  FROM scored s
  ORDER BY (s.dist_score * 0.40 + s.cat_score * 0.35 + s.credits_score * 0.25) DESC
  LIMIT p_limit;
END;
$$;
