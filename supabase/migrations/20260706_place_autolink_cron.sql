-- Cron diario que intenta vincular con Google Places los establecimientos que
-- se dieron de alta sin place_id (respaldo del trigger instantáneo y reintento
-- de los que aún no habían hecho match). Edge function match-google-places.

DO $$
BEGIN
  PERFORM cron.unschedule('match-google-places');
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;

SELECT cron.schedule(
  'match-google-places',
  '0 10 * * *',                              -- 10:00 UTC ≈ 04:00 CDMX, cada día
  $$
    SELECT net.http_post(
      url     := 'https://hfmvelirrcawsxaudhfl.supabase.co/functions/v1/match-google-places',
      headers := jsonb_build_object(
        'Content-Type',  'application/json',
        'Authorization', 'Bearer ' || current_setting('app.service_role_key', true)
      ),
      body    := '{}'::jsonb
    );
  $$
);
