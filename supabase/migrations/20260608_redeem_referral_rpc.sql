-- ═══════════════════════════════════════════════════════════════════
-- RPC redeem_referral: canjear un código de invitación desde la app
-- (usuarios ya registrados que aún no tienen referidor).
-- Devuelve un json con {ok, reason, referrer_name} para feedback en la UI.
-- ═══════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.redeem_referral(p_code text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_code          text := UPPER(TRIM(COALESCE(p_code, '')));
  v_referrer_id   uuid;
  v_referrer_name text;
  v_existing      uuid;
BEGIN
  IF auth.uid() IS NULL THEN
    RETURN json_build_object('ok', false, 'reason', 'unauthenticated');
  END IF;

  IF v_code = '' THEN
    RETURN json_build_object('ok', false, 'reason', 'empty');
  END IF;

  -- ¿El usuario ya tiene un referidor registrado?
  SELECT referrer_id INTO v_existing
  FROM public.referrals
  WHERE referred_id = auth.uid();

  IF v_existing IS NOT NULL THEN
    RETURN json_build_object('ok', false, 'reason', 'already');
  END IF;

  -- Buscar al referidor por su código.
  SELECT id, full_name INTO v_referrer_id, v_referrer_name
  FROM public.profiles
  WHERE referral_code = v_code;

  IF v_referrer_id IS NULL THEN
    RETURN json_build_object('ok', false, 'reason', 'not_found');
  END IF;

  IF v_referrer_id = auth.uid() THEN
    RETURN json_build_object('ok', false, 'reason', 'self');
  END IF;

  INSERT INTO public.referrals (referrer_id, referred_id, reward_mxn)
  VALUES (v_referrer_id, auth.uid(), 300)
  ON CONFLICT (referred_id) DO NOTHING;

  RETURN json_build_object(
    'ok',            true,
    'reason',        'ok',
    'referrer_name', COALESCE(v_referrer_name, '')
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.redeem_referral(text) TO authenticated;
