-- ─────────────────────────────────────────────────────────────────────────────
-- Fuente de verdad para "¿el usuario actual es admin de la plataforma?"
--
-- El admin real tiene role = 'admin' + is_superadmin = true (no 'superadmin').
-- Distintas tablas checaban distintas cosas (role='superadmin', role='admin',
-- is_superadmin). Esta función unifica el criterio: úsala en TODAS las políticas
-- de admin → un solo lugar que mantener.
--
-- SECURITY DEFINER: lee profiles sin chocar con el RLS de profiles (evita recursión).
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.is_platform_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid()
      AND (COALESCE(is_superadmin, false) = true OR role IN ('admin', 'superadmin'))
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_platform_admin() TO authenticated;
