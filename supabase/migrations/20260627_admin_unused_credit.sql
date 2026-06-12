-- Agrega al panel de superadmin el TOTAL de crédito sin uso:
--   • credit_unused: suma de ad_credits.balance_mxn (crédito de publicidad por
--     establecimiento que aún NO se ha gastado).
--   • wallet_unused: suma de profiles.ad_credits_mxn (cartera de usuarios por
--     referidos/promo que aún NO se ha aplicado a ningún local).
-- Ambos son "dinero pendiente de consumir" (pasivo de la plataforma).
-- Recrea get_admin_platform_metrics con esos 2 campos extra en el bloque campaigns.

CREATE OR REPLACE FUNCTION get_admin_platform_metrics()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN jsonb_build_object(
    'users', jsonb_build_object(
      'total',      (SELECT COUNT(*)::int FROM profiles),
      'by_role',    (SELECT COALESCE(jsonb_object_agg(role, cnt), '{}'::jsonb)
                     FROM (SELECT role, COUNT(*)::int AS cnt FROM profiles GROUP BY role) t),
      'new_today',  (SELECT COUNT(*)::int FROM profiles WHERE created_at >= CURRENT_DATE),
      'new_7d',     (SELECT COUNT(*)::int FROM profiles WHERE created_at >= NOW() - INTERVAL '7 days'),
      'new_15d',    (SELECT COUNT(*)::int FROM profiles WHERE created_at >= NOW() - INTERVAL '15 days'),
      'new_30d',    (SELECT COUNT(*)::int FROM profiles WHERE created_at >= NOW() - INTERVAL '30 days'),
      'active_7d',  (SELECT COUNT(*)::int FROM auth.users WHERE last_sign_in_at >= NOW() - INTERVAL '7 days'),
      'active_15d', (SELECT COUNT(*)::int FROM auth.users WHERE last_sign_in_at >= NOW() - INTERVAL '15 days'),
      'active_30d', (SELECT COUNT(*)::int FROM auth.users WHERE last_sign_in_at >= NOW() - INTERVAL '30 days')
    ),
    'establishments', jsonb_build_object(
      'total',   (SELECT COUNT(*)::int FROM establishments),
      'new_30d', (SELECT COUNT(*)::int FROM establishments WHERE created_at >= NOW() - INTERVAL '30 days')
    ),
    'promotions', jsonb_build_object(
      'active', (SELECT COUNT(*)::int FROM promotions WHERE is_active = true),
      'total',  (SELECT COUNT(*)::int FROM promotions)
    ),
    'loyalty', jsonb_build_object(
      'total_scans',   (SELECT COUNT(*)::int FROM loyalty_visit_log),
      'scans_30d',     (SELECT COUNT(*)::int FROM loyalty_visit_log
                        WHERE created_at >= NOW() - INTERVAL '30 days'),
      'total_revenue', (SELECT COALESCE(SUM(ticket_amount), 0)::numeric FROM loyalty_visit_log
                        WHERE ticket_amount IS NOT NULL AND ticket_amount > 0),
      'revenue_30d',   (SELECT COALESCE(SUM(ticket_amount), 0)::numeric FROM loyalty_visit_log
                        WHERE ticket_amount IS NOT NULL AND ticket_amount > 0
                          AND created_at >= NOW() - INTERVAL '30 days'),
      'avg_ticket',    (SELECT ROUND(AVG(ticket_amount)::numeric, 2) FROM loyalty_visit_log
                        WHERE ticket_amount IS NOT NULL AND ticket_amount > 0)
    ),
    'campaigns', jsonb_build_object(
      'active',           (SELECT COUNT(*)::int FROM ad_campaigns WHERE status = 'active'),
      'total',            (SELECT COUNT(*)::int FROM ad_campaigns),
      'spend_today',      (SELECT COALESCE(SUM(-amount_mxn), 0)::numeric FROM ad_credit_txns
                           WHERE type = 'impression_debit' AND amount_mxn < 0 AND created_at >= CURRENT_DATE),
      'spend_7d',         (SELECT COALESCE(SUM(-amount_mxn), 0)::numeric FROM ad_credit_txns
                           WHERE type = 'impression_debit' AND amount_mxn < 0 AND created_at >= NOW() - INTERVAL '7 days'),
      'spend_30d',        (SELECT COALESCE(SUM(-amount_mxn), 0)::numeric FROM ad_credit_txns
                           WHERE type = 'impression_debit' AND amount_mxn < 0 AND created_at >= NOW() - INTERVAL '30 days'),
      'credits_sold_30d', (SELECT COALESCE(SUM(amount_mxn), 0)::numeric FROM ad_credit_txns
                           WHERE type = 'purchase' AND created_at >= NOW() - INTERVAL '30 days'),
      -- NUEVO: crédito sin uso (pendiente de gastar)
      'credit_unused',    (SELECT COALESCE(SUM(balance_mxn), 0)::numeric FROM ad_credits),
      'wallet_unused',    (SELECT COALESCE(SUM(ad_credits_mxn), 0)::numeric
                           FROM profiles WHERE ad_credits_mxn > 0)
    ),
    'subscriptions', jsonb_build_object(
      'active',          (SELECT COUNT(*)::int FROM user_subscriptions WHERE status = 'authorized'),
      'new_30d',         (SELECT COUNT(*)::int FROM user_subscriptions
                          WHERE status = 'authorized' AND created_at >= NOW() - INTERVAL '30 days'),
      'monthly_revenue', (SELECT COALESCE(SUM(mp.price_mxn), 0)::numeric
                          FROM user_subscriptions us JOIN membership_plans mp ON mp.id = us.plan_id
                          WHERE us.status = 'authorized')
    )
  );
END;
$$;

REVOKE ALL ON FUNCTION get_admin_platform_metrics() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION get_admin_platform_metrics() TO service_role;
