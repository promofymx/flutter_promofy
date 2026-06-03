import '../../../main.dart';
import '../../models/subscription_model.dart';

/// Datasource para operaciones de pago: llama Edge Functions de MercadoPago
/// y consulta el estado de suscripción del usuario autenticado.
class PlansPaymentDatasource {

  // ── Estado de suscripción ──────────────────────────────────────────────────

  Future<UserSubscriptionData> getMySubscription() async {
    final result = await supabase.rpc('get_my_subscription');
    return UserSubscriptionData.fromJson(result as Map<String, dynamic>);
  }

  // ── Crear suscripción (Edge Function) ─────────────────────────────────────

  /// Llama a mp-create-subscription y devuelve el init_point para abrir en WebView.
  Future<Map<String, String>> createSubscription({required int planId}) async {
    final result = await supabase.functions.invoke(
      'mp-create-subscription',
      body: {'plan_id': planId},
    );

    if (result.status != 200) {
      final err = (result.data as Map<String, dynamic>?)?['error']
          ?? 'Error al iniciar pago';
      throw Exception(err);
    }

    final data = result.data as Map<String, dynamic>;
    return {
      'init_point':     data['init_point']     as String,
      'preapproval_id': data['preapproval_id'] as String,
    };
  }

  // ── Crear preferencia add-on (Edge Function) ───────────────────────────────

  /// Llama a mp-create-preference y devuelve la URL de Checkout Pro.
  Future<Map<String, String>> createAddOnPreference({
    required String addOnType,
  }) async {
    final result = await supabase.functions.invoke(
      'mp-create-preference',
      body: {'add_on_type': addOnType},
    );

    if (result.status != 200) {
      final err = (result.data as Map<String, dynamic>?)?['error']
          ?? 'Error al iniciar pago del add-on';
      throw Exception(err);
    }

    final data = result.data as Map<String, dynamic>;
    return {
      'checkout_url':  data['checkout_url']  as String,
      'preference_id': data['preference_id'] as String,
    };
  }

  // ── Add-ons aprobados del usuario ──────────────────────────────────────────

  Future<List<AddOnPurchaseModel>> getMyAddOns() async {
    final rows = await supabase
        .from('add_on_purchases')
        .select()
        .eq('status', 'approved')
        .order('created_at', ascending: false);

    return (rows as List)
        .map((e) => AddOnPurchaseModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
