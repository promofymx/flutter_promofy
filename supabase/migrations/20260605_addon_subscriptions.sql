-- ─────────────────────────────────────────────────────────────────────────────
-- Add-ons como SUSCRIPCIÓN mensual (recurrente) en vez de pago único.
-- Cada fila = 1 unidad de add-on (1 promo extra o 1 local extra), $X/mes.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.add_on_subscriptions (
  id                          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id                     uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  add_on_type                 text        NOT NULL
                                          CHECK (add_on_type IN ('extra_promotion','extra_establishment')),
  mp_preapproval_id           text,
  status                      text        NOT NULL DEFAULT 'pending'
                                          CHECK (status IN ('pending','authorized','paused','cancelled')),
  price_mxn                   numeric(10,2) NOT NULL,
  current_period_start        timestamptz,
  current_period_end          timestamptz,
  last_authorized_payment_id  text,
  created_at                  timestamptz NOT NULL DEFAULT now(),
  updated_at                  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_addon_subs_user ON public.add_on_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_addon_subs_preapproval ON public.add_on_subscriptions(mp_preapproval_id);

ALTER TABLE public.add_on_subscriptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "user_reads_own_addon_subs" ON public.add_on_subscriptions;
CREATE POLICY "user_reads_own_addon_subs" ON public.add_on_subscriptions
  FOR SELECT TO authenticated USING (user_id = auth.uid());

DROP POLICY IF EXISTS "admin_all_addon_subs" ON public.add_on_subscriptions;
CREATE POLICY "admin_all_addon_subs" ON public.add_on_subscriptions
  FOR ALL TO authenticated
  USING (public.is_platform_admin()) WITH CHECK (public.is_platform_admin());
-- El service_role (webhook) ignora RLS.

-- Cuántos add-ons ACTIVOS de un tipo tiene el usuario (para sumar al límite del plan).
CREATE OR REPLACE FUNCTION public.active_addon_count(p_user uuid, p_type text)
RETURNS int LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT COUNT(*)::int
  FROM   public.add_on_subscriptions
  WHERE  user_id = p_user
    AND  add_on_type = p_type
    AND  status = 'authorized'
    AND  (current_period_end IS NULL OR current_period_end > now());
$$;
GRANT EXECUTE ON FUNCTION public.active_addon_count(uuid, text) TO authenticated;
