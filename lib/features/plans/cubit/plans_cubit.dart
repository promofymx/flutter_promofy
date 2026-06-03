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
      ]);

      emit(PlansLoaded(
        plans:        results[0] as dynamic,
        subscription: results[1] as dynamic,
        addOns:       results[2] as dynamic,
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
      final result = await _repo.createAddOnPreference(addOnType: addOnType);
      emit(PlansPaymentReady(
        checkoutUrl: result['checkout_url']!,
        type:        'addon',
        loaded:      current.copyWith(isProcessing: false),
      ));
    } catch (e) {
      emit(current.copyWith(isProcessing: false));
      rethrow;
    }
  }

  // ── Restaurar estado cargado (tras cerrar WebView sin pagar) ─────────────

  void restoreLoaded(PlansLoaded loaded) => emit(loaded);
}
