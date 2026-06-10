-- ════════════════════════════════════════════════════════════════════════════
-- Fix CRÍTICO: get_ads_for_user referenciaba coupon_redemptions (tabla que NO
-- existe) → la función fallaba SIEMPRE → los anuncios nunca se mostraban.
-- Se reemplaza el CTE user_cats por las categorías favoritas del perfil
-- (profiles.favorite_category_ids), que sí existen. Resto idéntico.
-- ════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.get_ads_for_user(
  p_lat    float8 DEFAULT NULL,
  p_lng    float8 DEFAULT NULL,
  p_format text   DEFAULT NULL,
  p_limit  int    DEFAULT 5
)
RETURNS TABLE (
  id               uuid,
  establishment_id uuid,
  format           text,
  establishment_name text,
  photo_url        text,
  score            float8
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

  -- ── Categorías de interés del usuario (sus favoritas del perfil) ─────────
  user_cats AS (
    SELECT unnest(COALESCE(favorite_category_ids, '{}'::int[])) AS cat_id
    FROM   profiles
    WHERE  id = v_user_id
  ),

  -- ── Campañas candidatas (activas, con crédito, dentro de vigencia) ────────
  candidates AS (
    SELECT
      c.id,
      c.establishment_id,
      c.format,
      c.radius_km,
      c.target_category_ids,
      c.budget_mxn - c.spent_mxn  AS remaining_budget,
      e.name                       AS establishment_name,
      e.photo_url,
      e.lat                        AS est_lat,
      e.lng                        AS est_lng,
      COALESCE(ac.balance_mxn, 0)  AS balance_mxn
    FROM   ad_campaigns c
    JOIN   establishments e   ON e.id  = c.establishment_id
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
                 / cand.radius_km) * 100.0
        )
      END AS dist_score,
      CASE
        WHEN array_length(cand.target_category_ids, 1) IS NULL
          THEN 50.0
        ELSE LEAST(100.0,
          (SELECT COUNT(*)::float8
           FROM   unnest(cand.target_category_ids) t(cat)
           WHERE  t.cat IN (SELECT cat_id FROM user_cats)
          ) / array_length(cand.target_category_ids, 1) * 100.0
        )
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
    ROUND((s.dist_score * 0.40 + s.cat_score * 0.35 + s.credits_score * 0.25)::numeric, 4)::float8
      AS score
  FROM scored s
  ORDER BY (s.dist_score * 0.40 + s.cat_score * 0.35 + s.credits_score * 0.25) DESC
  LIMIT p_limit;
END;
$$;
