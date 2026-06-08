-- ═══════════════════════════════════════════════════════════════════
-- Códigos de descuento para suscripciones (negociación con negocios)
-- Soporta: porcentaje, monto fijo y meses gratis.
-- El descuento se aplica en el cobro recurrente (permanente) salvo
-- 'free_months', que usa free_trial de MercadoPago (N meses gratis).
-- ═══════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.discount_codes (
  id                  uuid          PRIMARY KEY DEFAULT gen_random_uuid(),
  code                text          NOT NULL UNIQUE,
  description         text,
  -- 'percent'  → discount_value = % (ej. 30 = 30%)
  -- 'fixed'    → discount_value = MXN a restar del precio mensual
  -- 'free_months' → discount_value = número de meses gratis (free_trial)
  discount_type       text          NOT NULL
                        CHECK (discount_type IN ('percent','fixed','free_months')),
  discount_value      numeric(10,2) NOT NULL CHECK (discount_value > 0),
  -- null = aplica a todos los planes
  applies_to_plan_id  int           REFERENCES public.membership_plans(id) ON DELETE CASCADE,
  -- null = usos ilimitados
  max_uses            int           CHECK (max_uses IS NULL OR max_uses > 0),
  used_count          int           NOT NULL DEFAULT 0,
  -- null = sin vencimiento
  expires_at          timestamptz,
  is_active           boolean       NOT NULL DEFAULT true,
  created_at          timestamptz   NOT NULL DEFAULT now()
);

-- Normalizar el código a MAYÚSCULAS al guardar.
CREATE OR REPLACE FUNCTION public.normalize_discount_code()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.code := UPPER(TRIM(NEW.code));
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trig_normalize_discount_code ON public.discount_codes;
CREATE TRIGGER trig_normalize_discount_code
  BEFORE INSERT OR UPDATE ON public.discount_codes
  FOR EACH ROW EXECUTE FUNCTION public.normalize_discount_code();

-- ─── Canjes (un usuario usa cada código una sola vez) ───────────────
CREATE TABLE IF NOT EXISTS public.discount_code_redemptions (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  code_id         uuid        NOT NULL REFERENCES public.discount_codes(id) ON DELETE CASCADE,
  user_id         uuid        NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  subscription_id uuid        REFERENCES public.user_subscriptions(id) ON DELETE SET NULL,
  redeemed_at     timestamptz NOT NULL DEFAULT now(),
  UNIQUE (code_id, user_id)
);

ALTER TABLE public.discount_codes            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.discount_code_redemptions ENABLE ROW LEVEL SECURITY;

-- Sin políticas de lectura pública: la validación/aplicación se hace con
-- service_role en la Edge Function. (Superadmin gestiona vía service_role.)

-- ─── RPC para PREVISUALIZAR el descuento en la app (sin canjear) ─────
-- Devuelve json: { ok, reason, type, value, original_price, final_price, free_months }
CREATE OR REPLACE FUNCTION public.preview_discount_code(p_code text, p_plan_id int)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_code  text := UPPER(TRIM(COALESCE(p_code, '')));
  v_dc    public.discount_codes%ROWTYPE;
  v_price numeric(10,2);
  v_final numeric(10,2);
  v_free  int := 0;
BEGIN
  IF auth.uid() IS NULL THEN
    RETURN json_build_object('ok', false, 'reason', 'unauthenticated');
  END IF;
  IF v_code = '' THEN
    RETURN json_build_object('ok', false, 'reason', 'empty');
  END IF;

  SELECT price_mxn INTO v_price
  FROM public.membership_plans WHERE id = p_plan_id AND is_active = true;
  IF v_price IS NULL THEN
    RETURN json_build_object('ok', false, 'reason', 'plan_not_found');
  END IF;

  SELECT * INTO v_dc FROM public.discount_codes WHERE code = v_code;

  IF v_dc.id IS NULL OR NOT v_dc.is_active THEN
    RETURN json_build_object('ok', false, 'reason', 'not_found');
  END IF;
  IF v_dc.expires_at IS NOT NULL AND v_dc.expires_at < now() THEN
    RETURN json_build_object('ok', false, 'reason', 'expired');
  END IF;
  IF v_dc.max_uses IS NOT NULL AND v_dc.used_count >= v_dc.max_uses THEN
    RETURN json_build_object('ok', false, 'reason', 'exhausted');
  END IF;
  IF v_dc.applies_to_plan_id IS NOT NULL AND v_dc.applies_to_plan_id <> p_plan_id THEN
    RETURN json_build_object('ok', false, 'reason', 'wrong_plan');
  END IF;
  IF EXISTS (SELECT 1 FROM public.discount_code_redemptions
             WHERE code_id = v_dc.id AND user_id = auth.uid()) THEN
    RETURN json_build_object('ok', false, 'reason', 'already_used');
  END IF;

  -- Calcular precio final
  v_final := v_price;
  IF v_dc.discount_type = 'percent' THEN
    v_final := ROUND(v_price * (1 - LEAST(v_dc.discount_value, 100) / 100.0), 2);
  ELSIF v_dc.discount_type = 'fixed' THEN
    v_final := GREATEST(v_price - v_dc.discount_value, 0);
  ELSIF v_dc.discount_type = 'free_months' THEN
    v_free  := v_dc.discount_value::int;  -- precio normal, pero con meses gratis
  END IF;

  RETURN json_build_object(
    'ok',             true,
    'reason',         'ok',
    'type',           v_dc.discount_type,
    'value',          v_dc.discount_value,
    'original_price', v_price,
    'final_price',    v_final,
    'free_months',    v_free,
    'description',    COALESCE(v_dc.description, '')
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.preview_discount_code(text, int) TO authenticated;
