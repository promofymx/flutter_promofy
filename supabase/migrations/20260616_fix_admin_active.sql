-- Fix: get_admin_analytics referenciaba coupon_redemptions (no existe).
-- "Activos" = usuarios con impresión/clic de anuncio o visita de lealtad en 30d.

CREATE OR REPLACE FUNCTION public.get_admin_analytics()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_all    uuid[];
  v_active uuid[];
  v_favs   jsonb;
  v_visits jsonb;
BEGIN
  IF NOT is_platform_admin() THEN
    RETURN jsonb_build_object('error', 'unauthorized');
  END IF;

  SELECT array_agg(id) INTO v_all FROM profiles;

  -- Activos en los últimos 30 días: impresion/clic de anuncio o visita de lealtad
  SELECT array_agg(DISTINCT uid) INTO v_active FROM (
    SELECT user_id   AS uid FROM ad_impressions
      WHERE created_at >= now() - interval '30 days' AND user_id IS NOT NULL
    UNION
    SELECT client_id AS uid FROM loyalty_visit_log
      WHERE created_at >= now() - interval '30 days'
  ) a;

  SELECT coalesce(jsonb_agg(jsonb_build_object('id', cid, 'name', cname, 'count', cnt)
                            ORDER BY cnt DESC), '[]'::jsonb)
  INTO v_favs FROM (
    SELECT c.id AS cid, c.name AS cname, count(*) AS cnt
    FROM user_favorite_establishments ufe
    JOIN establishments e ON e.id = ufe.establishment_id
    JOIN categories      c ON c.id = e.category_id
    GROUP BY c.id, c.name
  ) t;

  SELECT coalesce(jsonb_agg(jsonb_build_object('id', cid, 'name', cname, 'count', cnt)
                            ORDER BY cnt DESC), '[]'::jsonb)
  INTO v_visits FROM (
    SELECT c.id AS cid, c.name AS cname, count(*) AS cnt
    FROM loyalty_visit_log lvl
    JOIN establishments e ON e.id = lvl.establishment_id
    JOIN categories      c ON c.id = e.category_id
    GROUP BY c.id, c.name
  ) t;

  RETURN jsonb_build_object(
    'downloads',          _audience_demographics(COALESCE(v_all,    '{}'::uuid[])),
    'active',             _audience_demographics(COALESCE(v_active, '{}'::uuid[])),
    'types_by_favorites', v_favs,
    'types_by_visits',    v_visits
  );
END;
$$;
