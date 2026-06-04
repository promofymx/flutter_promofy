-- ═══════════════════════════════════════════════════════════════════════════
-- Parche: agrega p_reference_id a admin_add_credit
--
-- El webhook mp-webhook llama a este RPC con p_reference_id = mp_payment_id
-- para que quede guardado en ad_credit_txns.reference_id y así garantizar
-- idempotencia (no acreditar el mismo pago dos veces).
-- ═══════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.admin_add_credit(
  p_establishment_id uuid,
  p_amount_mxn       numeric,
  p_description      text    DEFAULT 'Recarga de créditos publicitarios',
  p_added_by         text    DEFAULT NULL,
  p_reference_id     text    DEFAULT NULL   -- mp payment id para idempotencia
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Upsert saldo del establecimiento
  INSERT INTO public.ad_credits (establishment_id, balance_mxn)
  VALUES (p_establishment_id, p_amount_mxn)
  ON CONFLICT (establishment_id)
  DO UPDATE SET
    balance_mxn = public.ad_credits.balance_mxn + p_amount_mxn,
    updated_at  = now();

  -- Registrar transacción (con reference_id para idempotencia)
  INSERT INTO public.ad_credit_txns
    (establishment_id, amount_mxn, type, reference_id, note)
  VALUES (
    p_establishment_id,
    p_amount_mxn,
    CASE WHEN p_added_by IS NOT NULL THEN 'manual_admin' ELSE 'purchase' END,
    p_reference_id,
    p_description
  );

  -- Reactivar campañas pausadas con presupuesto restante
  UPDATE public.ad_campaigns
  SET    status     = 'active',
         updated_at = now()
  WHERE  establishment_id = p_establishment_id
    AND  status           = 'paused'
    AND  (budget_mxn - spent_mxn) > 0;
END;
$$;

-- Mismos permisos: solo service_role (webhooks / admin)
GRANT EXECUTE ON FUNCTION public.admin_add_credit TO service_role;
REVOKE EXECUTE ON FUNCTION public.admin_add_credit FROM authenticated;
