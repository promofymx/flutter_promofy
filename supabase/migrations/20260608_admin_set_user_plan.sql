-- ═══════════════════════════════════════════════════════════════════
-- admin_set_user_plan: el superadmin asigna/cambia/quita el plan de un
-- usuario escribiendo en user_subscriptions (la tabla real que usa la app)
-- y reflejándolo en profiles (plan_id + role), igual que el webhook de MP.
-- p_plan_id NULL = quitar plan.
-- ═══════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.admin_set_user_plan(
  p_user_id uuid,
  p_plan_id int
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_is_admin boolean;
  v_existing uuid;
  v_now      timestamptz := now();
BEGIN
  SELECT is_superadmin INTO v_is_admin
  FROM public.profiles WHERE id = auth.uid();
  IF NOT COALESCE(v_is_admin, false) THEN
    RAISE EXCEPTION 'Sin permisos';
  END IF;

  -- ── Quitar plan ────────────────────────────────────────────────
  IF p_plan_id IS NULL THEN
    UPDATE public.user_subscriptions
      SET status = 'cancelled'
      WHERE user_id = p_user_id AND status IN ('authorized', 'pending');
    UPDATE public.profiles SET plan_id = NULL WHERE id = p_user_id;
    RETURN;
  END IF;

  -- Validar que el plan exista
  IF NOT EXISTS (SELECT 1 FROM public.membership_plans WHERE id = p_plan_id) THEN
    RAISE EXCEPTION 'Plan inexistente';
  END IF;

  -- ── Asignar / cambiar plan ─────────────────────────────────────
  SELECT id INTO v_existing
  FROM public.user_subscriptions
  WHERE user_id = p_user_id
  ORDER BY created_at DESC
  LIMIT 1;

  IF v_existing IS NOT NULL THEN
    UPDATE public.user_subscriptions
      SET plan_id              = p_plan_id,
          status               = 'authorized',
          current_period_start = v_now,
          current_period_end   = v_now + interval '1 month'
      WHERE id = v_existing;
  ELSE
    INSERT INTO public.user_subscriptions
      (user_id, plan_id, mp_preapproval_id, status,
       current_period_start, current_period_end)
    VALUES
      (p_user_id, p_plan_id, 'manual_' || gen_random_uuid()::text, 'authorized',
       v_now, v_now + interval '1 month');
  END IF;

  -- Reflejar en el perfil (como el webhook al autorizar)
  UPDATE public.profiles
    SET plan_id = p_plan_id, role = 'business_owner'
    WHERE id = p_user_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.admin_set_user_plan(uuid, int) TO authenticated;
