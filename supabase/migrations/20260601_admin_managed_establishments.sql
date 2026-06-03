-- ────────────────────────────────────────────────────────────────────────────
-- Feature: Admin-managed establishments
-- Adds is_admin_managed flag + trigger that auto-sets it when an admin
-- user creates an establishment.
-- ────────────────────────────────────────────────────────────────────────────

-- 1. Add column (idempotent)
ALTER TABLE establishments
  ADD COLUMN IF NOT EXISTS is_admin_managed BOOLEAN NOT NULL DEFAULT FALSE;

-- 2. Trigger function: auto-set flag when the inserter is admin
CREATE OR REPLACE FUNCTION trg_set_admin_managed()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF (SELECT role FROM profiles WHERE id = auth.uid()) = 'admin' THEN
    NEW.is_admin_managed := TRUE;
  END IF;
  RETURN NEW;
END;
$$;

-- 3. Attach trigger (drop first so the migration is re-runnable)
DROP TRIGGER IF EXISTS trg_admin_managed_before_insert ON establishments;
CREATE TRIGGER trg_admin_managed_before_insert
  BEFORE INSERT ON establishments
  FOR EACH ROW EXECUTE FUNCTION trg_set_admin_managed();
