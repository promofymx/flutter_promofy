-- ═══════════════════════════════════════════════════════════════════
-- Precio especial asignado por correo (sin campo público en el checkout).
-- El superadmin asigna un descuento a un correo; se aplica automáticamente
-- cuando ese cliente se suscribe.
-- ═══════════════════════════════════════════════════════════════════

ALTER TABLE public.discount_codes
  ADD COLUMN IF NOT EXISTS assigned_email text;

-- Normalizar código (MAYÚSCULAS) y correo asignado (minúsculas).
CREATE OR REPLACE FUNCTION public.normalize_discount_code()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.code := UPPER(TRIM(NEW.code));
  IF NEW.assigned_email IS NOT NULL THEN
    NEW.assigned_email := LOWER(TRIM(NEW.assigned_email));
    IF NEW.assigned_email = '' THEN
      NEW.assigned_email := NULL;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE INDEX IF NOT EXISTS idx_discount_codes_assigned_email
  ON public.discount_codes (assigned_email)
  WHERE assigned_email IS NOT NULL;
