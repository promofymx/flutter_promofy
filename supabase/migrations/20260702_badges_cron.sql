-- Cron nocturno que recalcula las insignias de establecimiento.
-- Requiere pg_cron habilitado (ya lo está: hay otros crons activos).
-- Corre la función SQL directo (no necesita edge function).

DO $$
BEGIN
  PERFORM cron.unschedule('recompute-establishment-badges');
EXCEPTION WHEN OTHERS THEN
  NULL;  -- no existía aún
END $$;

SELECT cron.schedule(
  'recompute-establishment-badges',
  '0 8 * * *',                              -- 08:00 UTC ≈ 02:00 CDMX, cada noche
  $$ SELECT public.compute_establishment_badges(); $$
);
