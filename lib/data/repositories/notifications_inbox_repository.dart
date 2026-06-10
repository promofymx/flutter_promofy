import '../../main.dart';
import '../models/user_notification_model.dart';

/// Inbox de notificaciones in-app (campanita).
class NotificationsInboxRepository {
  Future<List<UserNotification>> getNotifications({int limit = 50}) async {
    final res = await supabase
        .from('user_notifications')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return (res as List)
        .map((e) => UserNotification.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<int> unreadCount() async {
    try {
      final res = await supabase.rpc('my_unread_notifications_count');
      return (res as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> markAllRead() async {
    await supabase.rpc('mark_all_notifications_read');
  }

  Future<void> markRead(String id) async {
    await supabase
        .from('user_notifications')
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id);
  }
}
