import '../datasources/supabase/membership_plans_datasource.dart';
import '../models/addon_pricing_model.dart';
import '../models/membership_plan_model.dart';

class MembershipPlansRepository {
  final MembershipPlansDatasource _datasource;

  MembershipPlansRepository({MembershipPlansDatasource? datasource})
      : _datasource = datasource ?? MembershipPlansDatasource();

  Future<List<MembershipPlanModel>> getPlans() => _datasource.getPlans();

  Future<MembershipPlanModel?> getPlanById(int id) => _datasource.getPlanById(id);

  Future<void> updatePlan(MembershipPlanModel plan) => _datasource.updatePlan(plan);

  Future<List<Map<String, dynamic>>> getBusinessOwnersForAdmin() =>
      _datasource.getBusinessOwnersForAdmin();

  Future<void> assignPlanToUser(String userId, int planId) =>
      _datasource.assignPlanToUser(userId, planId);

  // ── Add-ons ───────────────────────────────────────────────────────────────

  Future<List<AddonPricingModel>> getAddonPricing() =>
      _datasource.getAddonPricing();

  Future<AddonPricingModel> updateAddonPricing({
    required int    id,
    required double priceMxn,
  }) => _datasource.updateAddonPricing(id: id, priceMxn: priceMxn);
}
