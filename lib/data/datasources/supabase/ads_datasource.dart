import '../../../main.dart';
import '../../models/ad_campaign_model.dart';
import '../../models/ad_credit_model.dart';
import '../../models/ad_credit_txn_model.dart';
import '../../models/ad_display_model.dart';
import '../../models/ad_pricing_model.dart';
import '../../models/admin_establishment_entry.dart';

class AdsDatasource {
  // ── Precios de formatos ────────────────────────────────────────────────────

  Future<List<AdPricingModel>> getPricing() async {
    final rows = await supabase.from('ad_pricing').select().order('id');
    return (rows as List)
        .map((e) => AdPricingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdPricingModel> updatePricing({
    required int    id,
    required double priceMxn,
    required double minBudgetMxn,
  }) async {
    final row = await supabase
        .from('ad_pricing')
        .update({
          'price_mxn':      priceMxn,
          'min_budget_mxn': minBudgetMxn,
          'updated_at':     DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();
    return AdPricingModel.fromJson(row);
  }

  /// Cuenta total de usuarios registrados (perfiles).
  Future<int> getTotalUserCount() async {
    final rows = await supabase.from('profiles').select('id');
    return (rows as List).length;
  }

  // ── Crédito del establecimiento ────────────────────────────────────────────

  Future<AdCreditModel?> getCredits(String establishmentId) async {
    final row = await supabase
        .from('ad_credits')
        .select()
        .eq('establishment_id', establishmentId)
        .maybeSingle();
    if (row == null) return null;
    return AdCreditModel.fromJson(row);
  }

  Future<List<AdCreditTxnModel>> getTransactions(
      String establishmentId) async {
    final rows = await supabase
        .from('ad_credit_txns')
        .select()
        .eq('establishment_id', establishmentId)
        .order('created_at', ascending: false)
        .limit(30);
    return (rows as List)
        .map((e) => AdCreditTxnModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Anuncios para el usuario final (Phase C) ──────────────────────────────

  /// Retorna campañas activas de formatos visibles al usuario (splash, banner,
  /// featured_list), incluyendo nombre y foto del establecimiento via JOIN.
  Future<List<AdDisplayModel>> getActiveAdsForDisplay() async {
    final rows = await supabase
        .from('ad_campaigns')
        .select('id, establishment_id, format, establishments(name, photo_url)')
        .eq('status', 'active')
        .inFilter('format', ['splash', 'featured_list', 'banner']);
    return (rows as List)
        .map((e) => AdDisplayModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Cuenta cuántos perfiles coinciden con los filtros de segmentación.
  /// Usado para mostrar el alcance estimado en tiempo real al crear campaña.
  Future<int> getReachEstimate({
    required int    minAge,
    required int    maxAge,
    required String gender, // 'all' | 'male' | 'female'
  }) async {
    final now     = DateTime.now();
    // Quienes tienen AL MENOS minAge: birth_date <= (hoy - minAge años)
    final latest  = DateTime(now.year - minAge,  now.month, now.day);
    // Quienes tienen COMO MUCHO maxAge: birth_date >= (hoy - maxAge años)
    final earliest = DateTime(now.year - maxAge, now.month, now.day);

    final baseRows = gender == 'all'
        ? await supabase
            .from('profiles')
            .select('id')
            .not('birth_date', 'is', null)
            .gte('birth_date', earliest.toIso8601String().split('T').first)
            .lte('birth_date', latest.toIso8601String().split('T').first)
        : await supabase
            .from('profiles')
            .select('id')
            .not('birth_date', 'is', null)
            .gte('birth_date', earliest.toIso8601String().split('T').first)
            .lte('birth_date', latest.toIso8601String().split('T').first)
            .eq('gender', gender);

    return (baseRows as List).length;
  }

  // ── Campañas ───────────────────────────────────────────────────────────────

  Future<List<AdCampaignModel>> getCampaigns(String establishmentId) async {
    final rows = await supabase
        .from('ad_campaigns')
        .select()
        .eq('establishment_id', establishmentId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => AdCampaignModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

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
  }) async {
    final row = await supabase
        .from('ad_campaigns')
        .insert({
          'establishment_id':      establishmentId,
          'created_by':            createdBy,
          'name':                  name,
          'format':                format,
          'status':                'active',
          'budget_mxn':            budgetMxn,
          'spent_mxn':             0,
          'radius_km':             radiusKm,
          'geo_mode':              geoMode,
          'target_category_ids':   targetCategoryIds ?? [],
          'target_min_age': targetMinAge,
          'target_max_age': targetMaxAge,
          'target_gender':  targetGender,
          if (promotionId != null) 'promotion_id': promotionId,
          if (startDate != null) 'start_date': startDate.toIso8601String().split('T').first,
          if (endDate   != null) 'end_date':   endDate.toIso8601String().split('T').first,
        })
        .select()
        .single();
    return AdCampaignModel.fromJson(row);
  }

  Future<AdCampaignModel> updateCampaignStatus(
      String campaignId, String status) async {
    final row = await supabase
        .from('ad_campaigns')
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', campaignId)
        .select()
        .single();
    return AdCampaignModel.fromJson(row);
  }

  // ── Admin: créditos publicitarios ─────────────────────────────────────────

  /// Lista todos los establecimientos con su saldo de crédito actual.
  /// Solo para uso del superadmin.
  Future<List<AdminEstablishmentEntry>> getAllEstablishmentsForAdmin() async {
    final rows = await supabase
        .from('establishments')
        .select('id, name, photo_url, profiles!owner_id(full_name), ad_credits(balance_mxn)')
        .order('name');
    return (rows as List)
        .map((e) => AdminEstablishmentEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Agrega crédito a un establecimiento (transacción + actualiza balance).
  Future<void> addCredit({
    required String establishmentId,
    required double amountMxn,
    required String description,
    required String addedBy,
  }) async {
    await supabase.rpc('admin_add_credit', params: {
      'p_establishment_id': establishmentId,
      'p_amount_mxn':       amountMxn,
      'p_description':      description,
      'p_added_by':         addedBy,
    });
  }

  // ── Phase D: impresiones y MercadoPago ────────────────────────────────────

  /// Registra una impresión o clic para la campaña.
  /// El RPC descuenta crédito (si es impresión) y pausa la campaña si el saldo llega a 0.
  Future<void> recordImpression(String campaignId, String type) async {
    await supabase.rpc('record_ad_impression', params: {
      'p_campaign_id': campaignId,
      'p_type':        type,
    });
  }

  /// Llama a la Edge Function para crear una preferencia de pago en MercadoPago.
  /// Devuelve la URL `init_point` para abrir con url_launcher.
  Future<String> createMpPreference({
    required String establishmentId,
    required double amountMxn,
  }) async {
    final resp = await supabase.functions.invoke(
      'create-mp-preference',
      body: {
        'establishment_id': establishmentId,
        'amount_mxn':       amountMxn,
      },
    );
    final data = resp.data as Map<String, dynamic>;
    if (data['error'] != null) {
      throw Exception(data['error']);
    }
    return data['init_point'] as String;
  }
}
