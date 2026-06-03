import 'dart:typed_data';

import '../datasources/supabase/business_datasource.dart';
import '../datasources/supabase/membership_plans_datasource.dart';
import '../datasources/supabase/promotions_datasource.dart';
import '../models/establishment_model.dart';
import '../models/membership_plan_model.dart';
import '../models/promotion_model.dart';

class BusinessRepository {
  final BusinessDatasource        _datasource;
  final PromotionsDatasource      _promosDatasource;
  final MembershipPlansDatasource _plansDatasource;

  BusinessRepository({
    BusinessDatasource?        datasource,
    PromotionsDatasource?      promosDatasource,
    MembershipPlansDatasource? plansDatasource,
  })  : _datasource       = datasource       ?? BusinessDatasource(),
        _promosDatasource = promosDatasource  ?? PromotionsDatasource(),
        _plansDatasource  = plansDatasource   ?? MembershipPlansDatasource();

  // ── Establecimientos ──────────────────────────────────────────────────────

  Future<List<EstablishmentModel>> getMyEstablishments(String userId) =>
      _datasource.getMyEstablishments(userId);

  Future<EstablishmentModel> createEstablishment({
    required String userId,
    required String name,
    String? description,
    String? address,
    String? phone,
    String? website,
    required double lat,
    required double lng,
    int?      categoryId,
    List<int> categoryIds          = const <int>[],
    String? establishmentType,
    Map<String, dynamic>? schedule,
    List<String> paymentMethods    = const <String>[],
    bool   adultPromotions         = false,
    String? facebookUrl,
    String? instagramUrl,
    List<String> characteristicIds = const <String>[],
  }) =>
      _datasource.createEstablishment(
        userId:            userId,
        name:              name,
        description:       description,
        address:           address,
        phone:             phone,
        website:           website,
        lat:               lat,
        lng:               lng,
        categoryId:        categoryId,
        categoryIds:       categoryIds,
        establishmentType: establishmentType,
        schedule:          schedule,
        paymentMethods:    paymentMethods,
        adultPromotions:   adultPromotions,
        facebookUrl:       facebookUrl,
        instagramUrl:      instagramUrl,
        characteristicIds: characteristicIds,
      );

  Future<void> deleteEstablishment(String id) =>
      _datasource.deleteEstablishment(id);

  Future<EstablishmentModel> updateEstablishment({
    required String id,
    required String name,
    String? description,
    String? address,
    String? phone,
    String? website,
    double? lat,
    double? lng,
    int?      categoryId,
    List<int> categoryIds          = const <int>[],
    String? establishmentType,
    Map<String, dynamic>? schedule,
    List<String> paymentMethods    = const <String>[],
    bool   adultPromotions         = false,
    String? facebookUrl,
    String? instagramUrl,
    List<String> characteristicIds = const <String>[],
  }) =>
      _datasource.updateEstablishment(
        id:                id,
        name:              name,
        description:       description,
        address:           address,
        phone:             phone,
        website:           website,
        lat:               lat,
        lng:               lng,
        categoryId:        categoryId,
        categoryIds:       categoryIds,
        establishmentType: establishmentType,
        schedule:          schedule,
        paymentMethods:    paymentMethods,
        adultPromotions:   adultPromotions,
        facebookUrl:       facebookUrl,
        instagramUrl:      instagramUrl,
        characteristicIds: characteristicIds,
      );

  // ── Plan y suscripción del usuario ────────────────────────────────────────

  Future<MembershipPlanModel?> getUserPlan(String userId) async {
    final planId = await _datasource.getUserPlanId(userId);
    if (planId == null) return null;
    return _plansDatasource.getPlanById(planId);
  }

  /// Devuelve true si el usuario tiene una suscripción mensual activa.
  Future<bool> getSubscriptionStatus(String userId) =>
      _datasource.hasActiveSubscription(userId);

  // ── Promociones — consulta ─────────────────────────────────────────────────

  /// Consulta directa para el panel del dueño (sin filtros de distancia/horario).
  Future<List<PromotionModel>> getOwnerPromosByEstablishment({
    required String establishmentId,
    required String establishmentName,
    String? establishmentLogo,
  }) =>
      _promosDatasource.getOwnerPromos(
        establishmentId:    establishmentId,
        establishmentName:  establishmentName,
        establishmentLogo:  establishmentLogo,
      );

  Future<List<PromotionModel>> getPromosByEstablishment({
    required String establishmentId,
    double lat = 0,
    double lng = 0,
    String? userId,
  }) =>
      _promosDatasource.getByDistance(
        lat:                   lat,
        lng:                   lng,
        page:                  0,
        limit:                 100,
        userId:                userId,
        filterEstablishmentId: establishmentId,
      );

  Future<int> countTotalPromos(List<String> establishmentIds) =>
      _datasource.countTotalPromos(establishmentIds);

  Future<void> toggleFeatured(String promotionId) =>
      _promosDatasource.toggleFeatured(promotionId);

  // ── Promociones — CRUD ────────────────────────────────────────────────────

  Future<String> createPromotion({
    required String establishmentId,
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
  }) =>
      _promosDatasource.createPromotion(
        establishmentId: establishmentId,
        name:            name,
        description:     description,
        type:            type,
        activeDays:      activeDays,
        startTime:       startTime,
        endTime:         endTime,
        flashStartsAt:   flashStartsAt,
        flashEndsAt:     flashEndsAt,
        photoUrl:        photoUrl,
        isAdultOnly:     isAdultOnly,
        categoryId:      categoryId,
        birthdayGift:    birthdayGift,
        birthdayTerms:   birthdayTerms,
      );

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
  }) =>
      _promosDatasource.updatePromotion(
        id:            id,
        name:          name,
        description:   description,
        type:          type,
        activeDays:    activeDays,
        startTime:     startTime,
        endTime:       endTime,
        flashStartsAt: flashStartsAt,
        flashEndsAt:   flashEndsAt,
        photoUrl:      photoUrl,
        isAdultOnly:   isAdultOnly,
        categoryId:    categoryId,
        birthdayGift:  birthdayGift,
        birthdayTerms: birthdayTerms,
      );

  Future<void> deletePromotion(String id) =>
      _promosDatasource.deletePromotion(id);

  // ── Fotos ─────────────────────────────────────────────────────────────────

  Future<String> uploadPromoPhoto({
    required String    userId,
    required Uint8List bytes,
    required String    extension,
  }) =>
      _promosDatasource.uploadPromoPhoto(
          userId: userId, bytes: bytes, extension: extension);

  // ── Validaciones de negocio ───────────────────────────────────────────────

  Future<bool> hasFlashPromoThisMonth(String establishmentId) =>
      _promosDatasource.hasFlashPromoThisMonth(establishmentId);

  // ── Notificaciones ────────────────────────────────────────────────────────

  Future<void> sendFlashNotification({
    required String establishmentId,
    required String promoName,
    required String description,
  }) =>
      _promosDatasource.sendFlashNotification(
        establishmentId: establishmentId,
        promoName:       promoName,
        description:     description,
      );

  Future<void> sendNewPromoNotification({
    required String establishmentId,
    required String promoId,
    required String promoName,
  }) =>
      _promosDatasource.sendNewPromoNotification(
        establishmentId: establishmentId,
        promoId:         promoId,
        promoName:       promoName,
      );
}
