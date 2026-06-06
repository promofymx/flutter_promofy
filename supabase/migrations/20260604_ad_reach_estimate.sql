-- ─────────────────────────────────────────────────────────────────────────────
-- Fix: "Audiencia con estos filtros" mostraba 0 personas.
--
-- Causa: la app contaba la audiencia consultando public.profiles DIRECTO desde la
-- sesión del dueño. Por RLS, un dueño solo puede leer su propio perfil → COUNT = 0.
--
-- Solución: RPC SECURITY DEFINER que cuenta del lado del servidor (bypassa RLS),
-- replicando exactamente el filtro de edad/género que usaba el cliente.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.get_ad_reach_estimate(
  p_min_age int,
  p_max_age int,
  p_gender  text DEFAULT 'all'   -- 'all' | 'male' | 'female'
)
RETURNS int
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COUNT(*)::int
  FROM   public.profiles
  WHERE  birth_date IS NOT NULL
    AND  birth_date >= (current_date - make_interval(years => p_max_age))
    AND  birth_date <= (current_date - make_interval(years => p_min_age))
    AND  (p_gender = 'all' OR gender::text = p_gender);
$$;

-- Solo usuarios autenticados pueden estimar audiencia.
REVOKE ALL     ON FUNCTION public.get_ad_reach_estimate(int, int, text) FROM public;
GRANT  EXECUTE ON FUNCTION public.get_ad_reach_estimate(int, int, text) TO authenticated;
