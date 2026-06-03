-- ─────────────────────────────────────────────────────────────────────────────
-- Función: get_admin_platform_metrics
-- Devuelve un JSON con todas las métricas globales de la plataforma.
-- Solo debe llamarse desde cuentas con role = 'admin'.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION get_admin_platform_metrics()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN jsonb_build_object(

    -- ── Usuarios ─────────────────────────────────────────────────────────────
    'users', jsonb_build_object(
      'total',      (SELECT COUNT(*)::int FROM profiles),
      'by_role',    (
                      SELECT COALESCE(jsonb_object_agg(role, cnt), '{}'::jsonb)
                      FROM (
                        SELECT role, COUNT(*)::int AS cnt
                        FROM profiles
                        GROUP BY role
                      ) t
                    ),
      'new_today',  (SELECT COUNT(*)::int FROM profiles
                     WHERE created_at >= CURRENT_DATE),
      'new_7d',     (SELECT COUNT(*)::int FROM profiles
                     WHERE created_at >= NOW() - INTERVAL '7 days'),
      'new_15d',    (SELECT COUNT(*)::int FROM profiles
                     WHERE created_at >= NOW() - INTERVAL '15 days'),
      'new_30d',    (SELECT COUNT(*)::int FROM profiles
                     WHERE created_at >= NOW() - INTERVAL '30 days'),
      'active_7d',  (SELECT COUNT(*)::int FROM auth.users
                     WHERE last_sign_in_at >= NOW() - INTERVAL '7 days'),
      'active_15d', (SELECT COUNT(*)::int FROM auth.users
                     WHERE last_sign_in_at >= NOW() - INTERVAL '15 days'),
      'active_30d', (SELECT COUNT(*)::int FROM auth.users
                     WHERE last_sign_in_at >= NOW() - INTERVAL '30 days')
    ),

    -- ── Establecimientos ─────────────────────────────────────────────────────
    'establishments', jsonb_build_object(
      'total',    (SELECT COUNT(*)::int FROM establishments),
      'new_30d',  (SELECT COUNT(*)::int FROM establishments
                   WHERE created_at >= NOW() - INTERVAL '30 days')
    ),

    -- ── Promociones ──────────────────────────────────────────────────────────
    'promotions', jsonb_build_object(
      'active',   (SELECT COUNT(*)::int FROM promotions WHERE is_active = true),
      'total',    (SELECT COUNT(*)::int FROM promotions)
    ),

    -- ── Lealtad / QR scans ────────────────────────────────────────────────────
    -- stamp_cards.program_visits = total de visitas por tarjeta
    -- loyalty_visits = registros individuales de cada escaneo
    'loyalty', jsonb_build_object(
      'total_scans',   (SELECT COALESCE(SUM(program_visits), 0)::int
                        FROM stamp_cards),
      'scans_30d',     (SELECT COUNT(*)::int FROM loyalty_visits
                        WHERE created_at >= NOW() - INTERVAL '30 days'),
      'total_revenue', (SELECT COALESCE(SUM(ticket_amount), 0)::numeric
                        FROM loyalty_visits
                        WHERE ticket_amount IS NOT NULL AND ticket_amount > 0),
      'revenue_30d',   (SELECT COALESCE(SUM(ticket_amount), 0)::numeric
                        FROM loyalty_visits
                        WHERE ticket_amount IS NOT NULL AND ticket_amount > 0
                          AND created_at >= NOW() - INTERVAL '30 days'),
      'avg_ticket',    (SELECT ROUND(AVG(ticket_amount)::numeric, 2)
                        FROM loyalty_visits
                        WHERE ticket_amount IS NOT NULL AND ticket_amount > 0)
    ),

    -- ── Campañas publicitarias ────────────────────────────────────────────────
    -- ad_credit_txns.type = 'impression_debit' → gasto en campañas (amount < 0)
    -- ad_credit_txns.type = 'purchase'         → créditos comprados (amount > 0)
    'campaigns', jsonb_build_object(
      'active',           (SELECT COUNT(*)::int FROM ad_campaigns
                           WHERE status = 'active'),
      'total',            (SELECT COUNT(*)::int FROM ad_campaigns),
      'spend_today',      (SELECT COALESCE(SUM(-amount_mxn), 0)::numeric
                           FROM ad_credit_txns
                           WHERE type = 'impression_debit'
                             AND amount_mxn < 0
                             AND created_at >= CURRENT_DATE),
      'spend_7d',         (SELECT COALESCE(SUM(-amount_mxn), 0)::numeric
                           FROM ad_credit_txns
                           WHERE type = 'impression_debit'
                             AND amount_mxn < 0
                             AND created_at >= NOW() - INTERVAL '7 days'),
      'spend_30d',        (SELECT COALESCE(SUM(-amount_mxn), 0)::numeric
                           FROM ad_credit_txns
                           WHERE type = 'impression_debit'
                             AND amount_mxn < 0
                             AND created_at >= NOW() - INTERVAL '30 days'),
      'credits_sold_30d', (SELECT COALESCE(SUM(amount_mxn), 0)::numeric
                           FROM ad_credit_txns
                           WHERE type = 'purchase'
                             AND created_at >= NOW() - INTERVAL '30 days')
    ),

    -- ── Suscripciones ────────────────────────────────────────────────────────
    'subscriptions', jsonb_build_object(
      'active',          (SELECT COUNT(*)::int FROM user_subscriptions
                          WHERE status = 'authorized'),
      'new_30d',         (SELECT COUNT(*)::int FROM user_subscriptions
                          WHERE status = 'authorized'
                            AND created_at >= NOW() - INTERVAL '30 days'),
      'monthly_revenue', (
                           SELECT COALESCE(SUM(mp.price_mxn), 0)::numeric
                           FROM user_subscriptions us
                           JOIN membership_plans mp ON mp.id = us.plan_id
                           WHERE us.status = 'authorized'
                         )
    )

  );
END;
$$;

-- Revocar acceso público; solo admins (service_role o SECURITY DEFINER)
REVOKE ALL ON FUNCTION get_admin_platform_metrics() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION get_admin_platform_metrics() TO service_role;
