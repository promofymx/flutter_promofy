-- ════════════════════════════════════════════════════════════════════════════
-- i18n de datos: traducciones de categorías y características
--
-- Agrega columnas name_en / name_de a las tablas `categories` y `characteristics`.
-- La app mostrará la columna según el idioma activo (en/de), con fallback a `name`
-- (español) cuando la traducción esté vacía.
--
-- Las traducciones de los valores existentes se cargan por separado (vía API).
-- Para categorías/características NUEVAS que se den de alta sin traducción, la app
-- usará automáticamente el nombre en español.
-- ════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.categories
  ADD COLUMN IF NOT EXISTS name_en text,
  ADD COLUMN IF NOT EXISTS name_de text;

ALTER TABLE public.characteristics
  ADD COLUMN IF NOT EXISTS name_en text,
  ADD COLUMN IF NOT EXISTS name_de text;
