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

  /// Saldo de la cartera del usuario (referidos + promo de lanzamiento).
  Future<double> getWalletCredits() async {
    final res = await supabase.rpc('get_my_wallet_credits');
    return (res as num?)?.toDouble() ?? 0;
  }

  /// Aplica saldo de la cartera del usuario al saldo de publicidad de un local.
  /// Devuelve el json del RPC: {ok, error?, wallet?, balance?}.
  Future<Map<String, dynamic>> applyWalletCredit({
    required String establishmentId,
    required double amount,
  }) async {
    final res = await supabase.rpc('apply_wallet_credit', params: {
      'p_establishment_id': establishmentId,
      'p_amount':           amount,
    });
    return (res as Map?)?.cast<String, dynamic>() ?? {'ok': false};
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

  // ── Anuncios para el usuario final ────────────────────────────────────────

  /// Retorna campañas rankeadas por relevancia via RPC get_ads_for_user.
  /// [lat] y [lng] son opcionales; sin ellos el factor distancia es neutro (50).
  Future<List<AdDisplayModel>> getAdsForUser({
    double? lat,
    double? lng,
    String? format,
    int limit = 10,
  }) async {
    final rows = await supabase.rpc('get_ads_for_user', params: {
      if (lat    != null) 'p_lat':    lat,
      if (lng    != null) 'p_lng':    lng,
      if (format != null) 'p_format': format,
      'p_limit': limit,
    });
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
    // Se cuenta del lado del servidor con un RPC SECURITY DEFINER.
    // Una consulta directa a `profiles` devolvería 0 por RLS (el dueño solo
    // puede leer su propio perfil).
    final result = await supabase.rpc('get_ad_reach_estimate', params: {
      'p_min_age': minAge,
      'p_max_age': maxAge,
      'p_gender':  gender,
    });
    return (result as num?)?.toInt() ?? 0;
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

  /// Vistas (impresiones) y clics por campaña del establecimiento.
  /// Cada fila de ad_impressions ya es alcance único diario, así que el conteo
  /// = lo realmente facturado. Resiliente: si falla, devuelve mapa vacío.
  Future<Map<String, ({int views, int clicks})>> getCampaignStats(
      String establishmentId) async {
    try {
      final rows = await supabase.rpc('get_campaign_stats',
          params: {'p_establishment_id': establishmentId});
      final map = <String, ({int views, int clicks})>{};
      for (final r in (rows as List)) {
        final m = r as Map<String, dynamic>;
        map[m['campaign_id'] as String] = (
          views:  (m['views']  as num? ?? 0).toInt(),
          clicks: (m['clicks'] as num? ?? 0).toInt(),
        );
      }
      return map;
    } catch (_) {
      return {};
    }
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
    List<String>?   placements,
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
          if (placements  != null && placements.isNotEmpty)
            'placements': placements,
          if (startDate != null) 'start_date': startDate.toIso8601String().split('T').first,
          if (endDate   != null) 'end_date':   endDate.toIso8601String().split('T').first,
        })
        .select()
        .single();
    return AdCampaignModel.fromJson(row);
  }

  /// Dispara el envío del push de una campaña de formato 'push'.
  /// Devuelve {sent, failed, charged} o {error}.
  Future<Map<String, dynamic>> sendAdPush(String campaignId) async {
    final res = await supabase.functions.invoke(
      'send-ad-push',
      body: {'campaign_id': campaignId},
    );
    return (res.data as Map<String, dynamic>?) ?? const {};
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
