-- enqueue_user_notifications solo debe llamarse desde edge functions (service
-- role). Quitamos el grant PUBLIC por defecto y lo damos solo a service_role.
REVOKE ALL ON FUNCTION public.enqueue_user_notifications(uuid[], text, text, text, jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.enqueue_user_notifications(uuid[], text, text, text, jsonb) TO service_role;
