import '../datasources/supabase/ads_datasource.dart';
import '../models/ad_campaign_model.dart';
import '../models/ad_credit_model.dart';
import '../models/ad_credit_txn_model.dart';
import '../models/ad_display_model.dart';
import '../models/ad_pricing_model.dart';
import '../models/admin_establishment_entry.dart';

class AdsRepository {
  final AdsDatasource _ds;

  AdsRepository({AdsDatasource? datasource})
      : _ds = datasource ?? AdsDatasource();

  // ── Precios ────────────────────────────────────────────────────────────────

  Future<List<AdPricingModel>> getPricing() => _ds.getPricing();

  Future<AdPricingModel> updatePricing({
    required int    id,
    required double priceMxn,
    required double minBudgetMxn,
  }) =>
      _ds.updatePricing(id: id, priceMxn: priceMxn, minBudgetMxn: minBudgetMxn);

  Future<int> getTotalUserCount() => _ds.getTotalUserCount();

  // ── Negocio ────────────────────────────────────────────────────────────────

  Future<AdCreditModel?> getCredits(String estId) => _ds.getCredits(estId);

  Future<List<AdCreditTxnModel>> getTransactions(String estId) =>
      _ds.getTransactions(estId);

  Future<List<AdCampaignModel>> getCampaigns(String estId) =>
      _ds.getCampaigns(estId);

  Future<AdCampaignModel> createCampaign({
    required String establishmentId,
    required String createdBy,
    required String name,
    required String format,
    required double budgetMxn,
    required int    radiusKm,
    required String geoMode,
    List<int>?      targetCategoryIds,
    int     targetMinAge  = 0,
    int     targetMaxAge  = 99,
    String  targetGender  = 'all',
    String? promotionId,
    DateTime?       startDate,
    DateTime?       endDate,
  }) =>
      _ds.createCampaign(
        establishmentId:    establishmentId,
        createdBy:          createdBy,
        name:               name,
        format:             format,
        budgetMxn:          budgetMxn,
        radiusKm:           radiusKm,
        geoMode:            geoMode,
        targetCategoryIds:  targetCategoryIds,
        targetMinAge:       targetMinAge,
        targetMaxAge:       targetMaxAge,
        targetGender:       targetGender,
        promotionId:        promotionId,
        startDate:          startDate,
        endDate:            endDate,
      );

  Future<AdCampaignModel> updateCampaignStatus(String id, String status) =>
      _ds.updateCampaignStatus(id, status);

  Future<int> getReachEstimate({
    required int    minAge,
    required int    maxAge,
    required String gender,
  }) => _ds.getReachEstimate(minAge: minAge, maxAge: maxAge, gender: gender);

  // ── Anuncios para el usuario final (Phase C) ──────────────────────────────

  Future<List<AdDisplayModel>> getActiveAdsForDisplay() =>
      _ds.getActiveAdsForDisplay();

  // ── Admin: créditos ────────────────────────────────────────────────────────

  Future<List<AdminEstablishmentEntry>> getAllEstablishmentsForAdmin() =>
      _ds.getAllEstablishmentsForAdmin();

  Future<void> addCredit({
    required String establishmentId,
    required double amountMxn,
    required String description,
    required String addedBy,
  }) =>
      _ds.addCredit(
        establishmentId: establishmentId,
        amountMxn:       amountMxn,
        description:     description,
        addedBy:         addedBy,
      );

  // ── Phase D ───────────────────────────────────────────────────────────────

  /// Registra 'impression' o 'click'. Fire-and-forget seguro.
  Future<void> recordImpression(String campaignId, String type) =>
      _ds.recordImpression(campaignId, type);

  /// Crea preferencia de pago MercadoPago y devuelve la URL `init_point`.
  Future<String> createMpPreference({
    required String establishmentId,
    required double amountMxn,
  }) =>
      _ds.createMpPreference(
        establishmentId: establishmentId,
        amountMxn:       amountMxn,
      );
}
