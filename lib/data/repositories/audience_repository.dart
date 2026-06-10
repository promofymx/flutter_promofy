import '../../main.dart';
import '../models/audience_stats_model.dart';

/// Estadísticas de audiencia del dueño (Fase 1: "Mi audiencia").
class AudienceRepository {
  Future<AudienceStats> getOwnerAudience(String establishmentId) async {
    final res = await supabase.rpc(
      'get_owner_audience_stats',
      params: {'p_establishment_id': establishmentId},
    );
    final map = (res as Map).cast<String, dynamic>();
    if (map['error'] != null) {
      throw Exception(map['error'].toString());
    }
    return AudienceStats.fromJson(map);
  }
}
