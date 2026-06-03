import 'package:equatable/equatable.dart';

class LoyaltyProgramModel extends Equatable {
  final String   id;
  final String   establishmentId;
  final String   establishmentName;
  final String?  establishmentLogo;
  final int      visitsRequired;
  final String   rewardDescription;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool     isActive;
  final DateTime createdAt;

  const LoyaltyProgramModel({
    required this.id,
    required this.establishmentId,
    required this.establishmentName,
    this.establishmentLogo,
    required this.visitsRequired,
    required this.rewardDescription,
    required this.startsAt,
    required this.endsAt,
    required this.isActive,
    required this.createdAt,
  });

  bool get isExpired  => DateTime.now().isAfter(endsAt);
  bool get isOngoing  => isActive && !isExpired;

  /// Días restantes (0 si ya expiró).
  int get daysLeft {
    final diff = endsAt.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  factory LoyaltyProgramModel.fromJson(
    Map<String, dynamic> json, {
    required String establishmentName,
    String? establishmentLogo,
  }) {
    return LoyaltyProgramModel(
      id:                 json['id']                 as String,
      establishmentId:    json['establishment_id']   as String,
      establishmentName:  establishmentName,
      establishmentLogo:  establishmentLogo,
      visitsRequired:     json['visits_required']    as int,
      rewardDescription:  json['reward_description'] as String,
      startsAt:  DateTime.parse(json['starts_at'] as String).toLocal(),
      endsAt:    DateTime.parse(json['ends_at']   as String).toLocal(),
      isActive:  (json['is_active'] as bool?) ?? true,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  @override
  List<Object?> get props => [
        id, establishmentId, visitsRequired, rewardDescription,
        startsAt, endsAt, isActive,
      ];
}
