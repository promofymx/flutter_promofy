import 'package:intl/intl.dart';

// ─── Progreso en el programa actual ──────────────────────────────────────────

class LoyaltyClientProgressModel {
  final String  userId;
  final String  clientName;
  final int     programVisits;
  final int     visitsRequired;
  final bool    rewardReady;

  const LoyaltyClientProgressModel({
    required this.userId,
    required this.clientName,
    required this.programVisits,
    required this.visitsRequired,
    required this.rewardReady,
  });

  double get progress =>
      (programVisits / visitsRequired).clamp(0.0, 1.0);

  int get stampsLeft =>
      (visitsRequired - programVisits).clamp(0, visitsRequired);

  factory LoyaltyClientProgressModel.fromJson(
    Map<String, dynamic> json, {
    required int visitsRequired,
  }) {
    return LoyaltyClientProgressModel(
      userId:         json['user_id']        as String,
      clientName:     json['client_name']    as String? ?? 'Cliente',
      programVisits:  (json['program_visits'] as num?)?.toInt() ?? 0,
      visitsRequired: visitsRequired,
      rewardReady:    (json['reward_ready']  as bool?) ?? false,
    );
  }
}

// ─── Historial de comensales ──────────────────────────────────────────────────

class LoyaltyClientHistoryModel {
  final String    userId;
  final String    clientName;
  final int       totalVisits;
  final double?   totalSpent;
  final DateTime? lastVisit;

  const LoyaltyClientHistoryModel({
    required this.userId,
    required this.clientName,
    required this.totalVisits,
    this.totalSpent,
    this.lastVisit,
  });

  static final _moneyFmt = NumberFormat.currency(
    locale: 'es_MX', symbol: '\$', decimalDigits: 0,
  );
  static final _dateFmt = DateFormat('dd/MM/yy', 'es_MX');

  String get formattedSpent =>
      totalSpent != null && totalSpent! > 0
          ? _moneyFmt.format(totalSpent!)
          : '—';

  String get formattedLastVisit =>
      lastVisit != null ? _dateFmt.format(lastVisit!) : '—';

  factory LoyaltyClientHistoryModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyClientHistoryModel(
      userId:      json['user_id']     as String,
      clientName:  json['client_name'] as String? ?? 'Cliente',
      totalVisits: (json['total_visits'] as num?)?.toInt() ?? 0,
      totalSpent:  (json['total_spent']  as num?)?.toDouble(),
      lastVisit:   json['last_visit'] != null
          ? DateTime.parse(json['last_visit'] as String).toLocal()
          : null,
    );
  }
}

// ─── Contenedor de ambas tablas ───────────────────────────────────────────────

class LoyaltyClientsData {
  final int                              visitsRequired;
  final List<LoyaltyClientProgressModel> currentProgram;
  final List<LoyaltyClientHistoryModel>  historical;

  const LoyaltyClientsData({
    required this.visitsRequired,
    required this.currentProgram,
    required this.historical,
  });

  factory LoyaltyClientsData.fromJson(Map<String, dynamic> json) {
    final vr = (json['visits_required'] as num?)?.toInt() ?? 1;

    final rawCurrent = json['current_program'] as List<dynamic>? ?? [];
    final rawHist    = json['historical']      as List<dynamic>? ?? [];

    return LoyaltyClientsData(
      visitsRequired: vr,
      currentProgram: rawCurrent
          .whereType<Map<String, dynamic>>()
          .map((e) => LoyaltyClientProgressModel.fromJson(e, visitsRequired: vr))
          .toList(),
      historical: rawHist
          .whereType<Map<String, dynamic>>()
          .map(LoyaltyClientHistoryModel.fromJson)
          .toList(),
    );
  }
}
