-- ════════════════════════════════════════════════════════════════════════════
-- Fix CRÍTICO del cobro de publicidad.
--
-- ad_credit_txns tenía un índice ÚNICO en reference_id (ad_credit_txns_reference_id_uniq).
-- Como reference_id = id de campaña para los débitos de impresión/clic, ese único
-- permitía SOLO UN cobro por campaña en toda su vida. Por eso el gasto se quedaba
-- clavado tras la 1ª impresión: cualquier débito posterior fallaba con
-- "duplicate key value violates unique constraint" (23505) y record_ad_impression
-- revertía toda la transacción → no se registraba nada.
--
-- Solución: quitar el único general y reaplicarlo SOLO para compras (idempotencia
-- de pagos MercadoPago). Las impresiones/clics pueden repetir reference_id.
-- (record_ad_impression ya deduplica por usuario/campaña/día.)
-- ════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.ad_credit_txns DROP CONSTRAINT IF EXISTS ad_credit_txns_reference_id_uniq;
DROP INDEX IF EXISTS ad_credit_txns_reference_id_uniq;

CREATE UNIQUE INDEX IF NOT EXISTS ad_credit_txns_purchase_ref_uniq
  ON public.ad_credit_txns (reference_id)
  WHERE type = 'purchase';
