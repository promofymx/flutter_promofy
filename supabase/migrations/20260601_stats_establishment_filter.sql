-- ═══════════════════════════════════════════════════════════════════════════════
-- PROMOFY · Stats por establecimiento (fix gerente vs dueño)
-- Ejecutar en el SQL Editor de Supabase
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- ANTES DE EJECUTAR:
-- Si tu función actual tiene un body diferente, primero ve a
--   Database → Functions → get_business_stats → Definition
-- y copia el body existente. Solo necesitas AÑADIR el parámetro
-- p_establishment_id y el bloque de lógica marcado con "── NUEVO ──".
--
-- Si no tienes acceso al editor visual, corre:
--   SELECT prosrc FROM pg_proc WHERE proname = 'get_business_stats';
-- para ver el body actual antes de reemplazar.
-- ═══════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.get_business_stats(
  p_owner_id         UUID    DEFAULT NULL,
  p_establishment_id UUID    DEFAULT NULL,   -- ── NUEVO ── (gerente)
  p_days             INT     DEFAULT 30
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_since    TIMESTAMPTZ := now() - (p_days || ' days')::INTERVAL;
  v_est_ids  UUID[];
BEGIN
  -- ── Determinar establecimientos a incluir ───────────────────────────────
  IF p_establishment_id IS NOT NULL THEN
    -- Gerente: solo su establecimiento
    v_est_ids := ARRAY[p_establishment_id];
  ELSIF p_owner_id IS NOT NULL THEN
    -- Dueño: todos sus establecimientos
    SELECT ARRAY_AGG(id) INTO v_est_ids
    FROM public.establishments
    WHERE owner_id = p_owner_id;
  ELSE
    RETURN '{}'::JSON;
  END IF;

  IF v_est_ids IS NULL OR array_length(v_est_ids, 1) = 0 THEN
    RETURN json_build_object(
      'establishment_views', 0,
      'promo_stats',         '[]'::JSON,
      'contact_clicks',      '[]'::JSON,
      'loyalty_visits',      0,
      'avg_ticket',          NULL,
      'total_revenue',       NULL
    );
  END IF;

  -- ── Resultado ───────────────────────────────────────────────────────────
  RETURN json_build_object(

    -- Vistas al perfil del establecimiento
    'establishment_views', (
      SELECT COUNT(*)
      FROM   public.establishment_view_logs evl
      WHERE  evl.establishment_id = ANY(v_est_ids)
        AND  evl.viewed_at >= v_since
    ),

    -- Top promos: vistas + favoritos
    'promo_stats', (
      SELECT COALESCE(json_agg(ps ORDER BY ps.views DESC), '[]'::JSON)
      FROM (
        SELECT
          p.id                        AS promo_id,
          p.name                      AS promo_name,
          COUNT(DISTINCT pvl.id)      AS views,
          COUNT(DISTINCT ufp.user_id) AS total_favs,
          COUNT(DISTINCT ufp.user_id)
            FILTER (WHERE ufp.created_at >= v_since) AS new_favs
        FROM   public.promotions p
        LEFT JOIN public.promo_view_logs pvl
               ON pvl.promo_id = p.id
              AND pvl.viewed_at >= v_since
        LEFT JOIN public.user_favorite_promotions ufp
               ON ufp.promotion_id = p.id
        WHERE  p.establishment_id = ANY(v_est_ids)
        GROUP  BY p.id, p.name
        LIMIT  10
      ) ps
    ),

    -- Clics de contacto por tipo
    'contact_clicks', (
      SELECT COALESCE(json_agg(cc ORDER BY cc.count DESC), '[]'::JSON)
      FROM (
        SELECT
          click_type  AS type,
          COUNT(*)    AS count
        FROM   public.contact_click_logs ccl
        WHERE  ccl.establishment_id = ANY(v_est_ids)
          AND  ccl.clicked_at >= v_since
        GROUP  BY click_type
      ) cc
    ),

    -- Visitas de lealtad
    'loyalty_visits', (
      SELECT COUNT(*)
      FROM   public.loyalty_visit_logs lvl
      JOIN   public.loyalty_programs lp ON lp.id = lvl.program_id
      WHERE  lp.establishment_id = ANY(v_est_ids)
        AND  lvl.visited_at >= v_since
    ),

    -- Ticket promedio
    'avg_ticket', (
      SELECT AVG(lvl.ticket_amount)
      FROM   public.loyalty_visit_logs lvl
      JOIN   public.loyalty_programs lp ON lp.id = lvl.program_id
      WHERE  lp.establishment_id = ANY(v_est_ids)
        AND  lvl.visited_at >= v_since
        AND  lvl.ticket_amount IS NOT NULL
    ),

    -- Ingresos totales
    'total_revenue', (
      SELECT SUM(lvl.ticket_amount)
      FROM   public.loyalty_visit_logs lvl
      JOIN   public.loyalty_programs lp ON lp.id = lvl.program_id
      WHERE  lp.establishment_id = ANY(v_est_ids)
        AND  lvl.visited_at >= v_since
        AND  lvl.ticket_amount IS NOT NULL
    )
  );
END;
$$;

-- Permisos
GRANT EXECUTE ON FUNCTION public.get_business_stats(UUID, UUID, INT)
  TO authenticated, service_role;
