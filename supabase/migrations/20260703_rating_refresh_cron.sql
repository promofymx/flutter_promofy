-- Cron diario que refresca la calificación de Google de un lote de
-- establecimientos (edge function refresh-google-ratings).
-- Usa app.service_role_key (ya configurado para los otros crons).

DO $$
BEGIN
  PERFORM cron.unschedule('refresh-google-ratings');
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;

SELECT cron.schedule(
  'refresh-google-ratings',
  '30 9 * * *',                              -- 09:30 UTC ≈ 03:30 CDMX, cada día
  $$
    SELECT net.http_post(
      url     := 'https://hfmvelirrcawsxaudhfl.supabase.co/functions/v1/refresh-google-ratings',
      headers := jsonb_build_object(
        'Content-Type',  'application/json',
        'Authorization', 'Bearer ' || current_setting('app.service_role_key', true)
      ),
      body    := '{}'::jsonb
    );
  $$
);
