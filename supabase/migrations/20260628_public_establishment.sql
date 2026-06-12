-- get_public_establishment: info pública de un establecimiento por id, para la
-- página web promofy.fun/e/<id> (destino del QR y del botón compartir).
-- SECURITY DEFINER + lectura pública (anon) pero SOLO de establecimientos activos
-- y solo campos no sensibles.

CREATE OR REPLACE FUNCTION public.get_public_establishment(p_id uuid)
RETURNS jsonb
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT jsonb_build_object(
    'id',            e.id,
    'name',          e.name,
    'description',   e.description,
    'address',       COALESCE(e.address, e.street, ''),
    'logo_url',      e.logo_url,
    'instagram_url', e.instagram_url,
    'facebook_url',  e.facebook_url,
    'website',       e.website,
    'active_promos', (SELECT COUNT(*)::int FROM public.promotions p
                      WHERE p.establishment_id = e.id AND p.is_active = true)
  )
  FROM public.establishments e
  WHERE e.id = p_id AND e.is_active = true;
$$;

GRANT EXECUTE ON FUNCTION public.get_public_establishment(uuid) TO anon, authenticated;
