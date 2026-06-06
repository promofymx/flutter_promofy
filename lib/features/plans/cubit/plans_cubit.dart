import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/plans_repository.dart';
import 'plans_state.dart';

class PlansCubit extends Cubit<PlansState> {
  final PlansRepository _repo;

  PlansCubit({PlansRepository? repository})
      : _repo = repository ?? PlansRepository(),
        super(const PlansInitial());

  // ── Carga inicial ──────────────────────────────────────────────────────────

  Future<void> load() async {
    emit(const PlansLoading());
    try {
      final results = await Future.wait([
        _repo.getPlans(),
        _repo.getMySubscription(),
        _repo.getMyAddOns(),
        _repo.getMyAddonSubscriptions(),
      ]);

      emit(PlansLoaded(
        plans:              results[0] as dynamic,
        subscription:       results[1] as dynamic,
        addOns:             results[2] as dynamic,
        addonSubscriptions: results[3] as List<Map<String, dynamic>>,
      ));
    } catch (e) {
      emit(PlansError('No se pudieron cargar los planes: $e'));
    }
  }

  // ── Refrescar solo la suscripción (tras volver del WebView) ───────────────

  Future<void> refreshSubscription() async {
    final current = state;
    if (current is! PlansLoaded) return;
    try {
      final sub = await _repo.getMySubscription();
      emit(current.copyWith(subscription: sub));
    } catch (_) {/* silencioso */}
  }

  // ── Iniciar pago: plan (suscripción) ──────────────────────────────────────

  Future<void> subscribeToPlan(int planId) async {
    final current = state;
    if (current is! PlansLoaded) return;

    emit(current.copyWith(isProcessing: true));
    try {
      final result = await _repo.createSubscription(planId: planId);
      emit(PlansPaymentReady(
        checkoutUrl: result['init_point']!,
        type:        'subscription',
        loaded:      current.copyWith(isProcessing: false),
      ));
    } catch (e) {
      emit(current.copyWith(isProcessing: false));
      rethrow; // la pantalla muestra el snackbar
    }
  }

  // ── Iniciar pago: add-on ───────────────────────────────────────────────────

  Future<void> purchaseAddOn(String addOnType) async {
    final current = state;
    if (current is! PlansLoaded) return;

    emit(current.copyWith(isProcessing: true));
    try {
      // Add-on como suscripción mensual recurrente (preapproval).
      final result = await _repo.createAddonSubscription(addOnType: addOnType);
      emit(PlansPaymentReady(
        checkoutUrl: result['init_point']!,
        type:        'addon',
        loaded:      current.copyWith(isProcessing: false),
      ));
    } catch (e) {
      emit(current.copyWith(isProcessing: false));
      rethrow;
    }
  }

  // ── Cancelar un add-on (suscripción mensual) ──────────────────────────────

  /// Promos activas del usuario (para que elija cuáles desactivar al cancelar).
  Future<List<Map<String, dynamic>>> activePromotions() =>
      _repo.getMyActivePromotions();

  /// Desactiva las promos elegidas (si quedó sobre el límite) y cancela el add-on.
  Future<void> cancelAddon(
    String addOnSubscriptionId, {
    List<String> deactivatePromoIds = const [],
  }) async {
    final current = state;
    if (current is! PlansLoaded) return;
    emit(current.copyWith(isProcessing: true));
    try {
      for (final pid in deactivatePromoIds) {
        await _repo.deactivatePromotion(pid);
      }
      await _repo.cancelAddonSubscription(addOnSubscriptionId);
      final subs = await _repo.getMyAddonSubscriptions();
      emit(current.copyWith(addonSubscriptions: subs, isProcessing: false));
    } catch (e) {
      emit(current.copyWith(isProcessing: false));
      rethrow;
    }
  }

  // ── Restaurar estado cargado (tras cerrar WebView sin pagar) ─────────────

  void restoreLoaded(PlansLoaded loaded) => emit(loaded);
}
