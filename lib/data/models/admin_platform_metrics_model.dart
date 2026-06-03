import 'package:equatable/equatable.dart';

/// Métricas globales de la plataforma — solo visibles para el rol 'admin'.
class AdminPlatformMetrics extends Equatable {

  // ── Usuarios ────────────────────────────────────────────────────────────────
  final int total;
  final int userCount;         // role = 'user'
  final int staffCount;        // role = 'staff'
  final int ownerCount;        // role = 'business_owner'
  final int adminCount;        // role = 'admin'

  final int newToday;
  final int new7d;
  final int new15d;
  final int new30d;

  final int active7d;
  final int active15d;
  final int active30d;

  // ── Establecimientos & Promos ────────────────────────────────────────────────
  final int totalEstablishments;
  final int newEstablishments30d;
  final int activePromotions;
  final int totalPromotions;

  // ── Lealtad / QR ──────────────────────────────────────────────────────────
  final int    totalQrScans;
  final int    qrScans30d;
  final double totalTicketRevenue;   // suma de tickets subidos por meseros
  final double ticketRevenue30d;
  final double avgTicket;

  // ── Campañas ──────────────────────────────────────────────────────────────
  final int    activeCampaigns;
  final int    totalCampaigns;
  final double campaignSpendToday;
  final double campaignSpend7d;
  final double campaignSpend30d;
  final double creditsSold30d;       // ingresos de recarga de créditos

  // ── Suscripciones ─────────────────────────────────────────────────────────
  final int    activeSubscriptions;
  final int    newSubscriptions30d;
  final double monthlyRevenue;       // MRR de suscripciones activas

  const AdminPlatformMetrics({
    required this.total,
    required this.userCount,
    required this.staffCount,
    required this.ownerCount,
    required this.adminCount,
    required this.newToday,
    required this.new7d,
    required this.new15d,
    required this.new30d,
    required this.active7d,
    required this.active15d,
    required this.active30d,
    required this.totalEstablishments,
    required this.newEstablishments30d,
    required this.activePromotions,
    required this.totalPromotions,
    required this.totalQrScans,
    required this.qrScans30d,
    required this.totalTicketRevenue,
    required this.ticketRevenue30d,
    required this.avgTicket,
    required this.activeCampaigns,
    required this.totalCampaigns,
    required this.campaignSpendToday,
    required this.campaignSpend7d,
    required this.campaignSpend30d,
    required this.creditsSold30d,
    required this.activeSubscriptions,
    required this.newSubscriptions30d,
    required this.monthlyRevenue,
  });

  // ── Métricas derivadas ───────────────────────────────────────────────────────

  /// Ingresos totales de la plataforma en los últimos 30 días.
  double get totalRevenue30d => monthlyRevenue + creditsSold30d;

  /// CPM (costo por 1 000 impresiones) si se tienen datos de campaigns.
  /// Si no hay gasto, retorna 0.
  double get roas {
    if (campaignSpend30d <= 0) return 0;
    // Ingresos plataforma 30d / gasto en campañas 30d
    return totalRevenue30d / campaignSpend30d;
  }

  // ── fromJson ────────────────────────────────────────────────────────────────

  factory AdminPlatformMetrics.fromJson(Map<String, dynamic> json) {
    int    i(String k, [Map<String, dynamic>? src]) =>
        ((src ?? json)[k] as num?)?.toInt()    ?? 0;
    double d(String k, [Map<String, dynamic>? src]) =>
        ((src ?? json)[k] as num?)?.toDouble() ?? 0.0;
    Map<String, dynamic> sub(String k) =>
        (json[k] as Map<String, dynamic>?) ?? {};

    final u    = sub('users');
    final e    = sub('establishments');
    final p    = sub('promotions');
    final ly   = sub('loyalty');
    final c    = sub('campaigns');
    final s    = sub('subscriptions');
    final role = (u['by_role'] as Map<String, dynamic>?) ?? {};

    return AdminPlatformMetrics(
      total:                  i('total', u),
      userCount:             (role['user']           as num?)?.toInt() ?? 0,
      staffCount:            (role['staff']          as num?)?.toInt() ?? 0,
      ownerCount:            (role['business_owner'] as num?)?.toInt() ?? 0,
      adminCount:            (role['admin']          as num?)?.toInt() ?? 0,
      newToday:               i('new_today',  u),
      new7d:                  i('new_7d',     u),
      new15d:                 i('new_15d',    u),
      new30d:                 i('new_30d',    u),
      active7d:               i('active_7d',  u),
      active15d:              i('active_15d', u),
      active30d:              i('active_30d', u),
      totalEstablishments:    i('total',   e),
      newEstablishments30d:   i('new_30d', e),
      activePromotions:       i('active',  p),
      totalPromotions:        i('total',   p),
      totalQrScans:           i('total_scans',   ly),
      qrScans30d:             i('scans_30d',     ly),
      totalTicketRevenue:     d('total_revenue', ly),
      ticketRevenue30d:       d('revenue_30d',   ly),
      avgTicket:              d('avg_ticket',    ly),
      activeCampaigns:        i('active',           c),
      totalCampaigns:         i('total',            c),
      campaignSpendToday:     d('spend_today',      c),
      campaignSpend7d:        d('spend_7d',         c),
      campaignSpend30d:       d('spend_30d',        c),
      creditsSold30d:         d('credits_sold_30d', c),
      activeSubscriptions:    i('active',          s),
      newSubscriptions30d:    i('new_30d',         s),
      monthlyRevenue:         d('monthly_revenue', s),
    );
  }

  static AdminPlatformMetrics get empty => const AdminPlatformMetrics(
    total: 0, userCount: 0, staffCount: 0, ownerCount: 0, adminCount: 0,
    newToday: 0, new7d: 0, new15d: 0, new30d: 0,
    active7d: 0, active15d: 0, active30d: 0,
    totalEstablishments: 0, newEstablishments30d: 0,
    activePromotions: 0, totalPromotions: 0,
    totalQrScans: 0, qrScans30d: 0,
    totalTicketRevenue: 0, ticketRevenue30d: 0, avgTicket: 0,
    activeCampaigns: 0, totalCampaigns: 0,
    campaignSpendToday: 0, campaignSpend7d: 0, campaignSpend30d: 0, creditsSold30d: 0,
    activeSubscriptions: 0, newSubscriptions30d: 0, monthlyRevenue: 0,
  );

  @override
  List<Object?> get props => [
    total, userCount, staffCount, ownerCount, adminCount,
    newToday, new7d, new15d, new30d,
    active7d, active15d, active30d,
    totalEstablishments, activePromotions,
    totalQrScans, qrScans30d, avgTicket,
    activeCampaigns, campaignSpend30d, creditsSold30d,
    activeSubscriptions, monthlyRevenue,
  ];
}
