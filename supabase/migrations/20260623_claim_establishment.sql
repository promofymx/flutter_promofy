-- ════════════════════════════════════════════════════════════════════════════
-- Siembra de prospección + "Reclamar negocio".
--   • Columnas: place_id (dedup + match), claim_email (correo del prospecto),
--     seeded_at, claimed_at.
--   • "Sin reclamar" = owner_id IS NULL.
--   • get_claimable_establishment(place_id) → datos públicos para la pantalla.
--   • claim_establishment(id) → enlaza la cuenta del dueño si está sin reclamar.
-- ════════════════════════════════════════════════════════════════════════════

ALTER TABLE public.establishments
  ADD COLUMN IF NOT EXISTS place_id    text,
  ADD COLUMN IF NOT EXISTS claim_email text,
  ADD COLUMN IF NOT EXISTS seeded_at   timestamptz,
  ADD COLUMN IF NOT EXISTS claimed_at  timestamptz;

-- Evita sembrar el mismo lugar dos veces (permite varios NULL).
CREATE UNIQUE INDEX IF NOT EXISTS establishments_place_id_uniq
  ON public.establishments(place_id) WHERE place_id IS NOT NULL;

-- ── Datos mínimos para la pantalla "reclamar" (búsqueda por Place ID) ──────────
CREATE OR REPLACE FUNCTION public.get_claimable_establishment(p_place_id text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE r record;
BEGIN
  SELECT id, name, street, owner_id
    INTO r
  FROM public.establishments
  WHERE place_id = p_place_id
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('found', false);
  END IF;

  RETURN jsonb_build_object(
    'found',   true,
    'id',      r.id,
    'name',    r.name,
    'address', r.street,
    'claimed', (r.owner_id IS NOT NULL)
  );
END;
$$;

-- ── El dueño reclama su negocio ───────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.claim_establishment(p_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid   uuid := auth.uid();
  v_owner uuid;
  v_name  text;
BEGIN
  IF v_uid IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', 'no_auth');
  END IF;

  SELECT owner_id, name INTO v_owner, v_name
  FROM public.establishments
  WHERE id = p_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', 'no_encontrado');
  END IF;

  IF v_owner IS NOT NULL THEN
    IF v_owner = v_uid THEN
      RETURN jsonb_build_object('ok', true, 'name', v_name, 'already_mine', true);
    END IF;
    RETURN jsonb_build_object('ok', false, 'error', 'ya_reclamado');
  END IF;

  UPDATE public.establishments
     SET owner_id = v_uid,
         is_admin_managed = false,
         claimed_at = now()
   WHERE id = p_id;

  -- Marca el perfil como dueño de negocio (si era consumidor).
  UPDATE public.profiles
     SET role = 'business_owner'
   WHERE id = v_uid
     AND COALESCE(role, '') NOT IN ('business_owner', 'admin', 'superadmin');

  RETURN jsonb_build_object('ok', true, 'name', v_name);
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_claimable_establishment(text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.claim_establishment(uuid)         TO authenticated;
