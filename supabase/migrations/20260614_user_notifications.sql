-- ════════════════════════════════════════════════════════════════════════════
-- Centro de notificaciones in-app (campanita): inbox por usuario.
-- Se llena desde las edge functions de push (service role bypassa RLS).
-- ════════════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.user_notifications (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title      text        NOT NULL,
  body       text,
  type       text,        -- flash_promo | new_promo | broadcast | loyalty_stamp | ad | ...
  data       jsonb       NOT NULL DEFAULT '{}'::jsonb,
  read_at    timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_user_notif_feed
  ON public.user_notifications(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_notif_unread
  ON public.user_notifications(user_id) WHERE read_at IS NULL;

ALTER TABLE public.user_notifications ENABLE ROW LEVEL SECURITY;

-- El usuario lee y actualiza (marcar leído) solo lo suyo.
CREATE POLICY "read_own_notifs" ON public.user_notifications
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "update_own_notifs" ON public.user_notifications
  FOR UPDATE TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
-- (No hay policy de INSERT → solo service_role / edge functions insertan.)

-- ─── Contador de no-leídas ───────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.my_unread_notifications_count()
RETURNS int
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT count(*)::int FROM user_notifications
  WHERE user_id = auth.uid() AND read_at IS NULL;
$$;
GRANT EXECUTE ON FUNCTION public.my_unread_notifications_count() TO authenticated;

-- ─── Marcar todas como leídas ────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.mark_all_notifications_read()
RETURNS void
LANGUAGE sql SECURITY DEFINER SET search_path = public
AS $$
  UPDATE user_notifications SET read_at = now()
  WHERE user_id = auth.uid() AND read_at IS NULL;
$$;
GRANT EXECUTE ON FUNCTION public.mark_all_notifications_read() TO authenticated;

-- ─── Helper para edge functions: insertar a varios usuarios de una vez ────────
CREATE OR REPLACE FUNCTION public.enqueue_user_notifications(
  p_user_ids uuid[],
  p_title    text,
  p_body     text,
  p_type     text,
  p_data     jsonb DEFAULT '{}'::jsonb
)
RETURNS int
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE v_n int;
BEGIN
  INSERT INTO user_notifications (user_id, title, body, type, data)
  SELECT uid, p_title, p_body, p_type, p_data
  FROM unnest(p_user_ids) AS uid;
  GET DIAGNOSTICS v_n = ROW_COUNT;
  RETURN v_n;
END;
$$;
-- Solo service role (edge functions). No expuesto a clientes.
REVOKE ALL ON FUNCTION public.enqueue_user_notifications(uuid[], text, text, text, jsonb)
  FROM anon, authenticated;
