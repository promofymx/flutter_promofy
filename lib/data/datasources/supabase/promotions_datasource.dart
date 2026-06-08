import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../main.dart';
import '../../models/filter_model.dart';
import '../../models/promotion_model.dart';

class PromotionsDatasource {
  // ── Consulta pública (RPC SECURITY DEFINER) ───────────────────────────────

  Future<List<PromotionModel>> getByDistance({
    required double lat,
    required double lng,
    int page     = 0,
    int limit    = 10,
    int radiusKm = 25,
    String? userId,
    HomeFilters filters = const HomeFilters(),
    bool filterFavoritesOnly   = false,
    String? filterEstablishmentId,
  }) async {
    final response = await supabase.rpc(
      'get_promotions_by_distance',
      params: {
        'user_lat':    lat,
        'user_lng':    lng,
        'page_number': page,
        'page_size':   limit,
        'radius_km':   filterEstablishmentId != null ? 999.0 : radiusKm.toDouble(),
        'filter_active_now':         filters.activeNow,
        'filter_flash_only':         filters.flashOnly,
        'filter_category_id':        filters.categoryId,
        'filter_characteristic_ids': filters.characteristicIds.isEmpty
            ? null
            : filters.characteristicIds,
        'filter_day_of_week':        filters.dayOfWeek,
        'filter_payment_method':     filters.paymentMethod,
        'current_user_id':           userId,
        'search_query':              filters.searchQuery.isEmpty
            ? null
            : filters.searchQuery,
        'filter_favorites_only':     filterFavoritesOnly || filters.favoritesOnly,
        'filter_establishment_id':   filterEstablishmentId,
        'filter_time_band':          filters.timeBand,
      },
    );
    return (response as List)
        .map((e) => PromotionModel.fromJson(e as Map<String, dynamic>))
        .where((p) => !p.isBirthday) // solo aparecen con el chip de cumpleañero
        .toList();
  }

  // ── Favoritos ─────────────────────────────────────────────────────────────

  Future<void> addFavorite(String userId, String promotionId) async {
    await supabase.from('user_favorite_promotions').insert({
      'user_id':      userId,
      'promotion_id': promotionId,
    });
  }

  Future<void> removeFavorite(String userId, String promotionId) async {
    await supabase
        .from('user_favorite_promotions')
        .delete()
        .eq('user_id', userId)
        .eq('promotion_id', promotionId);
  }

  /// RPC `toggle_featured_promotion` (SECURITY DEFINER).
  Future<void> toggleFeatured(String promotionId) async {
    await supabase.rpc(
      'toggle_featured_promotion',
      params: {'p_promotion_id': promotionId},
    );
  }

  // ── Promos de cumpleaños ──────────────────────────────────────────────────

  Future<List<PromotionModel>> getBirthdayPromos({
    required double lat,
    required double lng,
    int page     = 0,
    int limit    = 20,
    int radiusKm = 25,
    String? userId,
  }) async {
    final response = await supabase.rpc(
      'get_birthday_promotions',
      params: {
        'user_lat':        lat,
        'user_lng':        lng,
        'page_number':     page,
        'page_size':       limit,
        'radius_km':       radiusKm.toDouble(),
        'current_user_id': userId,
      },
    );
    return (response as List)
        .map((e) => PromotionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Consulta directa para el panel del dueño ─────────────────────────────

  /// Devuelve todas las promos de un establecimiento usando una consulta
  /// directa a la tabla (sin filtros de distancia ni horario del RPC).
  Future<List<PromotionModel>> getOwnerPromos({
    required String establishmentId,
    required String establishmentName,
    String? establishmentLogo,
  }) async {
    final rows = await supabase
        .from('promotions')
        .select()
        .eq('establishment_id', establishmentId)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((e) => PromotionModel.fromTable(
              e as Map<String, dynamic>,
              establishmentName: establishmentName,
              establishmentLogo: establishmentLogo,
            ))
        .toList();
  }

  // ── CRUD (dueño del establecimiento) ──────────────────────────────────────

  /// Inserta una nueva promoción y devuelve el ID generado.
  /// Cuando [isAdminCreated] = true, la promo no cuenta contra el límite del plan.
  Future<String> createPromotion({
    required String establishmentId,
    required String name,
    required String description,
    required String type,           // 'normal' | 'flash' | 'birthday'
    required List<int> activeDays,  // 1=Lun…7=Dom
    required String startTime,      // 'HH:mm:00'
    required String endTime,
    DateTime? flashStartsAt,
    DateTime? flashEndsAt,
    String? photoUrl,
    required bool isAdultOnly,
    int? categoryId,
    bool isAdminCreated = false,
    String? birthdayGift,
    String? birthdayTerms,
  }) async {
    final row = await supabase.from('promotions').insert({
      'establishment_id': establishmentId,
      'name':             name,
      'description':      description,
      'type':             type,
      'active_days':      activeDays,
      'start_time':       startTime,
      'end_time':         endTime,
      'is_adult_only':    isAdultOnly,
      'photo_url':        photoUrl,
      'category_id':      categoryId,
      'is_admin_created': isAdminCreated,
      if (flashStartsAt != null)
        'flash_starts_at': flashStartsAt.toUtc().toIso8601String(),
      if (flashEndsAt != null)
        'flash_ends_at': flashEndsAt.toUtc().toIso8601String(),
      if (birthdayGift  != null) 'birthday_gift':  birthdayGift,
      if (birthdayTerms != null) 'birthday_terms': birthdayTerms,
    }).select('id').single();
    return row['id'] as String;
  }

  /// Actualiza los campos de una promoción existente.
  Future<void> updatePromotion({
    required String id,
    required String name,
    required String description,
    required String type,
    required List<int> activeDays,
    required String startTime,
    required String endTime,
    DateTime? flashStartsAt,
    DateTime? flashEndsAt,
    String? photoUrl,
    required bool isAdultOnly,
    int? categoryId,
    String? birthdayGift,
    String? birthdayTerms,
  }) async {
    await supabase.from('promotions').update({
      'name':             name,
      'description':      description,
      'type':             type,
      'active_days':      activeDays,
      'start_time':       startTime,
      'end_time':         endTime,
      'is_adult_only':    isAdultOnly,
      'photo_url':        photoUrl,
      'category_id':      categoryId,
      'flash_starts_at':  flashStartsAt?.toUtc().toIso8601String(),
      'flash_ends_at':    flashEndsAt?.toUtc().toIso8601String(),
      'birthday_gift':    birthdayGift,
      'birthday_terms':   birthdayTerms,
    }).eq('id', id);
  }

  /// Elimina una promoción por ID.
  Future<void> deletePromotion(String id) async {
    await supabase.from('promotions').delete().eq('id', id);
  }

  // ── Fotos en Storage ──────────────────────────────────────────────────────

  /// Sube una imagen al bucket `promo-photos` y devuelve la URL pública.
  /// Usa bytes (Uint8List) para evitar problemas con dart:io en distintos
  /// dispositivos/versiones de SO.
  Future<String> uploadPromoPhoto({
    required String    userId,
    required Uint8List bytes,
    required String    extension, // 'jpg', 'png', etc.
  }) async {
    final name = '${DateTime.now().millisecondsSinceEpoch}.$extension';
    final path = '$userId/$name';
    final mime = extension == 'png' ? 'image/png' : 'image/jpeg';

    await supabase.storage
        .from('promo-photos')
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: mime, upsert: true),
        );

    return supabase.storage.from('promo-photos').getPublicUrl(path);
  }

  // ── Validaciones de negocio ───────────────────────────────────────────────

  /// Devuelve true si el establecimiento ya tiene una promo flash creada
  /// en el mes en curso (UTC). Se usa para impedir más de una por mes.
  Future<bool> hasFlashPromoThisMonth(String establishmentId) async {
    final now          = DateTime.now().toUtc();
    final firstOfMonth = DateTime.utc(now.year, now.month, 1);
    // DateTime.utc con month + 1 maneja diciembre → enero correctamente.
    final firstOfNext  = DateTime.utc(now.year, now.month + 1, 1);

    final rows = await supabase
        .from('promotions')
        .select('id')
        .eq('establishment_id', establishmentId)
        .eq('type', 'flash')
        .gte('flash_starts_at', firstOfMonth.toIso8601String())
        .lt('flash_starts_at', firstOfNext.toIso8601String())
        .limit(1);

    return (rows as List).isNotEmpty;
  }

  // ── Notificaciones ────────────────────────────────────────────────────────

  /// Llama a la Edge Function que envía push a los favoritos del establecimiento.
  Future<void> sendFlashNotification({
    required String establishmentId,
    required String promoName,
    required String description,
  }) async {
    await supabase.functions.invoke(
      'send-flash-notification',
      body: {
        'establishment_id':  establishmentId,
        'promo_name':        promoName,
        'promo_description': description,
      },
    );
  }

  /// Llama a la Edge Function que envía push a favoritos cuando se crea una
  /// promo normal (usa plantillas pre-aprobadas de notification_templates).
  Future<void> sendNewPromoNotification({
    required String establishmentId,
    required String promoId,
    required String promoName,
  }) async {
    await supabase.functions.invoke(
      'send-new-promo-notification',
      body: {
        'establishment_id': establishmentId,
        'promo_id':         promoId,
        'promo_name':       promoName,
      },
    );
  }
}
