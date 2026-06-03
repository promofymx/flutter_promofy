-- Plantillas pre-aprobadas de notificaciones push.
-- Los dueños de negocio NO escriben texto libre; el sistema usa estas plantillas.
-- {establishment_name} y {promo_name} se reemplazan en runtime.

CREATE TABLE IF NOT EXISTS public.notification_templates (
  id          serial      PRIMARY KEY,
  promo_type  text        NOT NULL DEFAULT 'normal', -- 'normal' | 'flash'
  title       text        NOT NULL,
  body        text        NOT NULL,
  sort_order  int         NOT NULL DEFAULT 0,
  is_active   boolean     NOT NULL DEFAULT true
);

ALTER TABLE public.notification_templates ENABLE ROW LEVEL SECURITY;

-- Solo lectura pública (los dueños necesitan ver las plantillas disponibles)
CREATE POLICY "anyone can read active templates"
  ON public.notification_templates FOR SELECT
  USING (is_active = true);

-- Plantillas de promos normales
INSERT INTO public.notification_templates (promo_type, title, body, sort_order) VALUES
('normal', '¡Nueva promo en {establishment_name}! 🎉',  'Acaban de lanzar {promo_name}. ¡Descúbrela ahora!',                        1),
('normal', '{establishment_name} tiene algo para ti 🏷️', 'Nueva promoción disponible. ¡No te la pierdas!',                           2),
('normal', '¡Tu favorito lanzó algo nuevo! 🍽️',         '{establishment_name} agregó {promo_name} hoy. ¡Ven y aprovecha!',           3),
('normal', '¿Ya lo viste? 👀',                           '{establishment_name} tiene una nueva promo esperándote.',                  4),
-- Plantillas de promos flash
('flash',  '¡Relámpago en {establishment_name}! ⚡',    'Promo flash activa ahora mismo. ¡Solo por tiempo limitado!',              1),
('flash',  '¡Corre! {establishment_name} activó una promo 🔥', 'Se acaba rápido. ¡No la dejes pasar!',                              2),
('flash',  '¡AHORA! Oferta relámpago ⚡',               '{establishment_name} tiene {promo_name} activa en este momento.',          3);
