-- ─────────────────────────────────────────────────────────────────────────────
-- Alinea las políticas de admin a UNA sola fuente de verdad: is_platform_admin()
--
-- Problema: las tablas de publicidad y categorías checaban
--   ((auth.jwt() -> 'app_metadata') ->> 'role') = 'admin'
-- es decir, el rol en el TOKEN (app_metadata), que el admin real no tiene.
-- El resto de tablas ya usaban profiles.is_superadmin. Aquí unificamos las de
-- publicidad/categorías a is_platform_admin() (que lee profiles), conservando
-- intactas las condiciones de dueño/staff.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.is_platform_admin()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid()
      AND (COALESCE(is_superadmin, false) = true OR role IN ('admin', 'superadmin'))
  );
$$;
GRANT EXECUTE ON FUNCTION public.is_platform_admin() TO authenticated;

-- ===== ad_campaigns =====
DROP POLICY IF EXISTS ad_campaigns_select ON public.ad_campaigns;
CREATE POLICY ad_campaigns_select ON public.ad_campaigns FOR SELECT TO public
USING (
  public.is_platform_admin()
  OR establishment_id IN (SELECT id FROM public.establishments WHERE owner_id = auth.uid())
  OR establishment_id IN (SELECT establishment_id FROM public.ad_staff_permissions
                          WHERE staff_user_id = auth.uid() AND can_manage_campaigns = true)
);

DROP POLICY IF EXISTS ad_campaigns_write ON public.ad_campaigns;
CREATE POLICY ad_campaigns_write ON public.ad_campaigns FOR ALL TO public
USING (
  public.is_platform_admin()
  OR establishment_id IN (SELECT id FROM public.establishments WHERE owner_id = auth.uid())
  OR establishment_id IN (SELECT establishment_id FROM public.ad_staff_permissions
                          WHERE staff_user_id = auth.uid() AND can_manage_campaigns = true)
)
WITH CHECK (
  public.is_platform_admin()
  OR establishment_id IN (SELECT id FROM public.establishments WHERE owner_id = auth.uid())
  OR establishment_id IN (SELECT establishment_id FROM public.ad_staff_permissions
                          WHERE staff_user_id = auth.uid() AND can_manage_campaigns = true)
);

-- ===== ad_credit_txns =====
DROP POLICY IF EXISTS ad_credit_txns_insert ON public.ad_credit_txns;
CREATE POLICY ad_credit_txns_insert ON public.ad_credit_txns FOR INSERT TO public
WITH CHECK (
  public.is_platform_admin()
  OR establishment_id IN (SELECT id FROM public.establishments WHERE owner_id = auth.uid())
  OR establishment_id IN (SELECT establishment_id FROM public.ad_staff_permissions
                          WHERE staff_user_id = auth.uid() AND can_add_credit = true)
);

DROP POLICY IF EXISTS ad_credit_txns_read ON public.ad_credit_txns;
CREATE POLICY ad_credit_txns_read ON public.ad_credit_txns FOR SELECT TO public
USING (
  public.is_platform_admin()
  OR establishment_id IN (SELECT id FROM public.establishments WHERE owner_id = auth.uid())
  OR establishment_id IN (SELECT establishment_id FROM public.ad_staff_permissions
                          WHERE staff_user_id = auth.uid() AND can_add_credit = true)
);

-- ===== ad_credits =====
DROP POLICY IF EXISTS ad_credits_admin ON public.ad_credits;
CREATE POLICY ad_credits_admin ON public.ad_credits FOR ALL TO public
USING (public.is_platform_admin()) WITH CHECK (public.is_platform_admin());

DROP POLICY IF EXISTS ad_credits_read ON public.ad_credits;
CREATE POLICY ad_credits_read ON public.ad_credits FOR SELECT TO public
USING (
  public.is_platform_admin()
  OR establishment_id IN (SELECT id FROM public.establishments WHERE owner_id = auth.uid())
);

-- ===== ad_pricing =====
DROP POLICY IF EXISTS ad_pricing_admin ON public.ad_pricing;
CREATE POLICY ad_pricing_admin ON public.ad_pricing FOR ALL TO public
USING (public.is_platform_admin()) WITH CHECK (public.is_platform_admin());

-- ===== ad_staff_permissions =====
DROP POLICY IF EXISTS ad_staff_perms_all ON public.ad_staff_permissions;
CREATE POLICY ad_staff_perms_all ON public.ad_staff_permissions FOR ALL TO public
USING (
  public.is_platform_admin()
  OR establishment_id IN (SELECT id FROM public.establishments WHERE owner_id = auth.uid())
)
WITH CHECK (
  public.is_platform_admin()
  OR establishment_id IN (SELECT id FROM public.establishments WHERE owner_id = auth.uid())
);

-- ===== categories =====
DROP POLICY IF EXISTS categories_delete_admin ON public.categories;
CREATE POLICY categories_delete_admin ON public.categories FOR DELETE TO authenticated
USING (public.is_platform_admin());

DROP POLICY IF EXISTS categories_insert_admin ON public.categories;
CREATE POLICY categories_insert_admin ON public.categories FOR INSERT TO authenticated
WITH CHECK (public.is_platform_admin());

DROP POLICY IF EXISTS categories_update_admin ON public.categories;
CREATE POLICY categories_update_admin ON public.categories FOR UPDATE TO authenticated
USING (public.is_platform_admin()) WITH CHECK (public.is_platform_admin());
