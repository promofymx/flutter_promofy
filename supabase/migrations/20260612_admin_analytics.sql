-- ════════════════════════════════════════════════════════════════════════════
-- Fase 2 — Analítica de superadmin:
--   • Demografía (edad/género) de descargas (todas las cuentas) y de activos.
--   • Tipos de establecimiento (categoría) con más favoritos y más visitados.
--   • Drill-down: establecimientos que componen un tipo.
-- Reusa el helper _audience_demographics. Solo superadmin (is_platform_admin()).
-- ════════════════════════════════════════════════════════════════════════════

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

  -- Descargas = todas las cuentas
  SELECT array_agg(id) INTO v_all FROM profiles;

  -- Activos = con canje o visita de lealtad en los últimos 30 días
  SELECT array_agg(DISTINCT uid) INTO v_active FROM (
    SELECT user_id   AS uid FROM coupon_redemptions WHERE redeemed_at >= now() - interval '30 days'
    UNION
    SELECT client_id AS uid FROM loyalty_visit_log  WHERE created_at  >= now() - interval '30 days'
  ) a;

  -- Tipos (categoría) con más favoritos
  SELECT coalesce(jsonb_agg(jsonb_build_object('id', cid, 'name', cname, 'count', cnt)
                            ORDER BY cnt DESC), '[]'::jsonb)
  INTO v_favs FROM (
    SELECT c.id AS cid, c.name AS cname, count(*) AS cnt
    FROM user_favorite_establishments ufe
    JOIN establishments e ON e.id = ufe.establishment_id
    JOIN categories      c ON c.id = e.category_id
    GROUP BY c.id, c.name
  ) t;

  -- Tipos más visitados (programa de lealtad)
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

GRANT EXECUTE ON FUNCTION public.get_admin_analytics() TO authenticated;

-- ─── Drill-down: establecimientos de un tipo (categoría) ──────────────────────
CREATE OR REPLACE FUNCTION public.get_admin_type_establishments(
  p_category_id int,
  p_metric      text   -- 'favorites' | 'visits'
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE v_res jsonb;
BEGIN
  IF NOT is_platform_admin() THEN
    RETURN jsonb_build_object('error', 'unauthorized');
  END IF;

  IF p_metric = 'visits' THEN
    SELECT coalesce(jsonb_agg(jsonb_build_object('name', ename, 'count', cnt)
                              ORDER BY cnt DESC), '[]'::jsonb)
    INTO v_res FROM (
      SELECT e.name AS ename, count(*) AS cnt
      FROM loyalty_visit_log lvl
      JOIN establishments e ON e.id = lvl.establishment_id
      WHERE e.category_id = p_category_id
      GROUP BY e.id, e.name
    ) t;
  ELSE
    SELECT coalesce(jsonb_agg(jsonb_build_object('name', ename, 'count', cnt)
                              ORDER BY cnt DESC), '[]'::jsonb)
    INTO v_res FROM (
      SELECT e.name AS ename, count(*) AS cnt
      FROM user_favorite_establishments ufe
      JOIN establishments e ON e.id = ufe.establishment_id
      WHERE e.category_id = p_category_id
      GROUP BY e.id, e.name
    ) t;
  END IF;

  RETURN jsonb_build_object('items', v_res);
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_admin_type_establishments(int, text) TO authenticated;
