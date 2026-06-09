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
  // ── Reglas configurables (0/false = regla apagada) ──
  final bool   onePerDay;          // máx. 1 sello por día por cliente
  final double minTicketMxn;       // consumo mínimo para sellar
  final int    minHoursBetween;    // horas mínimas entre sellos
  final int    stampValidityDays;  // vencen los sellos en curso
  final int    rewardValidityDays; // vence la recompensa lista

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
    this.onePerDay          = false,
    this.minTicketMxn       = 0,
    this.minHoursBetween    = 0,
    this.stampValidityDays  = 0,
    this.rewardValidityDays = 0,
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
      onePerDay:          (json['one_per_day'] as bool?) ?? false,
      minTicketMxn:       (json['min_ticket_mxn'] as num?)?.toDouble() ?? 0,
      minHoursBetween:    (json['min_hours_between'] as int?) ?? 0,
      stampValidityDays:  (json['stamp_validity_days'] as int?) ?? 0,
      rewardValidityDays: (json['reward_validity_days'] as int?) ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id, establishmentId, visitsRequired, rewardDescription,
        startsAt, endsAt, isActive,
        onePerDay, minTicketMxn, minHoursBetween,
        stampValidityDays, rewardValidityDays,
      ];
}
