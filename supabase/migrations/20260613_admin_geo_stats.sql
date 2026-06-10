-- ════════════════════════════════════════════════════════════════════════════
-- Fase 3 — Geo (superadmin): descargas por Estado + demografía por estado.
-- El estado viene de profiles.state (reverse geocoding al registrarse).
-- Solo is_platform_admin(). Reusa _audience_demographics para el drill-down.
-- ════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.get_admin_geo_stats()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_total  int;
  v_states jsonb;
BEGIN
  IF NOT is_platform_admin() THEN
    RETURN jsonb_build_object('error', 'unauthorized');
  END IF;

  SELECT count(*) INTO v_total FROM profiles;

  SELECT coalesce(jsonb_agg(jsonb_build_object('state', st, 'count', cnt)
                            ORDER BY cnt DESC), '[]'::jsonb)
  INTO v_states FROM (
    SELECT COALESCE(NULLIF(trim(state), ''), 'Sin ubicación') AS st, count(*) AS cnt
    FROM profiles
    GROUP BY COALESCE(NULLIF(trim(state), ''), 'Sin ubicación')
  ) t;

  RETURN jsonb_build_object(
    'country', 'México',
    'total',   v_total,
    'states',  v_states
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_admin_geo_stats() TO authenticated;

-- ─── Demografía de un estado (drill-down) ────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_admin_state_demographics(p_state text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE v_ids uuid[];
BEGIN
  IF NOT is_platform_admin() THEN
    RETURN jsonb_build_object('error', 'unauthorized');
  END IF;

  IF p_state = 'Sin ubicación' THEN
    SELECT array_agg(id) INTO v_ids
    FROM profiles WHERE NULLIF(trim(state), '') IS NULL;
  ELSE
    SELECT array_agg(id) INTO v_ids
    FROM profiles WHERE trim(state) = p_state;
  END IF;

  RETURN _audience_demographics(COALESCE(v_ids, '{}'::uuid[]));
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_admin_state_demographics(text) TO authenticated;
