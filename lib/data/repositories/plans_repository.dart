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

  Future<Map<String, String>> createSubscription({required int planId}) =>
      _paymentDs.createSubscription(planId: planId);

  // ── Pago: add-ons ──────────────────────────────────────────────────────────

  Future<Map<String, String>> createAddOnPreference({
    required String addOnType,
  }) =>
      _paymentDs.createAddOnPreference(addOnType: addOnType);

  Future<List<AddOnPurchaseModel>> getMyAddOns() =>
      _paymentDs.getMyAddOns();
}
