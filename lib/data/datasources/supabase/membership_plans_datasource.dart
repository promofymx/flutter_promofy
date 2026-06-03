import '../../../main.dart';
import '../../models/addon_pricing_model.dart';
import '../../models/membership_plan_model.dart';

class MembershipPlansDatasource {
  // ── Planes ────────────────────────────────────────────────────────────────

  Future<List<MembershipPlanModel>> getPlans() async {
    final response = await supabase
        .from('membership_plans')
        .select()
        .order('sort_order');
    return (response as List)
        .map((e) => MembershipPlanModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MembershipPlanModel?> getPlanById(int id) async {
    final response = await supabase
        .from('membership_plans')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return MembershipPlanModel.fromJson(response);
  }

  Future<void> updatePlan(MembershipPlanModel plan) async {
    await supabase
        .from('membership_plans')
        .update({
          'price_mxn':          plan.priceMxn,
          'max_establishments': plan.maxEstablishments,
          'max_promotions':     plan.maxPromotions,
        })
        .eq('id', plan.id);
  }

  // ── Usuarios dueños (solo superadmin) ─────────────────────────────────────

  /// Devuelve perfiles con rol business_owner/admin + email + conteo.
  /// Usa la RPC SECURITY DEFINER para acceder a auth.users.
  Future<List<Map<String, dynamic>>> getBusinessOwnersForAdmin() async {
    final result = await supabase.rpc('get_owners_for_admin');
    return (result as List).cast<Map<String, dynamic>>();
  }

  Future<void> assignPlanToUser(String userId, int planId) async {
    await supabase
        .from('profiles')
        .update({'plan_id': planId})
        .eq('id', userId);
  }

  // ── Add-ons ───────────────────────────────────────────────────────────────

  Future<List<AddonPricingModel>> getAddonPricing() async {
    final response = await supabase
        .from('addon_pricing')
        .select()
        .order('id');
    return (response as List)
        .map((e) => AddonPricingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AddonPricingModel> updateAddonPricing({
    required int    id,
    required double priceMxn,
  }) async {
    final response = await supabase
        .from('addon_pricing')
        .update({
          'price_mxn':  priceMxn,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return AddonPricingModel.fromJson(response);
  }
}
