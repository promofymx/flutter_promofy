-- In-App Purchase de Apple (suscripciones auto-renovables) — solo iOS.
-- Mapea cada plan a su product_id de App Store y prepara user_subscriptions
-- para distinguir la tienda (mercadopago | apple) y guardar los ids de Apple.

-- ── Mapeo plan → product_id de App Store ─────────────────────────────────────
ALTER TABLE public.membership_plans
  ADD COLUMN IF NOT EXISTS apple_product_id text;

UPDATE public.membership_plans SET apple_product_id = 'mx.promofy.app.plan.1local.monthly'  WHERE id = 1;
UPDATE public.membership_plans SET apple_product_id = 'mx.promofy.app.plan.2locales.monthly' WHERE id = 2;
UPDATE public.membership_plans SET apple_product_id = 'mx.promofy.app.plan.3locales.monthly' WHERE id = 3;
UPDATE public.membership_plans SET apple_product_id = 'mx.promofy.app.plan.5locales.monthly' WHERE id = 4;

-- ── Campos de Apple en user_subscriptions ────────────────────────────────────
ALTER TABLE public.user_subscriptions
  ADD COLUMN IF NOT EXISTS store                         text NOT NULL DEFAULT 'mercadopago',
  ADD COLUMN IF NOT EXISTS apple_product_id              text,
  ADD COLUMN IF NOT EXISTS apple_original_transaction_id text,
  ADD COLUMN IF NOT EXISTS apple_transaction_id          text,
  ADD COLUMN IF NOT EXISTS environment                   text;   -- Sandbox | Production

-- Una suscripción por original_transaction_id de Apple (idempotencia + upsert).
CREATE UNIQUE INDEX IF NOT EXISTS uniq_user_sub_apple_orig_txn
  ON public.user_subscriptions(apple_original_transaction_id)
  WHERE apple_original_transaction_id IS NOT NULL;

-- Resolver plan por product_id de Apple (lo usa la edge function de verificación).
CREATE OR REPLACE FUNCTION public.plan_id_for_apple_product(p_product_id text)
RETURNS int
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT id FROM public.membership_plans WHERE apple_product_id = p_product_id LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION public.plan_id_for_apple_product(text) TO service_role, authenticated;
