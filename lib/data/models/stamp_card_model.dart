import 'package:equatable/equatable.dart';

class StampCardModel extends Equatable {
  final String   id;
  final String   userId;
  final String   programId;
  final String   establishmentId;
  final String   establishmentName;
  final String?  establishmentLogo;
  final int      programVisits;
  final int      lifetimeVisits;
  final bool     rewardClaimed;
  // Info del programa (join)
  final int      visitsRequired;
  final String   rewardDescription;
  final DateTime programEndsAt;
  final bool     programIsActive;
  final DateTime createdAt;

  const StampCardModel({
    required this.id,
    required this.userId,
    required this.programId,
    required this.establishmentId,
    required this.establishmentName,
    this.establishmentLogo,
    required this.programVisits,
    required this.lifetimeVisits,
    required this.rewardClaimed,
    required this.visitsRequired,
    required this.rewardDescription,
    required this.programEndsAt,
    required this.programIsActive,
    required this.createdAt,
  });

  bool get rewardReady =>
      programVisits >= visitsRequired && !rewardClaimed;

  bool get programExpired => DateTime.now().isAfter(programEndsAt);

  int get stampsLeft =>
      (visitsRequired - programVisits).clamp(0, visitsRequired);

  StampCardModel copyWith({
    int?  programVisits,
    int?  lifetimeVisits,
    bool? rewardClaimed,
  }) {
    return StampCardModel(
      id:                id,
      userId:            userId,
      programId:         programId,
      establishmentId:   establishmentId,
      establishmentName: establishmentName,
      establishmentLogo: establishmentLogo,
      programVisits:     programVisits     ?? this.programVisits,
      lifetimeVisits:    lifetimeVisits    ?? this.lifetimeVisits,
      rewardClaimed:     rewardClaimed     ?? this.rewardClaimed,
      visitsRequired:    visitsRequired,
      rewardDescription: rewardDescription,
      programEndsAt:     programEndsAt,
      programIsActive:   programIsActive,
      createdAt:         createdAt,
    );
  }

  factory StampCardModel.fromJson(Map<String, dynamic> json) {
    final program = json['loyalty_programs'] as Map<String, dynamic>? ?? {};
    final est     = program['establishments'] as Map<String, dynamic>? ?? {};

    return StampCardModel(
      id:                json['id']               as String,
      userId:            json['user_id']           as String,
      programId:         json['program_id']        as String,
      establishmentId:   est['id']                 as String? ?? '',
      establishmentName: est['name']               as String? ?? '',
      establishmentLogo: est['logo_url']           as String?,
      programVisits:     (json['program_visits']   as int?) ?? 0,
      lifetimeVisits:    (json['lifetime_visits']  as int?) ?? 0,
      rewardClaimed:     (json['reward_claimed']   as bool?) ?? false,
      visitsRequired:    (program['visits_required']    as int?) ?? 1,
      rewardDescription: (program['reward_description'] as String?) ?? '',
      programEndsAt: DateTime.parse(
          program['ends_at'] as String? ?? DateTime.now().toIso8601String())
          .toLocal(),
      programIsActive: (program['is_active'] as bool?) ?? false,
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String())
          .toLocal(),
    );
  }

  @override
  List<Object?> get props => [
        id, programId, programVisits, lifetimeVisits, rewardClaimed,
      ];
}
