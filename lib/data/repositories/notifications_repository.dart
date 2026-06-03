import '../../main.dart';
import '../models/notification_log_model.dart';
import '../models/scheduled_notification_model.dart';

class NotificationsRepository {
  // ── Historial ──────────────────────────────────────────────────────────────

  Future<List<NotificationLogModel>> getLogs({int limit = 50}) async {
    final rows = await supabase
        .from('notification_logs')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((e) => NotificationLogModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Estadísticas ───────────────────────────────────────────────────────────

  Future<Map<String, int>> getDeviceStats() async {
    final result = await supabase.rpc('get_device_stats');
    final rows   = result as List;
    final stats  = <String, int>{};
    for (final row in rows) {
      stats[row['platform'] as String] = (row['count'] as num).toInt();
    }
    return stats;
  }

  /// Estadísticas diarias de los últimos 30 días para la gráfica.
  Future<List<Map<String, dynamic>>> getDailyStats() async {
    final result = await supabase.rpc('get_notification_daily_stats');
    return (result as List).cast<Map<String, dynamic>>();
  }

  // ── Broadcast ─────────────────────────────────────────────────────────────

  /// Envía a TODOS o a un segmento si se pasan filtros.
  Future<({int sent, int failed})> sendBroadcast({
    required String title,
    required String body,
    required String sentBy,
    Map<String, dynamic> filters = const {},
  }) async {
    final response = await supabase.functions.invoke(
      'send-broadcast-notification',
      body: {
        'title':    title,
        'body':     body,
        'sent_by':  sentBy,
        'filters':  filters,
      },
    );
    final data   = response.data as Map<String, dynamic>;
    final sent   = (data['sent']   as num?)?.toInt() ?? 0;
    final failed = (data['failed'] as num?)?.toInt() ?? 0;
    return (sent: sent, failed: failed);
  }

  // ── Conteo de destinatarios (preview) ─────────────────────────────────────

  Future<int> countRecipients(Map<String, dynamic> filters) async {
    final result = await supabase.rpc('count_notification_recipients', params: {
      'p_gender':              filters['gender'],
      'p_age_min':             filters['age_min'],
      'p_age_max':             filters['age_max'],
      'p_inactive_days':       filters['inactive_days'],
      'p_establishment_id':    filters['establishment_id'],
      'p_platform':            filters['platform'],
      'p_characteristic_ids':  filters['characteristic_ids'],
    });
    return (result as num?)?.toInt() ?? 0;
  }

  // ── Notificaciones programadas ─────────────────────────────────────────────

  Future<List<ScheduledNotificationModel>> getScheduled() async {
    final rows = await supabase
        .from('scheduled_notifications')
        .select()
        .neq('status', 'cancelled')
        .order('send_at', ascending: true);
    return (rows as List)
        .map((e) => ScheduledNotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ScheduledNotificationModel> createScheduled({
    required String title,
    required String body,
    required DateTime sendAt,
    String? recurrence,
    Map<String, dynamic> filters = const {},
    String? createdBy,
  }) async {
    final row = await supabase
        .from('scheduled_notifications')
        .insert({
          'title':       title,
          'body':        body,
          'send_at':     sendAt.toUtc().toIso8601String(),
          'next_send_at': sendAt.toUtc().toIso8601String(),
          'recurrence':  recurrence,
          'filters':     filters,
          'status':      'pending',
          'created_by':  createdBy,
        })
        .select()
        .single();
    return ScheduledNotificationModel.fromJson(row);
  }

  Future<void> cancelScheduled(String id) async {
    await supabase
        .from('scheduled_notifications')
        .update({'status': 'cancelled'})
        .eq('id', id);
  }

  // ── Stats por establecimiento (para dueños) ────────────────────────────────

  Future<List<NotificationLogModel>> getEstablishmentLogs(
    String establishmentId, {
    int days = 30,
  }) async {
    final rows = await supabase.rpc(
      'get_establishment_notification_stats',
      params: {
        'p_establishment_id': establishmentId,
        'p_days':             days,
      },
    );
    return (rows as List)
        .map((e) => NotificationLogModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Registro de apertura ───────────────────────────────────────────────────

  Future<void> recordOpen({
    required String notificationLogId,
    required String userId,
  }) async {
    // ON CONFLICT DO NOTHING — solo registra la primera apertura por usuario
    await supabase.from('notification_opens').upsert({
      'notification_log_id': notificationLogId,
      'user_id':             userId,
    }, onConflict: 'notification_log_id,user_id');
  }
}
