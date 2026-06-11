-- ════════════════════════════════════════════════════════════════════════════
-- Apple review: fecha de nacimiento y nombre dejan de ser OBLIGATORIOS.
-- Para no dejar al usuario atrapado en el onboarding (antes "completo" exigía
-- nombre+fecha+género), agregamos una bandera explícita de onboarding hecho.
-- Backfill: usuarios existentes con nombre se consideran ya onboarded.
-- ════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS onboarding_completed boolean NOT NULL DEFAULT false;

UPDATE public.profiles
   SET onboarding_completed = true
 WHERE full_name IS NOT NULL AND full_name <> '';
