-- get_public_establishment ahora acepta TANTO el id (uuid) COMO el place_id de
-- Google, para que promofy.fun/e/<place_id> (link de la invitación de WhatsApp y
-- de los QR masivos) resuelva al perfil una vez que el negocio está sembrado.
-- Cambia el parámetro de uuid a text; PostgREST sigue recibiendo 'p_id'.

DROP FUNCTION IF EXISTS public.get_public_establishment(uuid);

CREATE OR REPLACE FUNCTION public.get_public_establishment(p_id text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v      jsonb;
  v_uuid uuid;
BEGIN
  BEGIN
    v_uuid := p_id::uuid;       -- si p_id es un UUID válido
  EXCEPTION WHEN others THEN
    v_uuid := NULL;             -- si no (ej. un place_id "ChIJ…")
  END;

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
  ) INTO v
  FROM public.establishments e
  WHERE e.is_active = true
    AND ((v_uuid IS NOT NULL AND e.id = v_uuid) OR e.place_id = p_id)
  LIMIT 1;

  RETURN v;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_public_establishment(text) TO anon, authenticated;
