import '../../main.dart';
import '../models/admin_analytics_model.dart';

/// Analítica de superadmin (Fase 2).
class AdminAnalyticsRepository {
  Future<AdminAnalytics> getAnalytics() async {
    final res = await supabase.rpc('get_admin_analytics');
    final map = (res as Map).cast<String, dynamic>();
    if (map['error'] != null) throw Exception(map['error'].toString());
    return AdminAnalytics.fromJson(map);
  }

  /// Drill-down: establecimientos que componen un tipo (categoría).
  Future<List<({String name, int count, int? id})>> getTypeBreakdown(
    int categoryId,
    String metric, // 'favorites' | 'visits'
  ) async {
    final res = await supabase.rpc('get_admin_type_establishments', params: {
      'p_category_id': categoryId,
      'p_metric':      metric,
    });
    final map   = (res as Map).cast<String, dynamic>();
    final items = (map['items'] as List? ?? []);
    return items.map((e) {
      final m = (e as Map);
      return (
        name:  m['name'] as String? ?? '—',
        count: (m['count'] as num?)?.toInt() ?? 0,
        id:    null as int?,
      );
    }).toList();
  }
}
