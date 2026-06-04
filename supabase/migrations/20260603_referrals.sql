-- ═══════════════════════════════════════════════════════════════════
-- Programa de referidos — $300 MXN crédito publicitario
-- Se otorga cuando el referido activa una membresía de pago
-- ═══════════════════════════════════════════════════════════════════

-- ─── 1. Columnas nuevas en profiles ────────────────────────────────
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS referral_code   text  UNIQUE,
  ADD COLUMN IF NOT EXISTS ad_credits_mxn  numeric(10,2) NOT NULL DEFAULT 0;

-- Generar códigos para usuarios existentes
DO $$
DECLARE r RECORD;
BEGIN
  FOR r IN SELECT id FROM public.profiles WHERE referral_code IS NULL LOOP
    UPDATE public.profiles
    SET referral_code = UPPER(SUBSTRING(REPLACE(gen_random_uuid()::text, '-', ''), 1, 8))
    WHERE id = r.id;
  END LOOP;
END $$;

-- ─── 2. Trigger: código único al crear perfil ───────────────────────
CREATE OR REPLACE FUNCTION public.generate_profile_referral_code()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.referral_code IS NULL THEN
    NEW.referral_code :=
      UPPER(SUBSTRING(REPLACE(gen_random_uuid()::text, '-', ''), 1, 8));
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trig_gen_referral_code ON public.profiles;
CREATE TRIGGER trig_gen_referral_code
  BEFORE INSERT ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.generate_profile_referral_code();

-- ─── 3. Tabla referrals ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.referrals (
  id          uuid          PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id uuid          NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  referred_id uuid          NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  reward_mxn  numeric(10,2) NOT NULL DEFAULT 300,
  status      text          NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending', 'rewarded', 'cancelled')),
  created_at  timestamptz   NOT NULL DEFAULT now(),
  rewarded_at timestamptz,
  UNIQUE(referred_id)   -- cada usuario solo puede ser referido una vez
);

ALTER TABLE public.referrals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "referrer_can_read" ON public.referrals
  FOR SELECT USING (auth.uid() = referrer_id);

-- ─── 4. RPC: vincular referido (usado por OAuth de Google) ──────────
-- El cliente lo llama cuando tiene sesión activa (post-OAuth)
CREATE OR REPLACE FUNCTION public.link_referral(p_referrer_code text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_referrer_id uuid;
BEGIN
  IF auth.uid() IS NULL THEN RETURN; END IF;

  SELECT id INTO v_referrer_id
  FROM public.profiles
  WHERE referral_code = UPPER(TRIM(p_referrer_code));

  IF v_referrer_id IS NULL       THEN RETURN; END IF;
  IF v_referrer_id = auth.uid()  THEN RETURN; END IF;

  INSERT INTO public.referrals (referrer_id, referred_id, reward_mxn)
  VALUES (v_referrer_id, auth.uid(), 300)
  ON CONFLICT (referred_id) DO NOTHING;
END;
$$;

-- ─── 5. Trigger: vincular referido desde metadata de signup ─────────
-- Para registro con email, el código viaja en raw_user_meta_data
CREATE OR REPLACE FUNCTION public.handle_referral_from_signup()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_referring_code text;
  v_referrer_id    uuid;
BEGIN
  SELECT UPPER(TRIM(raw_user_meta_data->>'referring_code'))
  INTO v_referring_code
  FROM auth.users WHERE id = NEW.id;

  IF v_referring_code IS NULL OR v_referring_code = '' THEN
    RETURN NEW;
  END IF;

  SELECT id INTO v_referrer_id
  FROM public.profiles
  WHERE referral_code = v_referring_code;

  IF v_referrer_id IS NULL OR v_referrer_id = NEW.id THEN
    RETURN NEW;
  END IF;

  INSERT INTO public.referrals (referrer_id, referred_id, reward_mxn)
  VALUES (v_referrer_id, NEW.id, 300)
  ON CONFLICT (referred_id) DO NOTHING;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trig_referral_on_profile_create ON public.profiles;
CREATE TRIGGER trig_referral_on_profile_create
  AFTER INSERT ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_referral_from_signup();

-- ─── 6. Trigger: otorgar crédito cuando el referido paga ────────────
CREATE OR REPLACE FUNCTION public.award_referral_credit()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_ref public.referrals%ROWTYPE;
BEGIN
  -- Solo cuando status cambia a 'authorized'
  IF NEW.status = 'authorized'
     AND (OLD IS NULL OR OLD.status <> 'authorized') THEN

    SELECT * INTO v_ref
    FROM public.referrals
    WHERE referred_id = NEW.user_id AND status = 'pending';

    IF FOUND THEN
      -- Acreditar al referidor
      UPDATE public.profiles
      SET ad_credits_mxn = ad_credits_mxn + v_ref.reward_mxn
      WHERE id = v_ref.referrer_id;

      -- Marcar como recompensado
      UPDATE public.referrals
      SET status = 'rewarded', rewarded_at = now()
      WHERE id = v_ref.id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trig_award_referral ON public.user_subscriptions;
CREATE TRIGGER trig_award_referral
  AFTER INSERT OR UPDATE ON public.user_subscriptions
  FOR EACH ROW EXECUTE FUNCTION public.award_referral_credit();

-- ─── 7. RPC: estadísticas de referidos del usuario activo ───────────
CREATE OR REPLACE FUNCTION public.get_my_referral_stats()
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_code    text;
  v_credits numeric(10,2);
  v_total   int;
  v_rewarded int;
  v_pending  int;
BEGIN
  IF auth.uid() IS NULL THEN RETURN NULL; END IF;

  SELECT referral_code, ad_credits_mxn
  INTO v_code, v_credits
  FROM public.profiles WHERE id = auth.uid();

  SELECT
    COUNT(*),
    COUNT(*) FILTER (WHERE status = 'rewarded'),
    COUNT(*) FILTER (WHERE status = 'pending')
  INTO v_total, v_rewarded, v_pending
  FROM public.referrals WHERE referrer_id = auth.uid();

  RETURN json_build_object(
    'referral_code',       v_code,
    'ad_credits_mxn',      v_credits,
    'total_referrals',     v_total,
    'rewarded_referrals',  v_rewarded,
    'pending_referrals',   v_pending
  );
END;
$$;
