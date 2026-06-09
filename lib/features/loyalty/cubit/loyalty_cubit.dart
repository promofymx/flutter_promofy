import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/loyalty_repository.dart';
import 'loyalty_state.dart';

/// Gestiona el programa de lealtad desde el panel del dueño.
class LoyaltyCubit extends Cubit<LoyaltyState> {
  final LoyaltyRepository _repo;
  final String            _establishmentId;
  final String            _establishmentName;
  final String?           _establishmentLogo;

  LoyaltyCubit({
    required LoyaltyRepository repository,
    required String establishmentId,
    required String establishmentName,
    String? establishmentLogo,
  })  : _repo              = repository,
        _establishmentId   = establishmentId,
        _establishmentName = establishmentName,
        _establishmentLogo = establishmentLogo,
        super(LoyaltyInitial());

  // ── Carga ─────────────────────────────────────────────────────────────────

  Future<void> load() async {
    emit(LoyaltyLoading());
    try {
      final program = await _repo.getActiveProgram(
        establishmentId:   _establishmentId,
        establishmentName: _establishmentName,
        establishmentLogo: _establishmentLogo,
      );
      emit(LoyaltyLoaded(program: program));
      if (program != null) _loadCards(program.id);
    } catch (_) {
      emit(const LoyaltyError('No se pudo cargar el programa de lealtad.'));
    }
  }

  Future<void> _loadCards(String programId) async {
    try {
      final cards = await _repo.getCardsForProgram(programId);
      final s = state;
      if (s is LoyaltyLoaded) {
        emit(s.copyWith(cards: cards, cardsLoaded: true));
      }
    } catch (_) {
      final s = state;
      if (s is LoyaltyLoaded) emit(s.copyWith(cardsLoaded: true));
    }
  }

  // ── Crear programa ────────────────────────────────────────────────────────

  Future<bool> createProgram({
    required int      visitsRequired,
    required String   rewardDescription,
    required DateTime startsAt,
    required DateTime endsAt,
    bool   onePerDay          = false,
    double minTicketMxn       = 0,
    int    minHoursBetween    = 0,
    int    stampValidityDays  = 0,
    int    rewardValidityDays = 0,
  }) async {
    final prev = state;
    emit(LoyaltySaving());
    try {
      final program = await _repo.createProgram(
        establishmentId:   _establishmentId,
        establishmentName: _establishmentName,
        establishmentLogo: _establishmentLogo,
        visitsRequired:    visitsRequired,
        rewardDescription: rewardDescription,
        startsAt:          startsAt,
        endsAt:            endsAt,
        onePerDay:          onePerDay,
        minTicketMxn:       minTicketMxn,
        minHoursBetween:    minHoursBetween,
        stampValidityDays:  stampValidityDays,
        rewardValidityDays: rewardValidityDays,
      );
      emit(LoyaltyLoaded(program: program));
      return true;
    } catch (_) {
      emit(prev is LoyaltyLoaded ? prev : const LoyaltyLoaded());
      return false;
    }
  }

  // ── Desactivar programa ───────────────────────────────────────────────────

  Future<void> deactivateProgram() async {
    final s = state;
    if (s is! LoyaltyLoaded || s.program == null) return;
    final programId = s.program!.id;
    emit(LoyaltySaving());
    try {
      await _repo.deactivateProgram(programId);
      emit(s.copyWith(clearProgram: true, cards: [], cardsLoaded: false));
    } catch (_) {
      emit(s);
    }
  }

  // ── Registrar visita (tras escanear QR del cliente) ──────────────────────

  Future<void> recordVisit({
    required String clientId,
    double? ticketAmount,
  }) async {
    final s = state;
    if (s is! LoyaltyLoaded || s.program == null) return;

    try {
      final result = await _repo.recordVisit(
        programId:    s.program!.id,
        clientId:     clientId,
        ticketAmount: ticketAmount,
      );
      final ok = result['ok'] as bool? ?? false;
      emit(LoyaltyScanResult(
        ok:             ok,
        error:          ok ? null : result['error'] as String?,
        visitId:        result['visit_id'] as String?,
        programVisits:  result['program_visits']  as int?,
        lifetimeVisits: result['lifetime_visits'] as int?,
        visitsRequired: result['visits_required'] as int?,
        rewardReady:    (result['reward_ready']   as bool?) ?? false,
      ));
    } catch (_) {
      emit(const LoyaltyScanResult(ok: false, error: 'network_error'));
    }
  }

  /// Vuelve al estado LoyaltyLoaded tras mostrar el resultado del escaneo.
  void dismissScanResult() {
    load();
  }

  // ── Confirmar entrega de premio ───────────────────────────────────────────

  Future<void> claimReward(String clientId) async {
    final s = state;
    if (s is! LoyaltyLoaded || s.program == null) return;
    try {
      await _repo.claimReward(
        programId: s.program!.id,
        clientId:  clientId,
      );
      await _loadCards(s.program!.id);
    } catch (_) {}
  }

  // ── Recargar programa al cambiar establecimiento ──────────────────────────

  Future<void> reload({
    required String establishmentId,
    required String establishmentName,
    String? establishmentLogo,
  }) async {
    // Re-instanciar parámetros no es posible en Cubit (fields are final).
    // Llamamos directamente al datasource con los nuevos datos.
    emit(LoyaltyLoading());
    try {
      final program = await _repo.getActiveProgram(
        establishmentId:   establishmentId,
        establishmentName: establishmentName,
        establishmentLogo: establishmentLogo,
      );
      emit(LoyaltyLoaded(program: program));
      if (program != null) _loadCards(program.id);
    } catch (_) {
      emit(const LoyaltyError('No se pudo cargar el programa de lealtad.'));
    }
  }
}
