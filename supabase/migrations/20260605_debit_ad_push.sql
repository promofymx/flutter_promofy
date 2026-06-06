-- Cobro en bloque de un push publicitario: descuenta (precio_push × envíos) del
-- saldo del establecimiento, registra el gasto en la campaña y la transacción.
-- Lo llama la Edge Function send-ad-push tras enviar.

CREATE OR REPLACE FUNCTION public.debit_ad_push(p_campaign_id uuid, p_count int)
RETURNS numeric
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
DECLARE
  v_campaign public.ad_campaigns%ROWTYPE;
  v_price    numeric;
  v_total    numeric;
BEGIN
  IF p_count <= 0 THEN RETURN 0; END IF;

  SELECT * INTO v_campaign FROM public.ad_campaigns WHERE id = p_campaign_id;
  IF NOT FOUND THEN RETURN 0; END IF;

  SELECT price_mxn INTO v_price FROM public.ad_pricing WHERE format = 'push';
  IF v_price IS NULL THEN RETURN 0; END IF;

  v_total := v_price * p_count;

  UPDATE public.ad_credits
    SET    balance_mxn = balance_mxn - v_total, updated_at = now()
    WHERE  establishment_id = v_campaign.establishment_id
      AND  balance_mxn >= v_total;
  IF NOT FOUND THEN RETURN 0; END IF; -- saldo insuficiente

  UPDATE public.ad_campaigns
    SET    spent_mxn = spent_mxn + v_total, updated_at = now()
    WHERE  id = p_campaign_id;

  INSERT INTO public.ad_credit_txns
    (establishment_id, amount_mxn, type, reference_id, note)
  VALUES (
    v_campaign.establishment_id, -v_total, 'impression_debit',
    p_campaign_id::text,
    'Push publicitario (' || p_count || ' envios): ' || v_campaign.name
  );

  RETURN v_total;
END;
$$;
GRANT EXECUTE ON FUNCTION public.debit_ad_push(uuid, int) TO authenticated, service_role;
