-- ════════════════════════════════════════════════════════════════════════════
-- Fase 1 — "Mi audiencia" (dueño): demografía (edad/género) de
--   • favoritos del establecimiento
--   • favoritos de las promos del establecimiento
--   • clientes recurrentes (programa de lealtad)
--
-- Privacidad: si un grupo tiene menos de 5 personas, NO se devuelve la
-- demografía (solo el conteo) para no poder identificar individuos.
-- ════════════════════════════════════════════════════════════════════════════

-- Helper interno: demografía agregada de un conjunto de usuarios.
CREATE OR REPLACE FUNCTION public._audience_demographics(p_user_ids uuid[])
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_count int;
  v_res   jsonb;
BEGIN
  SELECT count(*) INTO v_count FROM profiles WHERE id = ANY(p_user_ids);

  IF v_count < 5 THEN
    RETURN jsonb_build_object('count', v_count, 'enough', false);
  END IF;

  WITH ppl AS (
    SELECT gender,
           EXTRACT(YEAR FROM age(birth_date))::int AS edad
    FROM profiles
    WHERE id = ANY(p_user_ids)
  )
  SELECT jsonb_build_object(
    'count',   v_count,
    'enough',  true,
    'avg_age', (SELECT round(avg(edad)) FROM ppl WHERE edad IS NOT NULL),
    'gender', jsonb_build_object(
      'male',    (SELECT count(*) FROM ppl WHERE gender = 'male'),
      'female',  (SELECT count(*) FROM ppl WHERE gender = 'female'),
      'unknown', (SELECT count(*) FROM ppl WHERE gender IS DISTINCT FROM 'male'
                                            AND gender IS DISTINCT FROM 'female')
    ),
    'age_buckets', jsonb_build_object(
      '18-24',   (SELECT count(*) FROM ppl WHERE edad BETWEEN 18 AND 24),
      '25-34',   (SELECT count(*) FROM ppl WHERE edad BETWEEN 25 AND 34),
      '35-44',   (SELECT count(*) FROM ppl WHERE edad BETWEEN 35 AND 44),
      '45-54',   (SELECT count(*) FROM ppl WHERE edad BETWEEN 45 AND 54),
      '55+',     (SELECT count(*) FROM ppl WHERE edad >= 55),
      'unknown', (SELECT count(*) FROM ppl WHERE edad IS NULL)
    )
  ) INTO v_res;

  RETURN v_res;
END;
$$;

-- El helper NO debe ser llamable directamente desde el cliente (evita pasar
-- IDs arbitrarios). Solo lo usa get_owner_audience_stats.
REVOKE ALL ON FUNCTION public._audience_demographics(uuid[]) FROM anon, authenticated;

-- ─── RPC principal: audiencia del dueño ──────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_owner_audience_stats(p_establishment_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_caller uuid := auth.uid();
  v_est    uuid[];
  v_promo  uuid[];
  v_loyal  uuid[];
BEGIN
  -- Solo el dueño del establecimiento.
  IF NOT EXISTS (
    SELECT 1 FROM establishments
    WHERE id = p_establishment_id AND owner_id = v_caller
  ) THEN
    RETURN jsonb_build_object('error', 'unauthorized');
  END IF;

  -- Favoritos del establecimiento
  SELECT array_agg(DISTINCT user_id) INTO v_est
  FROM user_favorite_establishments
  WHERE establishment_id = p_establishment_id;

  -- Favoritos de las promos del establecimiento
  SELECT array_agg(DISTINCT ufp.user_id) INTO v_promo
  FROM user_favorite_promotions ufp
  JOIN promotions p ON p.id = ufp.promotion_id
  WHERE p.establishment_id = p_establishment_id;

  -- Clientes recurrentes (tarjetas de lealtad del establecimiento)
  SELECT array_agg(DISTINCT sc.user_id) INTO v_loyal
  FROM stamp_cards sc
  JOIN loyalty_programs lp ON lp.id = sc.program_id
  WHERE lp.establishment_id = p_establishment_id;

  RETURN jsonb_build_object(
    'establishment_favorites', _audience_demographics(COALESCE(v_est,   '{}'::uuid[])),
    'promo_favorites',         _audience_demographics(COALESCE(v_promo, '{}'::uuid[])),
    'loyalty',                 _audience_demographics(COALESCE(v_loyal, '{}'::uuid[]))
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_owner_audience_stats(uuid) TO authenticated;
