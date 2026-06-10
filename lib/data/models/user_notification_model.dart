/// Notificación del inbox in-app (campanita).
class UserNotification {
  final String              id;
  final String              title;
  final String?             body;
  final String?             type;
  final Map<String, dynamic> data;
  final DateTime?           readAt;
  final DateTime            createdAt;

  const UserNotification({
    required this.id,
    required this.title,
    this.body,
    this.type,
    this.data = const {},
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  factory UserNotification.fromJson(Map<String, dynamic> j) => UserNotification(
        id:        j['id'] as String,
        title:     j['title'] as String? ?? '',
        body:      j['body'] as String?,
        type:      j['type'] as String?,
        data:      (j['data'] as Map?)?.cast<String, dynamic>() ?? const {},
        readAt:    j['read_at'] != null ? DateTime.parse(j['read_at'] as String).toLocal() : null,
        createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
      );
}
