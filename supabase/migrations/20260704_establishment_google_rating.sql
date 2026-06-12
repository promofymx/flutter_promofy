-- Devuelve la calificación de Google (rating + #reseñas) de un establecimiento,
-- para mostrarla CON atribución a Google en el perfil. SECURITY DEFINER porque
-- google_rating/google_reviews no son públicos vía RLS directa.
-- Si el negocio no tiene calificación, rating viene NULL → la app no pinta nada.

CREATE OR REPLACE FUNCTION public.get_establishment_google_rating(
  p_establishment_id uuid
)
RETURNS TABLE(rating numeric, reviews int)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT e.google_rating, e.google_reviews
  FROM public.establishments e
  WHERE e.id = p_establishment_id;
$$;

GRANT EXECUTE ON FUNCTION public.get_establishment_google_rating(uuid)
  TO anon, authenticated;
