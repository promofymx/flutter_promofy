-- ════════════════════════════════════════════════════════════════════════════
-- Cobro de publicidad: IMPRESIÓN + CLIC (modelo "ambas")
--
-- Reemplaza record_ad_impression para que:
--   1. Cobre tanto las impresiones como los clics (CPM + CPC).
--   2. Deduplique por (campaña, usuario, tipo, día): un mismo usuario solo
--      genera UN cobro de impresión y UN cobro de clic por campaña por día.
--      Esto evita el fraude / sobrecobro cuando el mismo usuario ve o toca el
--      anuncio muchas veces, y permite que el cliente dispare el evento de
--      forma agresiva sin riesgo.
--   3. Use type='impression_debit' en ad_credit_txns para AMBOS, de modo que
--      el panel admin (que suma 'impression_debit') refleje todo el gasto.
--      El desglose impresión vs clic vive en ad_impressions.type y en la nota.
--
-- Causa raíz del bug "gasto clavado en $6.30": la impresión solo se registraba
-- una vez por montaje del widget (initState). Como el feed se mantiene vivo
-- (keep-alive), al volver de un restaurante el widget no se re-montaba y nunca
-- se volvía a contar la impresión; los clics sí (cada toque) pero no cobraban.
-- ════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.record_ad_impression(
  p_campaign_id uuid,
  p_type        text DEFAULT 'impression'   -- 'impression' | 'click'
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id     uuid := auth.uid();
  v_campaign    public.ad_campaigns%ROWTYPE;
  v_pricing     public.ad_pricing%ROWTYPE;
  v_new_balance numeric;
  v_already     boolean := false;
  v_note_prefix text;
BEGIN
  IF p_type NOT IN ('impression', 'click') THEN
    RETURN;
  END IF;

  -- Cargar campaña activa
  SELECT * INTO v_campaign
  FROM   public.ad_campaigns
  WHERE  id = p_campaign_id AND status = 'active';
  IF NOT FOUND THEN RETURN; END IF;

  -- ── Dedup diario: 1 evento cobrable por usuario / campaña / tipo / día ──────
  -- La ventana "día" se calcula en horario de México (America/Mexico_City),
  -- de modo que el contador se reinicia a la medianoche local, no a la UTC.
  IF v_user_id IS NOT NULL THEN
    SELECT EXISTS (
      SELECT 1
      FROM   public.ad_impressions
      WHERE  campaign_id = p_campaign_id
        AND  user_id     = v_user_id
        AND  type        = p_type
        AND  created_at >= (date_trunc('day', now() AT TIME ZONE 'America/Mexico_City')
                            AT TIME ZONE 'America/Mexico_City')
    ) INTO v_already;
  END IF;

  IF v_already THEN
    -- Ya contado y cobrado hoy para este usuario → no duplicar ni recobrar.
    RETURN;
  END IF;

  -- ── Precio del formato (impresión y clic cobran el mismo price_mxn) ─────────
  SELECT * INTO v_pricing
  FROM   public.ad_pricing
  WHERE  format = v_campaign.format;

  IF FOUND AND v_pricing.price_mxn > 0 THEN
    v_note_prefix := CASE WHEN p_type = 'click' THEN 'Clic: ' ELSE 'Impresión: ' END;

    -- Verificar y descontar crédito atómicamente
    UPDATE public.ad_credits
    SET    balance_mxn = balance_mxn - v_pricing.price_mxn,
           updated_at  = now()
    WHERE  establishment_id = v_campaign.establishment_id
      AND  balance_mxn      >= v_pricing.price_mxn
    RETURNING balance_mxn INTO v_new_balance;

    IF NOT FOUND THEN
      -- Sin crédito suficiente → pausar campaña y salir (no se registra evento)
      UPDATE public.ad_campaigns
      SET status = 'paused', updated_at = now()
      WHERE id = p_campaign_id;
      RETURN;
    END IF;

    -- Actualizar gasto en campaña
    UPDATE public.ad_campaigns
    SET    spent_mxn  = spent_mxn + v_pricing.price_mxn,
           updated_at = now()
    WHERE  id = p_campaign_id;

    -- Registrar transacción de débito (type='impression_debit' para que el
    -- panel admin lo sume como gasto en campañas, tanto impresión como clic)
    INSERT INTO public.ad_credit_txns
      (establishment_id, amount_mxn, type, reference_id, note)
    VALUES (
      v_campaign.establishment_id,
      -v_pricing.price_mxn,
      'impression_debit',
      p_campaign_id::text,
      v_note_prefix || v_campaign.name
    );

    -- Pausar si el nuevo saldo ya no cubre otro evento
    IF v_new_balance < v_pricing.price_mxn THEN
      UPDATE public.ad_campaigns
      SET status = 'paused', updated_at = now()
      WHERE id = p_campaign_id;
    END IF;
  END IF;

  -- Registrar el evento (impresión o clic) para analítica / dedup
  INSERT INTO public.ad_impressions (campaign_id, user_id, type)
  VALUES (p_campaign_id, v_user_id, p_type);
END;
$$;

GRANT EXECUTE ON FUNCTION public.record_ad_impression TO authenticated;
