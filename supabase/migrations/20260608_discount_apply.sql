-- ═══════════════════════════════════════════════════════════════════
-- Aplicación de códigos de descuento en la suscripción
--   • columna discount_code_id en user_subscriptions
--   • RPC record_discount_redemption (registra el canje al autorizarse el pago)
-- ═══════════════════════════════════════════════════════════════════

ALTER TABLE public.user_subscriptions
  ADD COLUMN IF NOT EXISTS discount_code_id uuid
    REFERENCES public.discount_codes(id) ON DELETE SET NULL;

-- Registra el canje una sola vez e incrementa el contador de usos.
-- Lo llama el webhook (service_role) cuando la suscripción queda 'authorized'.
CREATE OR REPLACE FUNCTION public.record_discount_redemption(
  p_code_id         uuid,
  p_user_id         uuid,
  p_subscription_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF p_code_id IS NULL OR p_user_id IS NULL THEN
    RETURN;
  END IF;

  INSERT INTO public.discount_code_redemptions (code_id, user_id, subscription_id)
  VALUES (p_code_id, p_user_id, p_subscription_id)
  ON CONFLICT (code_id, user_id) DO NOTHING;

  -- Solo si efectivamente se insertó (no había canje previo) → incrementar usos.
  IF FOUND THEN
    UPDATE public.discount_codes
    SET used_count = used_count + 1
    WHERE id = p_code_id;
  END IF;
END;
$$;
