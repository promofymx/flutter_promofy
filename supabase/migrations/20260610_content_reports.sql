-- ════════════════════════════════════════════════════════════════════════════
-- Reportes de contenido (moderación) — requerido por App Store (regla 1.2):
-- el usuario puede reportar una promoción o un establecimiento inapropiado.
-- El superadmin revisa y actúa (eliminar contenido, etc.).
-- ════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.content_reports (
  id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id  uuid        REFERENCES auth.users(id) ON DELETE SET NULL,
  content_type text        NOT NULL CHECK (content_type IN ('promotion','establishment')),
  content_id   uuid        NOT NULL,
  reason       text        NOT NULL,
  note         text,
  status       text        NOT NULL DEFAULT 'pending'
                           CHECK (status IN ('pending','reviewed','dismissed')),
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_content_reports_status
  ON public.content_reports(status, created_at DESC);

ALTER TABLE public.content_reports ENABLE ROW LEVEL SECURITY;

-- Cualquier usuario autenticado puede crear un reporte (a su nombre)
CREATE POLICY "create_own_report" ON public.content_reports
  FOR INSERT TO authenticated
  WITH CHECK (reporter_id = auth.uid());

-- El reportante puede ver sus propios reportes
CREATE POLICY "read_own_report" ON public.content_reports
  FOR SELECT TO authenticated
  USING (reporter_id = auth.uid());

-- Superadmin: acceso total (revisar/moderar)
CREATE POLICY "superadmin_all_reports" ON public.content_reports
  FOR ALL TO authenticated
  USING   ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'superadmin')
  WITH CHECK ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'superadmin');
