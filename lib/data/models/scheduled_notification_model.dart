import 'package:equatable/equatable.dart';

/// Notificación programada para envío futuro (una vez o recurrente).
class ScheduledNotificationModel extends Equatable {
  final String    id;
  final String    title;
  final String    body;
  final Map<String, dynamic> filters;  // age_min, age_max, gender, inactive_days, …
  final DateTime  sendAt;
  final String?   recurrence;          // null | 'daily' | 'weekly' | 'monthly'
  final DateTime? nextSendAt;
  final String    status;              // 'pending' | 'active' | 'sent' | 'cancelled'
  final DateTime? lastSentAt;
  final int       runCount;
  final int       totalSent;
  final int       totalFailed;
  final DateTime  createdAt;

  const ScheduledNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.filters,
    required this.sendAt,
    this.recurrence,
    this.nextSendAt,
    required this.status,
    this.lastSentAt,
    required this.runCount,
    required this.totalSent,
    required this.totalFailed,
    required this.createdAt,
  });

  bool get isPending    => status == 'pending' || status == 'active';
  bool get isCancelled  => status == 'cancelled';
  bool get isSent       => status == 'sent';
  bool get isRecurring  => recurrence != null;

  String get recurrenceLabel {
    switch (recurrence) {
      case 'daily':   return 'Diaria';
      case 'weekly':  return 'Semanal';
      case 'monthly': return 'Mensual';
      default:        return 'Una vez';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pending':   return 'Pendiente';
      case 'active':    return 'Activa';
      case 'sent':      return 'Enviada';
      case 'cancelled': return 'Cancelada';
      default:          return status;
    }
  }

  factory ScheduledNotificationModel.fromJson(Map<String, dynamic> json) {
    return ScheduledNotificationModel(
      id:          json['id']          as String,
      title:       json['title']       as String,
      body:        json['body']        as String,
      filters:     (json['filters']    as Map<String, dynamic>?) ?? {},
      sendAt:      DateTime.parse(json['send_at'] as String).toLocal(),
      recurrence:  json['recurrence']  as String?,
      nextSendAt:  json['next_send_at'] != null
          ? DateTime.parse(json['next_send_at'] as String).toLocal()
          : null,
      status:      json['status']      as String,
      lastSentAt:  json['last_sent_at'] != null
          ? DateTime.parse(json['last_sent_at'] as String).toLocal()
          : null,
      runCount:    (json['run_count']   as num?)?.toInt() ?? 0,
      totalSent:   (json['total_sent']  as num?)?.toInt() ?? 0,
      totalFailed: (json['total_failed'] as num?)?.toInt() ?? 0,
      createdAt:   DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  @override
  List<Object?> get props => [id, status, runCount, totalSent];
}
