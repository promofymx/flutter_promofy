-- get_campaign_stats: vistas (impresiones) y clics por campaña, para que el
-- anunciante vea en sus métricas qué está pagando.
--
-- ad_impressions ya viene deduplicado por usuario/campaña/tipo/día (lo escribe
-- record_ad_impression), así que CADA fila = 1 alcance único diario cobrado.
-- Por eso COUNT(*) FILTER por type da exactamente vistas y clics facturados.
--
-- SECURITY DEFINER porque la RLS de ad_impressions solo deja a cada usuario ver
-- las suyas; aquí validamos que el llamante sea dueño del establecimiento
-- (o superadmin) y devolvemos el agregado.

CREATE OR REPLACE FUNCTION public.get_campaign_stats(p_establishment_id uuid)
RETURNS TABLE (campaign_id uuid, views bigint, clicks bigint)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT EXISTS (
        SELECT 1 FROM public.establishments e
        WHERE e.id = p_establishment_id AND e.owner_id = auth.uid()
      )
     AND COALESCE(
           (SELECT role FROM public.profiles WHERE id = auth.uid()), ''
         ) <> 'superadmin'
  THEN
    RAISE EXCEPTION 'No autorizado para ver estas estadísticas';
  END IF;

  RETURN QUERY
  SELECT c.id,
         COUNT(*) FILTER (WHERE i.type = 'impression')::bigint AS views,
         COUNT(*) FILTER (WHERE i.type = 'click')::bigint      AS clicks
  FROM   public.ad_campaigns c
  LEFT JOIN public.ad_impressions i ON i.campaign_id = c.id
  WHERE  c.establishment_id = p_establishment_id
  GROUP BY c.id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_campaign_stats(uuid) TO authenticated;
