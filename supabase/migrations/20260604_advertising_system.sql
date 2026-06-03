-- ═══════════════════════════════════════════════════════════════════════════
-- Sistema de publicidad Promofy — Puja mínima + Relevancia
--
-- Puntaje final por campaña:
--   score = distancia(40%) + categorías(35%) + créditos(25%)
--
-- Tablas:
--   ad_pricing       — precios por formato (admin configurable)
--   ad_credits       — saldo de créditos por establecimiento
--   ad_credit_txns   — historial de movimientos de crédito
--   ad_campaigns     — campañas publicitarias
--   ad_impressions   — tracking de impresiones y clics
--
-- RPCs:
--   get_ads_for_user(p_lat, p_lng, p_format, p_limit)  → scored ad list
--   record_ad_impression(p_campaign_id, p_type)         → debit + tracking
--   admin_add_credit(p_establishment_id, ...)           → credit + reactivate
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── Extensión de distancia (haversine puro, sin PostGIS) ────────────────────
CREATE OR REPLACE FUNCTION public.haversine_km(
  lat1 float8, lng1 float8,
  lat2 float8, lng2 float8
)
RETURNS float8
LANGUAGE sql IMMUTABLE STRICT AS $$
  SELECT 6371.0 * 2 * asin(sqrt(
    sin(radians(lat2 - lat1) / 2) ^ 2
    + cos(radians(lat1)) * cos(radians(lat2))
      * sin(radians(lng2 - lng1) / 2) ^ 2
  ))
$$;


-- ─── 1. Tabla: ad_pricing ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.ad_pricing (
  id             serial      PRIMARY KEY,
  format         text        NOT NULL UNIQUE
                             CHECK (format IN ('splash','banner','featured_list','push','flash')),
  label          text        NOT NULL,
  billing_type   text        NOT NULL DEFAULT 'cpm'
                             CHECK (billing_type IN ('cpm','per_send','flat_rate')),
  price_mxn      numeric(10,4) NOT NULL,   -- costo por impresión individual
  min_budget_mxn numeric(10,2) NOT NULL,
  updated_at     timestamptz NOT NULL DEFAULT now()
);

-- Seed de precios iniciales (idempotente)
INSERT INTO public.ad_pricing (format, label, billing_type, price_mxn, min_budget_mxn)
VALUES
  ('splash',        'Splash (pantalla completa)', 'cpm',       0.10,  50.00),
  ('banner',        'Banner',                     'cpm',       0.03,  20.00),
  ('featured_list', 'Destacada en lista',         'cpm',       0.05,  30.00),
  ('push',          'Notificación push',          'per_send',  0.50,  30.00),
  ('flash',         'Promo Relámpago',            'flat_rate', 25.00, 25.00)
ON CONFLICT (format) DO NOTHING;

ALTER TABLE public.ad_pricing ENABLE ROW LEVEL SECURITY;
CREATE POLICY "superadmin_manage_pricing" ON public.ad_pricing
  FOR ALL TO authenticated
  USING   ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'superadmin')
  WITH CHECK ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'superadmin');
CREATE POLICY "anyone_read_pricing" ON public.ad_pricing
  FOR SELECT TO authenticated USING (true);


-- ─── 2. Tabla: ad_credits ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.ad_credits (
  id               uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  establishment_id uuid        NOT NULL UNIQUE
                               REFERENCES public.establishments(id) ON DELETE CASCADE,
  balance_mxn      numeric(12,2) NOT NULL DEFAULT 0 CHECK (balance_mxn >= 0),
  updated_at       timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.ad_credits ENABLE ROW LEVEL SECURITY;
-- El dueño del establecimiento puede ver su propio saldo
CREATE POLICY "owner_read_credits" ON public.ad_credits
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.establishments e
      WHERE e.id = establishment_id AND e.owner_id = auth.uid()
    )
  );
-- Superadmin todo
CREATE POLICY "superadmin_all_credits" ON public.ad_credits
  FOR ALL TO authenticated
  USING   ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'superadmin')
  WITH CHECK ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'superadmin');


-- ─── 3. Tabla: ad_credit_txns ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.ad_credit_txns (
  id               uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  establishment_id uuid        NOT NULL REFERENCES public.establishments(id) ON DELETE CASCADE,
  amount_mxn       numeric(12,2) NOT NULL,    -- positivo = carga, negativo = débito
  type             text        NOT NULL
                               CHECK (type IN ('purchase','impression_debit','refund','manual_admin')),
  reference_id     text,       -- campaign_id para impression_debit, mp payment id para purchase
  note             text,
  created_at       timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ad_credit_txns_est  ON public.ad_credit_txns(establishment_id, created_at DESC);

ALTER TABLE public.ad_credit_txns ENABLE ROW LEVEL SECURITY;
CREATE POLICY "owner_read_txns" ON public.ad_credit_txns
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.establishments e
      WHERE e.id = establishment_id AND e.owner_id = auth.uid()
    )
  );
CREATE POLICY "superadmin_all_txns" ON public.ad_credit_txns
  FOR ALL TO authenticated
  USING   ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'superadmin')
  WITH CHECK ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'superadmin');


-- ─── 4. Tabla: ad_campaigns ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.ad_campaigns (
  id                   uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  establishment_id     uuid        NOT NULL REFERENCES public.establishments(id) ON DELETE CASCADE,
  created_by           uuid        REFERENCES auth.users(id) ON DELETE SET NULL,
  name                 text        NOT NULL,
  format               text        NOT NULL
                                   CHECK (format IN ('splash','banner','featured_list','push','flash')),
  status               text        NOT NULL DEFAULT 'draft'
                                   CHECK (status IN ('draft','active','paused','completed','cancelled')),
  budget_mxn           numeric(12,2) NOT NULL CHECK (budget_mxn > 0),
  spent_mxn            numeric(12,2) NOT NULL DEFAULT 0 CHECK (spent_mxn >= 0),
  -- Segmentación geográfica
  radius_km            int         NOT NULL DEFAULT 5 CHECK (radius_km BETWEEN 1 AND 50),
  geo_mode             text        NOT NULL DEFAULT 'both'
                                   CHECK (geo_mode IN ('physical_location','search_area','both')),
  -- Segmentación demográfica
  target_category_ids  int[]       NOT NULL DEFAULT '{}',
  target_min_age       int         NOT NULL DEFAULT 0,
  target_max_age       int         NOT NULL DEFAULT 99,
  target_gender        text        NOT NULL DEFAULT 'all'
                                   CHECK (target_gender IN ('all','male','female')),
  -- Referencia opcional a una promoción concreta
  promotion_id         uuid        REFERENCES public.promotions(id) ON DELETE SET NULL,
  -- Vigencia
  start_date           date,
  end_date             date,
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ad_campaigns_est    ON public.ad_campaigns(establishment_id);
CREATE INDEX IF NOT EXISTS idx_ad_campaigns_active ON public.ad_campaigns(status, format)
  WHERE status = 'active';

ALTER TABLE public.ad_campaigns ENABLE ROW LEVEL SECURITY;
CREATE POLICY "owner_manage_campaigns" ON public.ad_campaigns
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.establishments e
      WHERE e.id = establishment_id AND e.owner_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.establishments e
      WHERE e.id = establishment_id AND e.owner_id = auth.uid()
    )
  );
CREATE POLICY "users_read_active_campaigns" ON public.ad_campaigns
  FOR SELECT TO authenticated
  USING (status = 'active');
CREATE POLICY "superadmin_all_campaigns" ON public.ad_campaigns
  FOR ALL TO authenticated
  USING   ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'superadmin')
  WITH CHECK ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'superadmin');


-- ─── 5. Tabla: ad_impressions ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.ad_impressions (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id uuid        NOT NULL REFERENCES public.ad_campaigns(id) ON DELETE CASCADE,
  user_id     uuid        REFERENCES auth.users(id) ON DELETE SET NULL,
  type        text        NOT NULL CHECK (type IN ('impression','click')),
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ad_impressions_campaign ON public.ad_impressions(campaign_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ad_impressions_user     ON public.ad_impressions(user_id, created_at DESC);

ALTER TABLE public.ad_impressions ENABLE ROW LEVEL SECURITY;
-- Solo SECURITY DEFINER RPCs escriben aquí; usuarios solo leen sus propias
CREATE POLICY "users_read_own_impressions" ON public.ad_impressions
  FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY "superadmin_all_impressions" ON public.ad_impressions
  FOR ALL TO authenticated
  USING   ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'superadmin')
  WITH CHECK ((SELECT role FROM public.profiles WHERE id = auth.uid()) = 'superadmin');


-- ════════════════════════════════════════════════════════════════════════════
-- RPC 1: get_ads_for_user
--   Selecciona y rankea campañas activas para el usuario actual usando el
--   modelo de relevancia: distancia(40%) + categorías(35%) + créditos(25%)
-- ════════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.get_ads_for_user(
  p_lat    float8 DEFAULT NULL,
  p_lng    float8 DEFAULT NULL,
  p_format text   DEFAULT NULL,   -- NULL = todos los formatos visuales
  p_limit  int    DEFAULT 5
)
RETURNS TABLE (
  id               uuid,
  establishment_id uuid,
  format           text,
  establishment_name text,
  photo_url        text,
  score            float8
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id uuid := auth.uid();
BEGIN
  RETURN QUERY
  WITH

  -- ── Categorías de interés del usuario (últimos 90 días) ──────────────────
  user_cats AS (
    SELECT DISTINCT unnest(e2.category_ids) AS cat_id
    FROM   coupon_redemptions cr
    JOIN   promotions         pr ON pr.id = cr.promotion_id
    JOIN   establishments     e2 ON e2.id = pr.establishment_id
    WHERE  cr.user_id      = v_user_id
      AND  cr.redeemed_at >= now() - interval '90 days'
  ),

  -- ── Campañas candidatas (activas, con crédito, dentro de vigencia) ────────
  candidates AS (
    SELECT
      c.id,
      c.establishment_id,
      c.format,
      c.radius_km,
      c.target_category_ids,
      c.budget_mxn - c.spent_mxn  AS remaining_budget,
      e.name                       AS establishment_name,
      e.photo_url,
      e.lat                        AS est_lat,
      e.lng                        AS est_lng,
      COALESCE(ac.balance_mxn, 0)  AS balance_mxn
    FROM   ad_campaigns c
    JOIN   establishments e   ON e.id  = c.establishment_id
    LEFT JOIN ad_credits  ac  ON ac.establishment_id = c.establishment_id
    JOIN   ad_pricing     ap  ON ap.format = c.format
    WHERE  c.status = 'active'
      AND  (p_format IS NULL OR c.format = p_format)
      AND  (c.start_date IS NULL OR c.start_date <= current_date)
      AND  (c.end_date   IS NULL OR c.end_date   >= current_date)
      AND  COALESCE(ac.balance_mxn, 0) >= ap.price_mxn
  ),

  -- ── Score por factor ──────────────────────────────────────────────────────
  scored AS (
    SELECT
      cand.*,

      -- Factor distancia (0–100)
      CASE
        WHEN p_lat IS NULL OR p_lng IS NULL
          OR cand.est_lat IS NULL OR cand.est_lng IS NULL
          THEN 50.0
        WHEN haversine_km(p_lat, p_lng, cand.est_lat, cand.est_lng) >= cand.radius_km
          THEN 0.0
        ELSE GREATEST(0.0,
          (1.0 - haversine_km(p_lat, p_lng, cand.est_lat, cand.est_lng)
                 / cand.radius_km) * 100.0
        )
      END AS dist_score,

      -- Factor categoría (0–100)
      CASE
        WHEN array_length(cand.target_category_ids, 1) IS NULL
          THEN 50.0  -- sin filtro → neutral
        ELSE LEAST(100.0,
          (SELECT COUNT(*)::float8
           FROM   unnest(cand.target_category_ids) t(cat)
           WHERE  t.cat IN (SELECT cat_id FROM user_cats)
          ) / array_length(cand.target_category_ids, 1) * 100.0
        )
      END AS cat_score,

      -- Factor créditos disponibles (normalizado dentro del pool, 0–100)
      CASE
        WHEN MAX(cand.balance_mxn) OVER () = 0 THEN 0.0
        ELSE cand.balance_mxn / MAX(cand.balance_mxn) OVER () * 100.0
      END AS credits_score

    FROM candidates cand
  )

  SELECT
    s.id,
    s.establishment_id,
    s.format,
    s.establishment_name,
    s.photo_url,
    ROUND((s.dist_score * 0.40 + s.cat_score * 0.35 + s.credits_score * 0.25)::numeric, 4)::float8
      AS score
  FROM scored s
  ORDER BY (s.dist_score * 0.40 + s.cat_score * 0.35 + s.credits_score * 0.25) DESC
  LIMIT p_limit;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_ads_for_user TO authenticated;


-- ════════════════════════════════════════════════════════════════════════════
-- RPC 2: record_ad_impression
--   Registra impresión o clic. Para impresiones: descuenta crédito y pausa
--   la campaña si el saldo llega a 0.
-- ════════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.record_ad_impression(
  p_campaign_id uuid,
  p_type        text DEFAULT 'impression'   -- 'impression' | 'click'
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id    uuid := auth.uid();
  v_campaign   public.ad_campaigns%ROWTYPE;
  v_pricing    public.ad_pricing%ROWTYPE;
  v_new_balance numeric;
BEGIN
  -- Cargar campaña activa
  SELECT * INTO v_campaign
  FROM   public.ad_campaigns
  WHERE  id = p_campaign_id AND status = 'active';
  IF NOT FOUND THEN RETURN; END IF;

  -- ── Solo las impresiones tienen costo ──────────────────────────────────────
  IF p_type = 'impression' THEN

    SELECT * INTO v_pricing
    FROM   public.ad_pricing
    WHERE  format = v_campaign.format;
    IF NOT FOUND THEN RETURN; END IF;

    -- Verificar y descontar crédito atómicamente
    UPDATE public.ad_credits
    SET    balance_mxn = balance_mxn - v_pricing.price_mxn,
           updated_at  = now()
    WHERE  establishment_id = v_campaign.establishment_id
      AND  balance_mxn      >= v_pricing.price_mxn
    RETURNING balance_mxn INTO v_new_balance;

    IF NOT FOUND THEN
      -- Sin crédito suficiente → pausar campaña y salir
      UPDATE public.ad_campaigns
      SET status = 'paused', updated_at = now()
      WHERE id = p_campaign_id;
      RETURN;
    END IF;

    -- Actualizar gasto en campaña
    UPDATE public.ad_campaigns
    SET    spent_mxn  = spent_mxn + v_pricing.price_mxn,
           updated_at = now()
    WHERE  id = p_campaign_id;

    -- Registrar transacción de débito
    INSERT INTO public.ad_credit_txns
      (establishment_id, amount_mxn, type, reference_id, note)
    VALUES (
      v_campaign.establishment_id,
      -v_pricing.price_mxn,
      'impression_debit',
      p_campaign_id::text,
      'Impresión: ' || v_campaign.name
    );

    -- Pausar si el nuevo saldo ya no cubre otra impresión
    IF v_new_balance < v_pricing.price_mxn THEN
      UPDATE public.ad_campaigns
      SET status = 'paused', updated_at = now()
      WHERE id = p_campaign_id;
    END IF;

  END IF;

  -- Registrar impresión / clic (ambos se guardan)
  INSERT INTO public.ad_impressions (campaign_id, user_id, type)
  VALUES (p_campaign_id, v_user_id, p_type);

END;
$$;

GRANT EXECUTE ON FUNCTION public.record_ad_impression TO authenticated;


-- ════════════════════════════════════════════════════════════════════════════
-- RPC 3: admin_add_credit
--   Agrega crédito a un establecimiento y reactiva campañas pausadas
--   que aún tengan presupuesto disponible.
-- ════════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.admin_add_credit(
  p_establishment_id uuid,
  p_amount_mxn       numeric,
  p_description      text    DEFAULT 'Recarga de créditos publicitarios',
  p_added_by         text    DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Upsert saldo del establecimiento
  INSERT INTO public.ad_credits (establishment_id, balance_mxn)
  VALUES (p_establishment_id, p_amount_mxn)
  ON CONFLICT (establishment_id)
  DO UPDATE SET
    balance_mxn = public.ad_credits.balance_mxn + p_amount_mxn,
    updated_at  = now();

  -- Registrar transacción
  INSERT INTO public.ad_credit_txns
    (establishment_id, amount_mxn, type, note)
  VALUES (
    p_establishment_id,
    p_amount_mxn,
    CASE WHEN p_added_by IS NOT NULL THEN 'manual_admin' ELSE 'purchase' END,
    p_description
  );

  -- Reactivar campañas pausadas con presupuesto restante
  UPDATE public.ad_campaigns
  SET    status     = 'active',
         updated_at = now()
  WHERE  establishment_id = p_establishment_id
    AND  status           = 'paused'
    AND  (budget_mxn - spent_mxn) > 0;
END;
$$;

-- Solo superadmin o sistema interno pueden llamar admin_add_credit
GRANT EXECUTE ON FUNCTION public.admin_add_credit TO service_role;
REVOKE EXECUTE ON FUNCTION public.admin_add_credit FROM authenticated;
-- El superadmin lo llama a través de la Edge Function mp-webhook (service_role)
-- o desde el panel superadmin (también service_role via Supabase admin client)
