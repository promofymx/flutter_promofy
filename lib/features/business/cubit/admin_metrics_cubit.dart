import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/stats_repository.dart';
import 'admin_metrics_state.dart';

class AdminMetricsCubit extends Cubit<AdminMetricsState> {
  final StatsRepository _repo;

  AdminMetricsCubit({StatsRepository? repository})
      : _repo = repository ?? StatsRepository(),
        super(AdminMetricsInitial());

  Future<void> load() async {
    emit(AdminMetricsLoading());
    try {
      final metrics = await _repo.getAdminPlatformMetrics();
      if (!isClosed) emit(AdminMetricsLoaded(metrics));
    } catch (e) {
      if (!isClosed) {
        emit(AdminMetricsError('No se pudieron cargar las métricas: $e'));
      }
    }
  }

  Future<void> refresh() => load();
}
