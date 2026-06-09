-- ═══════════════════════════════════════════════════════════════════
-- Conector de cartera → saldo de publicidad del establecimiento
-- El dueño aplica su crédito de cartera (profiles.ad_credits_mxn,
-- referidos + promo de inscripción) al saldo gastable de uno de sus
-- locales (ad_credits.balance_mxn). Así el crédito por fin es utilizable.
-- ═══════════════════════════════════════════════════════════════════

-- Permitir el nuevo tipo de transacción 'wallet' en el ledger.
DO $$
DECLARE c text;
BEGIN
  SELECT conname INTO c
  FROM pg_constraint
  WHERE conrelid = 'public.ad_credit_txns'::regclass
    AND contype = 'c'
    AND pg_get_constraintdef(oid) ILIKE '%type%';
  IF c IS NOT NULL THEN
    EXECUTE 'ALTER TABLE public.ad_credit_txns DROP CONSTRAINT ' || quote_ident(c);
  END IF;
  ALTER TABLE public.ad_credit_txns
    ADD CONSTRAINT ad_credit_txns_type_check
    CHECK (type IN ('purchase','impression_debit','refund','manual_admin','wallet'));
END $$;

CREATE OR REPLACE FUNCTION public.apply_wallet_credit(
  p_establishment_id uuid,
  p_amount           numeric
)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid         uuid := auth.uid();
  v_wallet      numeric(12,2);
  v_new_balance numeric(12,2);
BEGIN
  IF v_uid IS NULL THEN
    RETURN json_build_object('ok', false, 'error', 'unauthenticated');
  END IF;
  IF p_amount IS NULL OR p_amount <= 0 THEN
    RETURN json_build_object('ok', false, 'error', 'invalid_amount');
  END IF;

  -- El caller debe ser dueño del establecimiento
  IF NOT EXISTS (
    SELECT 1 FROM public.establishments
    WHERE id = p_establishment_id AND owner_id = v_uid
  ) THEN
    RETURN json_build_object('ok', false, 'error', 'unauthorized');
  END IF;

  -- Bloquear el perfil y validar saldo de cartera
  SELECT ad_credits_mxn INTO v_wallet
  FROM public.profiles WHERE id = v_uid FOR UPDATE;

  IF COALESCE(v_wallet, 0) < p_amount THEN
    RETURN json_build_object('ok', false, 'error', 'insufficient_wallet',
                             'wallet', COALESCE(v_wallet, 0));
  END IF;

  -- Descontar de la cartera del usuario
  UPDATE public.profiles
  SET ad_credits_mxn = ad_credits_mxn - p_amount
  WHERE id = v_uid;

  -- Acreditar al saldo del establecimiento
  INSERT INTO public.ad_credits (establishment_id, balance_mxn)
  VALUES (p_establishment_id, p_amount)
  ON CONFLICT (establishment_id)
  DO UPDATE SET balance_mxn = public.ad_credits.balance_mxn + p_amount,
                updated_at  = now()
  RETURNING balance_mxn INTO v_new_balance;

  -- Registrar la transacción
  INSERT INTO public.ad_credit_txns (establishment_id, amount_mxn, type, note)
  VALUES (p_establishment_id, p_amount, 'wallet',
          'Crédito aplicado desde la cartera del usuario');

  -- Reactivar campañas pausadas que aún tengan presupuesto
  UPDATE public.ad_campaigns
  SET status = 'active', updated_at = now()
  WHERE establishment_id = p_establishment_id
    AND status = 'paused'
    AND (budget_mxn - spent_mxn) > 0;

  RETURN json_build_object(
    'ok',      true,
    'wallet',  COALESCE(v_wallet, 0) - p_amount,
    'balance', v_new_balance
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.apply_wallet_credit(uuid, numeric) TO authenticated;
