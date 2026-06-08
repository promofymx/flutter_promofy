-- ═══════════════════════════════════════════════════════════════════
-- RLS: el superadmin gestiona los códigos de descuento desde el panel web.
-- ═══════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "superadmin_all_discount_codes" ON public.discount_codes;
CREATE POLICY "superadmin_all_discount_codes" ON public.discount_codes
  FOR ALL TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.id = auth.uid() AND p.is_superadmin
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.id = auth.uid() AND p.is_superadmin
  ));

DROP POLICY IF EXISTS "superadmin_read_redemptions" ON public.discount_code_redemptions;
CREATE POLICY "superadmin_read_redemptions" ON public.discount_code_redemptions
  FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.profiles p
    WHERE p.id = auth.uid() AND p.is_superadmin
  ));
