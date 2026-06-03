-- ═══════════════════════════════════════════════════════════════════════════════
-- PROMOFY · Promociones de Cumpleaños
-- ═══════════════════════════════════════════════════════════════════════════════
-- 1. Añade columnas birthday_gift / birthday_terms a promotions
-- 2. Crea RPC get_birthday_promotions (misma firma de salida que get_promotions_by_distance)
-- 3. Añade plantillas de notificación para cumpleaños
-- 4. Crea cron diario que llama a la edge function send-birthday-notifications
-- ═══════════════════════════════════════════════════════════════════════════════

-- ── 1. Columnas nuevas en promotions ─────────────────────────────────────────
ALTER TABLE public.promotions
  ADD COLUMN IF NOT EXISTS birthday_gift  TEXT,
  ADD COLUMN IF NOT EXISTS birthday_terms TEXT;

-- ── 2. RPC para listar promos de cumpleaños por distancia ─────────────────────
CREATE OR REPLACE FUNCTION public.get_birthday_promotions(
  user_lat        DOUBLE PRECISION,
  user_lng        DOUBLE PRECISION,
  page_number     INT              DEFAULT 0,
  page_size       INT              DEFAULT 20,
  radius_km       DOUBLE PRECISION DEFAULT 25.0,
  current_user_id UUID             DEFAULT NULL
)
RETURNS TABLE (
  id                  UUID,
  establishment_id    UUID,
  establishment_name  TEXT,
  establishment_logo  TEXT,
  name                TEXT,
  description         TEXT,
  active_days         INT[],
  start_time          TEXT,
  end_time            TEXT,
  is_adult_only       BOOLEAN,
  type                TEXT,
  flash_starts_at     TIMESTAMPTZ,
  flash_ends_at       TIMESTAMPTZ,
  photo_url           TEXT,
  distance_meters     DOUBLE PRECISION,
  favorites_count     INT,
  avg_rating          DOUBLE PRECISION,
  is_favorited        BOOLEAN,
  is_featured         BOOLEAN,
  category_id         INT,
  category_name       TEXT,
  created_at          TIMESTAMPTZ,
  birthday_gift       TEXT,
  birthday_terms      TEXT
)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT
    p.id,
    p.establishment_id,
    e.name                                    AS establishment_name,
    e.logo_url                                AS establishment_logo,
    p.name,
    COALESCE(p.description, '')               AS description,
    p.active_days,
    p.start_time::TEXT,
    p.end_time::TEXT,
    COALESCE(p.is_adult_only, false)          AS is_adult_only,
    p.type,
    p.flash_starts_at,
    p.flash_ends_at,
    p.photo_url,
    ST_Distance(
      e.location::geography,
      ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography
    )                                         AS distance_meters,
    (
      SELECT COUNT(*)::INT
      FROM   user_favorite_promotions ufp
      WHERE  ufp.promotion_id = p.id
    )                                         AS favorites_count,
    NULL::DOUBLE PRECISION                    AS avg_rating,
    CASE
      WHEN current_user_id IS NOT NULL THEN
        EXISTS (
          SELECT 1 FROM user_favorite_promotions ufp2
          WHERE  ufp2.promotion_id = p.id
            AND  ufp2.user_id = current_user_id
        )
      ELSE false
    END                                       AS is_favorited,
    COALESCE(p.is_featured, false)            AS is_featured,
    p.category_id,
    NULL::TEXT                                AS category_name,
    p.created_at,
    p.birthday_gift,
    p.birthday_terms
  FROM  public.promotions     p
  JOIN  public.establishments e ON e.id = p.establishment_id
  WHERE p.type       = 'birthday'
    AND p.is_active  = true
    AND e.is_active  = true
    AND ST_DWithin(
          e.location::geography,
          ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography,
          radius_km * 1000
        )
  ORDER BY distance_meters ASC
  LIMIT  page_size
  OFFSET page_number * page_size;
$$;

GRANT EXECUTE ON FUNCTION public.get_birthday_promotions(
  DOUBLE PRECISION, DOUBLE PRECISION, INT, INT, DOUBLE PRECISION, UUID
) TO authenticated, anon, service_role;

-- ── 3. Plantillas de notificación de cumpleaños ───────────────────────────────
INSERT INTO public.notification_templates (promo_type, title, body, sort_order)
VALUES
  ('birthday', '¡Felicidades! 🎂',
   '¡Hoy es tu día! Mira todos los lugares que te quieren consentir 🎁',
   1),
  ('birthday', '¡Happy Birthday! 🎉',
   'Los negocios cerca de ti tienen algo especial para ti hoy 🥳',
   2)
ON CONFLICT DO NOTHING;

-- ── 4. Cron diario: 9 AM hora Ciudad de México (UTC-6 → 15:00 UTC) ────────────
-- Requiere extensiones pg_cron + pg_net habilitadas en el proyecto Supabase.
SELECT cron.schedule(
  'promofy-birthday-notifications',   -- nombre único del job
  '0 15 * * *',                       -- 09:00 CDMX (UTC-6)
  $$
  SELECT net.http_post(
    url     := 'https://hfmvelirrcawsxaudhfl.supabase.co/functions/v1/send-birthday-notifications',
    headers := jsonb_build_object(
      'Content-Type',  'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmbXZlbGlycmNhd3N4YXVkaGZsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3OTkwNzA3OSwiZXhwIjoyMDk1NDgzMDc5fQ.J06Du6hcZ4i4BrpBnDv_65p_QquXZcGy8QRnBjxq818'
    ),
    body    := '{}'::jsonb
  ) AS request_id;
  $$
);
