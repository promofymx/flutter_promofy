-- Comida favorita del usuario: IDs de categorías (referencian public.categories).
-- Se usa para recomendaciones / segmentación. El usuario las edita en Perfil → Configuración.

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS favorite_category_ids int[] NOT NULL DEFAULT '{}';
