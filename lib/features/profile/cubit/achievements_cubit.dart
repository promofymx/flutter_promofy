import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../main.dart';
import '../../../data/models/user_stats_model.dart';
import 'achievements_state.dart';

/// Carga las estadísticas de gamificación de un usuario
/// (visitas anuales, racha, top %, insignia actual).
class AchievementsCubit extends Cubit<AchievementsState> {
  final String userId;

  AchievementsCubit({required this.userId}) : super(AchievementsInitial());

  Future<void> load() async {
    if (isClosed) return;
    emit(AchievementsLoading());
    try {
      final result = await supabase.rpc(
        'get_user_profile_stats',
        params: {'p_user_id': userId},
      );
      if (isClosed) return;
      final data = result as Map<String, dynamic>;
      if (data.containsKey('error')) {
        emit(AchievementsLoaded(UserStatsModel.empty()));
        return;
      }
      emit(AchievementsLoaded(UserStatsModel.fromJson(data)));
    } catch (_) {
      if (!isClosed) emit(AchievementsError());
    }
  }
}
