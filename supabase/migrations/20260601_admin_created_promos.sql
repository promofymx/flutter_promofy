-- ═══════════════════════════════════════════════════════════════════════════════
-- PROMOFY · Carga masiva superadmin — promos no cuentan contra el plan
-- Ejecutar en el SQL Editor de Supabase
-- ═══════════════════════════════════════════════════════════════════════════════

-- 1. Nueva columna en promotions
ALTER TABLE public.promotions
  ADD COLUMN IF NOT EXISTS is_admin_created BOOLEAN NOT NULL DEFAULT FALSE;

-- 2. Índice para que el count sea eficiente
CREATE INDEX IF NOT EXISTS promotions_not_admin_idx
  ON public.promotions (establishment_id)
  WHERE is_admin_created = FALSE;

-- Nota: La app ya usa una consulta directa para countTotalPromos.
-- Con este cambio, countTotalPromos añade el filtro is_admin_created = false,
-- por lo que las promos cargadas por el superadmin NO cuentan contra el límite.
