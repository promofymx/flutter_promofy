import 'package:equatable/equatable.dart';
import '../../../data/models/ad_pricing_model.dart';
import '../../../data/models/addon_pricing_model.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/characteristic_model.dart';
import '../../../data/models/membership_plan_model.dart';
import '../../../data/models/notification_log_model.dart';
import '../../../data/models/scheduled_notification_model.dart';

// ─── Modelo ligero: usuario dueño de negocios ─────────────────────────────────

class AdminUserEntry extends Equatable {
  final String id;
  final String displayName;   // full_name o ID corto si aún no completó onboarding
  final String email;
  final int    planId;
  final String planName;
  final int    estCount;      // establecimientos registrados

  const AdminUserEntry({
    required this.id,
    required this.displayName,
    required this.email,
    required this.planId,
    required this.planName,
    required this.estCount,
  });

  AdminUserEntry copyWith({int? planId, String? planName}) => AdminUserEntry(
    id:          id,
    displayName: displayName,
    email:       email,
    planId:      planId   ?? this.planId,
    planName:    planName ?? this.planName,
    estCount:    estCount,
  );

  @override
  List<Object?> get props => [id, displayName, email, planId, planName, estCount];
}

// ─── States ──────────────────────────────────────────────────────────────────

abstract class SuperadminState extends Equatable {
  const SuperadminState();
  @override
  List<Object?> get props => [];
}

class SuperadminInitial extends SuperadminState {
  const SuperadminInitial();
}

class SuperadminLoading extends SuperadminState {
  const SuperadminLoading();
}

class SuperadminLoaded extends SuperadminState {
  final List<MembershipPlanModel>          plans;
  final List<AdminUserEntry>               users;
  final List<CategoryModel>                categories;
  final List<CharacteristicModel>          characteristics;
  final List<NotificationLogModel>         notificationLogs;
  final List<ScheduledNotificationModel>   scheduledNotifications;
  final Map<String, int>                   deviceStats;
  final List<Map<String, dynamic>>         dailyStats;  // [{day, sent_count, open_count}]
  final List<AdPricingModel>               adPricing;
  final int                                totalUserCount;
  final List<AddonPricingModel>            addonPricing;

  const SuperadminLoaded({
    required this.plans,
    required this.users,
    this.categories              = const [],
    this.characteristics         = const [],
    this.notificationLogs        = const [],
    this.scheduledNotifications  = const [],
    this.deviceStats             = const {},
    this.dailyStats              = const [],
    this.adPricing               = const [],
    this.totalUserCount          = 0,
    this.addonPricing            = const [],
  });

  SuperadminLoaded copyWith({
    List<MembershipPlanModel>?         plans,
    List<AdminUserEntry>?              users,
    List<CategoryModel>?               categories,
    List<CharacteristicModel>?         characteristics,
    List<NotificationLogModel>?        notificationLogs,
    List<ScheduledNotificationModel>?  scheduledNotifications,
    Map<String, int>?                  deviceStats,
    List<Map<String, dynamic>>?        dailyStats,
    List<AdPricingModel>?              adPricing,
    int?                               totalUserCount,
    List<AddonPricingModel>?           addonPricing,
  }) =>
      SuperadminLoaded(
        plans:                   plans                  ?? this.plans,
        users:                   users                  ?? this.users,
        categories:              categories             ?? this.categories,
        characteristics:         characteristics        ?? this.characteristics,
        notificationLogs:        notificationLogs       ?? this.notificationLogs,
        scheduledNotifications:  scheduledNotifications ?? this.scheduledNotifications,
        deviceStats:             deviceStats            ?? this.deviceStats,
        dailyStats:              dailyStats             ?? this.dailyStats,
        adPricing:               adPricing              ?? this.adPricing,
        totalUserCount:          totalUserCount         ?? this.totalUserCount,
        addonPricing:            addonPricing           ?? this.addonPricing,
      );

  int    get totalDevices    => deviceStats.values.fold(0, (a, b) => a + b);
  int    get totalSentAll    => notificationLogs.fold(0, (s, l) => s + l.sentCount);
  double get avgDeliveryRate {
    if (notificationLogs.isEmpty) return 0;
    return notificationLogs.map((l) => l.deliveryRate).reduce((a, b) => a + b) /
        notificationLogs.length;
  }
  double get avgOpenRate {
    final valid = notificationLogs.where((l) => l.sentCount > 0).toList();
    if (valid.isEmpty) return 0;
    return valid.map((l) => l.openRate).reduce((a, b) => a + b) / valid.length;
  }

  @override
  List<Object?> get props => [
    plans, users, categories, characteristics,
    notificationLogs, scheduledNotifications, deviceStats, dailyStats,
    adPricing, totalUserCount, addonPricing,
  ];
}

class SuperadminError extends SuperadminState {
  final String message;
  const SuperadminError(this.message);
  @override
  List<Object?> get props => [message];
}
