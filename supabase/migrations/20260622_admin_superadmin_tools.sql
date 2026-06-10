-- ════════════════════════════════════════════════════════════════════════════
-- Herramientas de superadmin (web):
--   • admin_delete_promotion      → soft-delete (deleted_at); el feed ya filtra.
--   • admin_delete_establishment  → delete real; si hay dependencias, desactiva.
--   • admin_grant_user_wallet     → suma crédito a la cartera del usuario
--                                    (profiles.ad_credits_mxn).
-- Todos protegidos con is_platform_admin() (role admin/superadmin o is_superadmin).
-- ════════════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.admin_delete_promotion(p_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT is_platform_admin() THEN
    RETURN jsonb_build_object('ok', false, 'error', 'forbidden');
  END IF;
  UPDATE public.promotions SET deleted_at = now() WHERE id = p_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', 'no encontrada');
  END IF;
  RETURN jsonb_build_object('ok', true);
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_delete_establishment(p_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT is_platform_admin() THEN
    RETURN jsonb_build_object('ok', false, 'error', 'forbidden');
  END IF;
  -- Soft-delete de sus promos para que no queden huérfanas en el feed.
  UPDATE public.promotions SET deleted_at = now()
    WHERE establishment_id = p_id AND deleted_at IS NULL;
  DELETE FROM public.establishments WHERE id = p_id;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', 'no encontrado');
  END IF;
  RETURN jsonb_build_object('ok', true);
EXCEPTION WHEN foreign_key_violation THEN
  -- Si hay dependencias que impiden el borrado, lo desactivamos.
  UPDATE public.establishments SET is_active = false WHERE id = p_id;
  RETURN jsonb_build_object('ok', true, 'soft', true);
END;
$$;

-- Acepta el correo del usuario (se resuelve contra auth.users) para que el
-- superadmin pueda acreditar por correo, igual que en "Precios especiales".
CREATE OR REPLACE FUNCTION public.admin_grant_user_wallet(
  p_email  text,
  p_amount numeric,
  p_note   text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid     uuid;
  v_balance numeric;
BEGIN
  IF NOT is_platform_admin() THEN
    RETURN jsonb_build_object('ok', false, 'error', 'forbidden');
  END IF;
  IF p_amount IS NULL OR p_amount = 0 THEN
    RETURN jsonb_build_object('ok', false, 'error', 'monto inválido');
  END IF;

  SELECT id INTO v_uid
  FROM   auth.users
  WHERE  lower(email) = lower(trim(p_email))
  LIMIT  1;

  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', 'correo no encontrado');
  END IF;

  UPDATE public.profiles
     SET ad_credits_mxn = GREATEST(0, COALESCE(ad_credits_mxn, 0) + p_amount)
   WHERE id = v_uid
   RETURNING ad_credits_mxn INTO v_balance;

  IF v_balance IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', 'perfil no encontrado');
  END IF;

  RETURN jsonb_build_object('ok', true, 'balance', v_balance);
END;
$$;

GRANT EXECUTE ON FUNCTION public.admin_delete_promotion(uuid)              TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_delete_establishment(uuid)         TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_grant_user_wallet(text, numeric, text) TO authenticated;
