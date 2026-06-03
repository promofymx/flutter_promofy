-- Permite que un establecimiento tenga varias categorías.
-- Mantenemos category_id (primera categoría) para compatibilidad con queries existentes.

ALTER TABLE establishments
  ADD COLUMN IF NOT EXISTS category_ids integer[] NOT NULL DEFAULT '{}';

-- Migrar datos existentes
UPDATE establishments
   SET category_ids = ARRAY[category_id]
 WHERE category_id IS NOT NULL
   AND (category_ids IS NULL OR array_length(category_ids, 1) IS NULL);
