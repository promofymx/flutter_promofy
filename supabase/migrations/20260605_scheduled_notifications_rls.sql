-- ─────────────────────────────────────────────────────────────────────────────
-- Fix: "new row violates row-level security policy for table scheduled_notifications"
--
-- La tabla scheduled_notifications tenía RLS activo pero SIN política que dejara
-- al superadmin insertar/leer. Además el admin real tiene role = 'admin' +
-- is_superadmin = true (no role = 'superadmin'), así que la política debe
-- reconocer ambas señales.
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE public.scheduled_notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "superadmin_manage_scheduled" ON public.scheduled_notifications;

CREATE POLICY "superadmin_manage_scheduled" ON public.scheduled_notifications
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid()
        AND (COALESCE(p.is_superadmin, false) = true OR p.role IN ('admin','superadmin'))
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.profiles p
      WHERE p.id = auth.uid()
        AND (COALESCE(p.is_superadmin, false) = true OR p.role IN ('admin','superadmin'))
    )
  );
