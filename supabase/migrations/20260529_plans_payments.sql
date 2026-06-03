-- ═══════════════════════════════════════════════════════════════════════════════
-- PROMOFY · Planes y Pagos con MercadoPago
-- Ejecutar en el SQL Editor de Supabase (una sola vez)
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─── 1. membership_plans: columnas nuevas ─────────────────────────────────────
ALTER TABLE public.membership_plans
  ADD COLUMN IF NOT EXISTS mp_preapproval_plan_id   text,
  ADD COLUMN IF NOT EXISTS max_push_notifications   int NOT NULL DEFAULT 0;

-- ─── 2. user_subscriptions ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_subscriptions (
  id                    uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_id               int         NOT NULL REFERENCES public.membership_plans(id),
  mp_preapproval_id     text        UNIQUE,
  status                text        NOT NULL DEFAULT 'pending',
  -- pending | authorized | paused | cancelled
  current_period_start  timestamptz,
  current_period_end    timestamptz,
  created_at            timestamptz NOT NULL DEFAULT now(),
  updated_at            timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_sees_own_subscription"
  ON public.user_subscriptions FOR SELECT
  USING (auth.uid() = user_id);

-- Edge Functions usan service_role key → necesitan policy para INSERT/UPDATE
CREATE POLICY "service_role_manage_subscriptions"
  ON public.user_subscriptions FOR ALL
  TO service_role USING (true) WITH CHECK (true);

-- ─── 3. add_on_purchases ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.add_on_purchases (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  add_on_type     text        NOT NULL,
  -- extra_establishment | extra_promotions | push_pack
  mp_payment_id   text        UNIQUE,
  quantity        int         NOT NULL DEFAULT 1,
  amount_paid     numeric(10, 2),
  status          text        NOT NULL DEFAULT 'pending',
  -- pending | approved | rejected
  created_at      timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.add_on_purchases ENABLE ROW LEVEL SECURITY;

CREATE POLICY "user_sees_own_addons"
  ON public.add_on_purchases FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "service_role_manage_addons"
  ON public.add_on_purchases FOR ALL
  TO service_role USING (true) WITH CHECK (true);

-- ─── 4. RPC: suscripción activa del usuario autenticado ──────────────────────
CREATE OR REPLACE FUNCTION public.get_my_subscription()
RETURNS json
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  v_uid  uuid := auth.uid();
  v_sub  public.user_subscriptions%ROWTYPE;
  v_plan public.membership_plans%ROWTYPE;
BEGIN
  -- Prioridad: suscripción activa via MP
  SELECT * INTO v_sub
  FROM   public.user_subscriptions
  WHERE  user_id = v_uid
    AND  status IN ('authorized', 'pending')
  ORDER BY created_at DESC
  LIMIT  1;

  IF FOUND THEN
    SELECT * INTO v_plan
    FROM   public.membership_plans
    WHERE  id = v_sub.plan_id;

    RETURN json_build_object(
      'subscription', json_build_object(
        'id',                   v_sub.id,
        'plan_id',              v_sub.plan_id,
        'mp_preapproval_id',    v_sub.mp_preapproval_id,
        'status',               v_sub.status,
        'current_period_start', v_sub.current_period_start,
        'current_period_end',   v_sub.current_period_end,
        'created_at',           v_sub.created_at
      ),
      'plan', json_build_object(
        'id',                     v_plan.id,
        'name',                   v_plan.name,
        'price_mxn',              v_plan.price_mxn,
        'max_establishments',     v_plan.max_establishments,
        'max_promotions',         v_plan.max_promotions,
        'max_push_notifications', v_plan.max_push_notifications
      )
    );
  END IF;

  -- Fallback: plan asignado manualmente por el admin en profiles.plan_id
  SELECT mp.* INTO v_plan
  FROM   public.membership_plans mp
  JOIN   public.profiles          p ON p.plan_id = mp.id
  WHERE  p.id = v_uid;

  IF FOUND THEN
    RETURN json_build_object(
      'subscription', null,
      'plan', json_build_object(
        'id',                     v_plan.id,
        'name',                   v_plan.name,
        'price_mxn',              v_plan.price_mxn,
        'max_establishments',     v_plan.max_establishments,
        'max_promotions',         v_plan.max_promotions,
        'max_push_notifications', v_plan.max_push_notifications
      )
    );
  END IF;

  -- Sin plan
  RETURN json_build_object('subscription', null, 'plan', null);
END;
$$;
