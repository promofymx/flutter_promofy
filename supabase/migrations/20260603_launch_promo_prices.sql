-- ═══════════════════════════════════════════════════════════════════════
-- Precios de lanzamiento — precios escalonados (~50 % de descuento)
-- El crédito que recibe el suscriptor = precio ORIGINAL del plan
--
--  Mesa 1  $249 → $99   (regalo $249 en publicidad)
--  Mesa 2  $449 → $199  (regalo $449 en publicidad)
--  Mesa 3  $599 → $299  (regalo $599 en publicidad)
--  Mesa 4  $899 → $449  (regalo $899 en publicidad)
-- ═══════════════════════════════════════════════════════════════════════

-- ─── 1. Guardar precio original antes de modificarlo ────────────────────
ALTER TABLE public.membership_plans
  ADD COLUMN IF NOT EXISTS original_price_mxn numeric(10,2);

-- Copia el precio actual como "original" en planes que aún no lo tienen
UPDATE public.membership_plans
SET    original_price_mxn = price_mxn
WHERE  original_price_mxn IS NULL
  AND  price_mxn > 0;

-- ─── 2. Precios de lanzamiento escalonados ──────────────────────────────
UPDATE public.membership_plans SET price_mxn =  99 WHERE original_price_mxn = 249;
UPDATE public.membership_plans SET price_mxn = 199 WHERE original_price_mxn = 449;
UPDATE public.membership_plans SET price_mxn = 299 WHERE original_price_mxn = 599;
UPDATE public.membership_plans SET price_mxn = 449 WHERE original_price_mxn = 899;

-- ─── 3. Trigger: el crédito se basa en el precio ORIGINAL ───────────────
-- (no en el precio de lanzamiento que realmente paga el usuario)
CREATE OR REPLACE FUNCTION public.award_launch_promo_credit()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_promo  public.launch_promos%ROWTYPE;
  v_plan   public.membership_plans%ROWTYPE;
  v_amount numeric(10,2);
BEGIN
  IF NEW.status <> 'authorized' THEN RETURN NEW; END IF;
  IF OLD IS NOT NULL AND OLD.status = 'authorized' THEN RETURN NEW; END IF;

  SELECT * INTO v_promo
  FROM   public.launch_promos
  WHERE  now() < ends_at
  ORDER  BY ends_at ASC
  LIMIT  1;
  IF NOT FOUND THEN RETURN NEW; END IF;

  IF EXISTS (
    SELECT 1 FROM public.promo_credit_log
    WHERE  subscription_id = NEW.id AND promo_id = v_promo.id
  ) THEN RETURN NEW; END IF;

  SELECT * INTO v_plan FROM public.membership_plans WHERE id = NEW.plan_id;
  IF NOT FOUND THEN RETURN NEW; END IF;

  -- Usa el precio original para el crédito; si no existe, usa price_mxn
  v_amount := ROUND(
    COALESCE(v_plan.original_price_mxn, v_plan.price_mxn)
    * v_promo.credit_pct / 100.0,
    2
  );

  UPDATE public.profiles
  SET    ad_credits_mxn = ad_credits_mxn + v_amount
  WHERE  id = NEW.user_id;

  INSERT INTO public.promo_credit_log (subscription_id, promo_id, user_id, amount_mxn)
  VALUES (NEW.id, v_promo.id, NEW.user_id, v_amount);

  RETURN NEW;
END;
$$;
