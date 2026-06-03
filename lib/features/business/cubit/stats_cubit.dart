import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/audience_model.dart';
import '../../../data/repositories/stats_repository.dart';
import 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final StatsRepository _repo;
  final String          _ownerId;
  String?               _establishmentId;

  StatsCubit({
    required StatsRepository repository,
    required String          ownerId,
    String?                  establishmentId,
  })  : _repo           = repository,
        _ownerId         = ownerId,
        _establishmentId = establishmentId,
        super(StatsInitial());

  // ── Carga de estadísticas ─────────────────────────────────────────────────

  Future<void> load({int days = 30, String? establishmentId}) async {
    if (establishmentId != null) _establishmentId = establishmentId;

    // Si tenemos establishmentId, consultamos por establecimiento.
    // Esto funciona tanto para dueños (sucursal específica) como para
    // gerentes (cuyo ownerId es su propio userId y no el del dueño).
    final estId = _establishmentId;
    final useEst = estId != null && estId.isNotEmpty;

    if (!useEst && _ownerId.isEmpty) return;

    emit(StatsLoading());
    try {
      final stats = await _repo.getBusinessStats(
        ownerId:         useEst ? null : _ownerId,
        establishmentId: useEst ? estId  : null,
        days:            days,
      );

      AudienceModel? audience;
      if (estId != null && estId.isNotEmpty) {
        audience = await _repo.getAudienceDemographics(estId);
      }
      emit(StatsLoaded(stats, audience: audience));
    } catch (_) {
      emit(const StatsError('No se pudieron cargar las estadísticas.'));
    }
  }

  // ── Actualiza el ticket de una visita de lealtad ──────────────────────────

  Future<void> updateVisitTicket({
    required String visitId,
    required double amount,
  }) async {
    try {
      await _repo.updateVisitTicket(visitId: visitId, amount: amount);
    } catch (_) {}
  }
}
