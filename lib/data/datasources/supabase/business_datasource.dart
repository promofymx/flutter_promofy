import '../../../main.dart';
import '../../models/establishment_model.dart';

class BusinessDatasource {
  // ── Consulta ──────────────────────────────────────────────────────────────

  Future<List<EstablishmentModel>> getMyEstablishments(String userId) async {
    final response = await supabase
        .from('establishments')
        .select()
        .eq('owner_id', userId)
        .order('created_at');
    return (response as List)
        .map((e) => EstablishmentModel.fromTable(e as Map<String, dynamic>))
        .toList();
  }

  /// Devuelve el plan_id del perfil del usuario (para cargar el plan completo).
  Future<int?> getUserPlanId(String userId) async {
    final response = await supabase
        .from('profiles')
        .select('plan_id')
        .eq('id', userId)
        .maybeSingle();
    return response?['plan_id'] as int?;
  }

  /// Devuelve true si el usuario tiene una suscripción mensual activa (authorized).
  Future<bool> hasActiveSubscription(String userId) async {
    final response = await supabase
        .from('user_subscriptions')
        .select('id')
        .eq('user_id', userId)
        .eq('status', 'authorized')
        .maybeSingle();
    return response != null;
  }

  /// Cuenta todas las promociones de una lista de establecimientos.
  /// Excluye las promos creadas por el superadmin (is_admin_created = true)
  /// para que no cuenten contra el límite del plan del dueño.
  Future<int> countTotalPromos(List<String> establishmentIds) async {
    if (establishmentIds.isEmpty) return 0;
    final response = await supabase
        .from('promotions')
        .select('id')
        .inFilter('establishment_id', establishmentIds)
        .eq('is_admin_created', false);
    return (response as List).length;
  }

  // ── Creación ──────────────────────────────────────────────────────────────

  Future<EstablishmentModel> createEstablishment({
    required String userId,
    required String name,
    String? description,
    String? address,
    String? phone,
    String? website,
    required double lat,
    required double lng,
    int?    categoryId,
    List<int> categoryIds          = const <int>[],
    String? establishmentType,
    Map<String, dynamic>? schedule,
    List<String> paymentMethods    = const <String>[],
    bool   adultPromotions         = false,
    String? facebookUrl,
    String? instagramUrl,
    List<String> characteristicIds = const <String>[],
  }) async {
    // Primary category = first of categoryIds, or fallback to categoryId param
    final primaryCat = categoryIds.isNotEmpty ? categoryIds.first : categoryId;
    final allCatIds  = categoryIds.isNotEmpty
        ? categoryIds
        : (categoryId != null ? [categoryId] : <int>[]);

    final response = await supabase
        .from('establishments')
        .insert({
          'owner_id':           userId,
          'name':               name,
          'description':        description,
          'street':             address,
          'phone':              phone,
          'website':            website,
          'location':           'SRID=4326;POINT($lng $lat)',
          'category_id':        primaryCat,
          'category_ids':       allCatIds,
          'establishment_type': establishmentType,
          'schedule':           schedule,
          'payment_methods':    paymentMethods,
          'adult_promotions':   adultPromotions,
          'facebook_url':       facebookUrl,
          'instagram_url':      instagramUrl,
        })
        .select()
        .single();

    final est = EstablishmentModel.fromTable(response);

    if (characteristicIds.isNotEmpty) {
      try { await _saveCharacteristics(est.id, characteristicIds); } catch (_) {}
    }

    return est;
  }

  // ── Actualización ─────────────────────────────────────────────────────────

  Future<EstablishmentModel> updateEstablishment({
    required String id,
    required String name,
    String? description,
    String? address,
    String? phone,
    String? website,
    double? lat,
    double? lng,
    int?    categoryId,
    List<int> categoryIds          = const <int>[],
    String? establishmentType,
    Map<String, dynamic>? schedule,
    List<String> paymentMethods    = const <String>[],
    bool   adultPromotions         = false,
    String? facebookUrl,
    String? instagramUrl,
    List<String> characteristicIds = const <String>[],
  }) async {
    final primaryCat = categoryIds.isNotEmpty ? categoryIds.first : categoryId;
    final allCatIds  = categoryIds.isNotEmpty
        ? categoryIds
        : (categoryId != null ? [categoryId] : <int>[]);

    final data = <String, dynamic>{
      'name':               name,
      'description':        description,
      'street':             address,
      'phone':              phone,
      'website':            website,
      'category_id':        primaryCat,
      'category_ids':       allCatIds,
      'establishment_type': establishmentType,
      'schedule':           schedule,
      'payment_methods':    paymentMethods,
      'adult_promotions':   adultPromotions,
      'facebook_url':       facebookUrl,
      'instagram_url':      instagramUrl,
    };
    if (lat != null && lng != null) {
      data['location'] = 'SRID=4326;POINT($lng $lat)';
    }

    final response = await supabase
        .from('establishments')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    final est = EstablishmentModel.fromTable(response);

    try { await _saveCharacteristics(est.id, characteristicIds); } catch (_) {}

    return est;
  }

  // ── Eliminar ──────────────────────────────────────────────────────────────

  Future<void> deleteEstablishment(String id) async {
    await supabase.from('establishments').delete().eq('id', id);
  }

  // ── Características (junction table) ─────────────────────────────────────

  Future<void> _saveCharacteristics(
    String establishmentId,
    List<String> characteristicIds,
  ) async {
    await supabase
        .from('establishment_characteristics')
        .delete()
        .eq('establishment_id', establishmentId);

    if (characteristicIds.isNotEmpty) {
      await supabase.from('establishment_characteristics').insert(
        characteristicIds.map((cid) => {
          'establishment_id':  establishmentId,
          'characteristic_id': int.tryParse(cid) ?? cid,
        }).toList(),
      );
    }
  }
}
