import 'package:equatable/equatable.dart';

class NotificationLogModel extends Equatable {
  final String   id;
  final String   title;
  final String   body;
  final String   targetType;   // 'broadcast' | 'flash_promo'
  final int      sentCount;
  final int      failedCount;
  final int      openCount;    // apertura por tap en la notificación
  final DateTime createdAt;

  const NotificationLogModel({
    required this.id,
    required this.title,
    required this.body,
    required this.targetType,
    required this.sentCount,
    required this.failedCount,
    this.openCount = 0,
    required this.createdAt,
  });

  factory NotificationLogModel.fromJson(Map<String, dynamic> json) {
    return NotificationLogModel(
      id:          json['id']           as String,
      title:       json['title']        as String,
      body:        json['body']         as String,
      targetType:  json['target_type']  as String? ?? 'broadcast',
      sentCount:   (json['sent_count']   as num?)?.toInt() ?? 0,
      failedCount: (json['failed_count'] as num?)?.toInt() ?? 0,
      openCount:   (json['open_count']   as num?)?.toInt() ?? 0,
      createdAt:   DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  String get targetLabel =>
      targetType == 'flash_promo' ? '⚡ Flash' : '📢 Broadcast';

  /// Tasa de entrega (0–100)
  double get deliveryRate {
    final total = sentCount + failedCount;
    if (total == 0) return 0;
    return sentCount / total * 100;
  }

  /// Tasa de apertura (0–100)
  double get openRate {
    if (sentCount == 0) return 0;
    return openCount / sentCount * 100;
  }

  @override
  List<Object?> get props =>
      [id, title, body, targetType, sentCount, failedCount, openCount, createdAt];
}
