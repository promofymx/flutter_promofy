import '../datasources/supabase/stats_datasource.dart';
import '../models/admin_platform_metrics_model.dart';
import '../models/audience_model.dart';
import '../models/business_stats_model.dart';

class StatsRepository {
  final StatsDatasource _ds;

  StatsRepository({StatsDatasource? datasource})
      : _ds = datasource ?? StatsDatasource();

  // ── Estadísticas del negocio ──────────────────────────────────────────────

  /// [ownerId] agrega todas las sucursales del dueño.
  /// [establishmentId] filtra a un solo establecimiento (modo gerente).
  Future<BusinessStatsModel> getBusinessStats({
    String?  ownerId,
    String?  establishmentId,
    required int days,
  }) =>
      _ds.getBusinessStats(
        ownerId:          ownerId,
        establishmentId:  establishmentId,
        days:             days,
      );

  // ── Tracking (fire-and-forget) ────────────────────────────────────────────

  void logEstablishmentView(String establishmentId) =>
      _ds.logEstablishmentView(establishmentId);

  void logPromoView(String promoId) =>
      _ds.logPromoView(promoId);

  void logContactClick({
    required String establishmentId,
    required String clickType,
  }) =>
      _ds.logContactClick(
        establishmentId: establishmentId,
        clickType:       clickType,
      );

  // ── Ticket de lealtad ─────────────────────────────────────────────────────

  Future<void> updateVisitTicket({
    required String visitId,
    required double amount,
  }) =>
      _ds.updateVisitTicket(visitId: visitId, amount: amount);

  // ── Métricas globales de plataforma (solo admin) ─────────────────────────

  Future<AdminPlatformMetrics> getAdminPlatformMetrics() =>
      _ds.getAdminPlatformMetrics();

  // ── Demografía de audiencia ───────────────────────────────────────────────

  Future<AudienceModel?> getAudienceDemographics(String establishmentId) =>
      _ds.getAudienceDemographics(establishmentId);
}
