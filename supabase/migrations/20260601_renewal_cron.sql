-- ═══════════════════════════════════════════════════════════════════════════════
-- PROMOFY · Cron job: aviso de renovación 5 días antes
-- Ejecutar en el SQL Editor de Supabase
--
-- REQUISITOS:
--   1. Habilitar pg_cron: Database → Extensions → pg_cron → Enable
--   2. Habilitar pg_net:  Database → Extensions → pg_net  → Enable
--   3. Desplegar la Edge Function:
--        supabase functions deploy notify-renewal --no-verify-jwt
-- ═══════════════════════════════════════════════════════════════════════════════

-- Reemplaza estos valores con los tuyos:
--   <PROJECT_REF>   → hfmvelirrcawsxaudhfl
--   <SERVICE_KEY>   → tu SUPABASE_SERVICE_ROLE_KEY

-- Ejecuta todos los días a las 10:00 AM UTC (= 4:00 AM / 5:00 AM hora MX)
SELECT cron.schedule(
  'notify-renewal-5days',      -- nombre único del job
  '0 10 * * *',                -- cron expression: diario 10:00 UTC
  $$
    SELECT net.http_post(
      url     := 'https://hfmvelirrcawsxaudhfl.supabase.co/functions/v1/notify-renewal',
      headers := jsonb_build_object(
        'Content-Type',  'application/json',
        'Authorization', 'Bearer ' || current_setting('app.service_role_key', true)
      ),
      body    := '{}'::jsonb
    );
  $$
);

-- ── Guardar service_role_key en app.settings ────────────────────────────────
-- Nota: Ejecuta esto UNA SOLA VEZ con la clave real (no commites este SQL).
-- ALTER DATABASE postgres SET "app.service_role_key" = 'TU_SERVICE_ROLE_KEY_AQUI';

-- ── Para verificar que el job está registrado: ───────────────────────────────
-- SELECT * FROM cron.job;

-- ── Para ejecutarlo manualmente y probar: ────────────────────────────────────
-- SELECT cron.run_job('notify-renewal-5days');

-- ── Para eliminar el job: ────────────────────────────────────────────────────
-- SELECT cron.unschedule('notify-renewal-5days');
