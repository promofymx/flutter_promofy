import '../datasources/supabase/membership_plans_datasource.dart';
import '../datasources/supabase/plans_payment_datasource.dart';
import '../models/membership_plan_model.dart';
import '../models/subscription_model.dart';

/// Repositorio unificado: lista de planes + operaciones de pago/suscripción.
class PlansRepository {
  final MembershipPlansDatasource _plansDs;
  final PlansPaymentDatasource    _paymentDs;

  PlansRepository({
    MembershipPlansDatasource? plansDs,
    PlansPaymentDatasource?    paymentDs,
  })  : _plansDs   = plansDs   ?? MembershipPlansDatasource(),
        _paymentDs = paymentDs ?? PlansPaymentDatasource();

  // ── Planes ─────────────────────────────────────────────────────────────────

  Future<List<MembershipPlanModel>> getPlans() => _plansDs.getPlans();

  // ── Suscripción actual ─────────────────────────────────────────────────────

  Future<UserSubscriptionData> getMySubscription() =>
      _paymentDs.getMySubscription();

  // ── Pago: suscripción ──────────────────────────────────────────────────────

  Future<Map<String, String>> createSubscription({
    required int planId,
    String? discountCode,
  }) =>
      _paymentDs.createSubscription(planId: planId, discountCode: discountCode);

  Future<Map<String, dynamic>> previewDiscount({
    required String code,
    required int planId,
  }) =>
      _paymentDs.previewDiscount(code: code, planId: planId);

  // ── Pago: add-ons ──────────────────────────────────────────────────────────

  Future<Map<String, String>> createAddOnPreference({
    required String addOnType,
  }) =>
      _paymentDs.createAddOnPreference(addOnType: addOnType);

  Future<List<AddOnPurchaseModel>> getMyAddOns() =>
      _paymentDs.getMyAddOns();

  // ── Add-ons recurrentes (suscripción mensual) ──────────────────────────────

  Future<Map<String, String>> createAddonSubscription({
    required String addOnType,
  }) =>
      _paymentDs.createAddonSubscription(addOnType: addOnType);

  Future<void> cancelAddonSubscription(String id) =>
      _paymentDs.cancelAddonSubscription(id);

  Future<List<Map<String, dynamic>>> getMyAddonSubscriptions() =>
      _paymentDs.getMyAddonSubscriptions();

  Future<List<Map<String, dynamic>>> getMyActivePromotions() =>
      _paymentDs.getMyActivePromotions();

  Future<void> deactivatePromotion(String promoId) =>
      _paymentDs.deactivatePromotion(promoId);
}
