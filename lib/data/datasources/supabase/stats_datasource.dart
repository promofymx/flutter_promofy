import '../../../main.dart';
import '../../models/admin_platform_metrics_model.dart';
import '../../models/audience_model.dart';
import '../../models/business_stats_model.dart';

class StatsDatasource {
  // ── Consulta agregada ─────────────────────────────────────────────────────

  /// Si se pasa [establishmentId] se consultan estadísticas solo de ese
  /// establecimiento (caso gerente). Si se pasa [ownerId] se agregan todas
  /// las sucursales del dueño.
  Future<BusinessStatsModel> getBusinessStats({
    String? ownerId,
    String? establishmentId,
    required int days,
  }) async {
    final result = await supabase.rpc(
      'get_business_stats',
      params: {
        'p_owner_id':          establishmentId != null ? null : ownerId,
        'p_establishment_id':  establishmentId,
        'p_days':              days,
      },
    );
    return BusinessStatsModel.fromJson(
      result as Map<String, dynamic>,
      days: days,
    );
  }

  // ── Tracking fire-and-forget ──────────────────────────────────────────────

  void logEstablishmentView(String establishmentId) {
    supabase.rpc('log_establishment_view', params: {
      'p_establishment_id': establishmentId,
    }).catchError((_) {});
  }

  void logPromoView(String promoId) {
    supabase.rpc('log_promo_view', params: {
      'p_promo_id': promoId,
    }).catchError((_) {});
  }

  void logContactClick({
    required String establishmentId,
    required String clickType,
  }) {
    supabase.rpc('log_contact_click', params: {
      'p_establishment_id': establishmentId,
      'p_click_type':       clickType,
    }).catchError((_) {});
  }

  // ── Importe del ticket de una visita de lealtad ───────────────────────────

  Future<void> updateVisitTicket({
    required String visitId,
    required double amount,
  }) async {
    await supabase.rpc('update_visit_ticket', params: {
      'p_visit_id': visitId,
      'p_amount':   amount,
    });
  }

  // ── Métricas globales de plataforma (solo admin) ─────────────────────────

  Future<AdminPlatformMetrics> getAdminPlatformMetrics() async {
    final result = await supabase
        .rpc('get_admin_platform_metrics')
        .timeout(
          const Duration(seconds: 25),
          onTimeout: () => throw Exception(
            'La solicitud tardó demasiado. Verifica tu conexión y vuelve a intentar.',
          ),
        );
    return AdminPlatformMetrics.fromJson(result as Map<String, dynamic>);
  }

  // ── Demografía de audiencia ────────────────────────────────────────────────

  Future<AudienceModel?> getAudienceDemographics(
      String establishmentId) async {
    try {
      final result = await supabase.rpc(
        'get_audience_demographics',
        params: {'p_establishment_id': establishmentId},
      );
      if (result == null) return AudienceModel.empty();
      return AudienceModel.fromJson(result as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
