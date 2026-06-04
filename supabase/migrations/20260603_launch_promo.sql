-- ═══════════════════════════════════════════════════════════════════════
-- Promoción de Lanzamiento Promofy
-- 03 jun → 18 jul 2026 (45 días)
--
-- Cada dueño que active una membresía durante la promo recibe
-- el 100 % del monto pagado en créditos de publicidad.
-- Resultado: "no gasta nada" y Promofy gana negocios reales suscritos.
-- ═══════════════════════════════════════════════════════════════════════

-- ─── 1. Tabla: launch_promos ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.launch_promos (
  id         serial      PRIMARY KEY,
  name       text        NOT NULL,
  ends_at    timestamptz NOT NULL,
  credit_pct int         NOT NULL DEFAULT 100
                          CHECK (credit_pct BETWEEN 1 AND 200),
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ─── 2. Tabla: promo_credit_log ─────────────────────────────────────────
-- Garantiza que cada suscripción reciba el crédito una sola vez por promo
CREATE TABLE IF NOT EXISTS public.promo_credit_log (
  id              uuid          PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id uuid          NOT NULL REFERENCES public.user_subscriptions(id) ON DELETE CASCADE,
  promo_id        int           NOT NULL REFERENCES public.launch_promos(id),
  user_id         uuid          NOT NULL REFERENCES auth.users(id)   ON DELETE CASCADE,
  amount_mxn      numeric(10,2) NOT NULL,
  credited_at     timestamptz   NOT NULL DEFAULT now(),
  UNIQUE(subscription_id, promo_id)   -- idempotencia
);

ALTER TABLE public.promo_credit_log ENABLE ROW LEVEL SECURITY;

-- El usuario puede ver sus propios registros (por si queremos mostrarlo en UI)
CREATE POLICY "user_reads_own_promo_log"
  ON public.promo_credit_log FOR SELECT
  USING (auth.uid() = user_id);

-- El trigger usa SECURITY DEFINER → service_role hace el INSERT
CREATE POLICY "service_role_manage_promo_log"
  ON public.promo_credit_log FOR ALL
  TO service_role USING (true) WITH CHECK (true);

-- ─── 3. Seed: primera promo (45 días desde 03-jun-2026) ────────────────
INSERT INTO public.launch_promos (name, ends_at, credit_pct)
VALUES ('Lanzamiento Promofy — Membresía = Publicidad', '2026-07-18 23:59:59+00', 100)
ON CONFLICT DO NOTHING;

-- ─── 4. Función: acreditar cuando el pago se autoriza ──────────────────
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
  -- Solo cuando status acaba de pasar a 'authorized'
  IF NEW.status <> 'authorized' THEN RETURN NEW; END IF;
  IF OLD IS NOT NULL AND OLD.status = 'authorized' THEN RETURN NEW; END IF;

  -- ¿Existe una promo activa ahora mismo?
  SELECT * INTO v_promo
  FROM   public.launch_promos
  WHERE  now() < ends_at
  ORDER  BY ends_at ASC
  LIMIT  1;
  IF NOT FOUND THEN RETURN NEW; END IF;

  -- ¿Ya acreditamos esta suscripción para esta promo? (idempotencia)
  IF EXISTS (
    SELECT 1 FROM public.promo_credit_log
    WHERE  subscription_id = NEW.id AND promo_id = v_promo.id
  ) THEN RETURN NEW; END IF;

  -- Obtener precio del plan
  SELECT * INTO v_plan FROM public.membership_plans WHERE id = NEW.plan_id;
  IF NOT FOUND THEN RETURN NEW; END IF;

  v_amount := ROUND(v_plan.price_mxn * v_promo.credit_pct / 100.0, 2);

  -- Acumular en la cartera del perfil del dueño
  UPDATE public.profiles
  SET    ad_credits_mxn = ad_credits_mxn + v_amount
  WHERE  id = NEW.user_id;

  -- Registrar para evitar doble acreditación
  INSERT INTO public.promo_credit_log (subscription_id, promo_id, user_id, amount_mxn)
  VALUES (NEW.id, v_promo.id, NEW.user_id, v_amount);

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trig_launch_promo ON public.user_subscriptions;
CREATE TRIGGER trig_launch_promo
  AFTER INSERT OR UPDATE ON public.user_subscriptions
  FOR EACH ROW EXECUTE FUNCTION public.award_launch_promo_credit();

-- ─── 5. RPC: consultar créditos de cartera del usuario activo ──────────
-- Retorna el saldo de ad_credits_mxn (referidos + promo de lanzamiento)
CREATE OR REPLACE FUNCTION public.get_my_wallet_credits()
RETURNS numeric
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE v_credits numeric(10,2);
BEGIN
  IF auth.uid() IS NULL THEN RETURN 0; END IF;
  SELECT ad_credits_mxn INTO v_credits FROM public.profiles WHERE id = auth.uid();
  RETURN COALESCE(v_credits, 0);
END;
$$;
