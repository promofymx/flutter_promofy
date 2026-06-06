import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/establishment_model.dart';
import '../../../data/models/promotion_model.dart';
import '../../../data/repositories/business_repository.dart';
import 'business_state.dart';

class BusinessCubit extends Cubit<BusinessState> {
  final BusinessRepository _repo;
  final String             _userId;

  BusinessCubit({
    required BusinessRepository repository,
    required String userId,
  })  : _repo   = repository,
        _userId = userId,
        super(const BusinessInitial());

  // ── Carga inicial ─────────────────────────────────────────────────────────

  Future<void> load() async {
    emit(const BusinessLoading());
    try {
      final results = await Future.wait([
        _repo.getMyEstablishments(_userId),
        _repo.getUserPlan(_userId),
        _repo.getSubscriptionStatus(_userId),
      ]);
      final ests           = results[0] as List<EstablishmentModel>;
      final plan           = results[1] as dynamic; // MembershipPlanModel?
      final isSubActive    = results[2] as bool;

      if (ests.isEmpty) {
        emit(BusinessNoEstablishment(plan: plan));
        return;
      }

      int totalPromos = 0;
      try {
        totalPromos = await _repo.countTotalPromos(ests.map((e) => e.id).toList());
      } catch (_) {}

      final addons = await _repo.getActiveAddonCounts(_userId);

      emit(BusinessLoaded(
        establishments:       ests,
        selectedIndex:        0,
        totalPromoCount:      totalPromos,
        plan:                 plan,
        isSubscriptionActive: isSubActive,
        extraPromotions:      addons.promotions,
        extraEstablishments:  addons.establishments,
      ));
      _loadPromos(ests[0]);
    } catch (_) {
      emit(const BusinessError(
        message:       'No se pudo cargar la información del negocio.',
        previousState: BusinessNoEstablishment(),
      ));
    }
  }

  // ── Seleccionar establecimiento ───────────────────────────────────────────

  void selectEstablishment(int index) {
    final current = state;
    if (current is! BusinessLoaded) return;
    if (index == current.selectedIndex) return;
    emit(current.copyWith(
      selectedIndex: index,
      promos:        [],
      promosLoaded:  false,
    ));
    _loadPromos(current.establishments[index]);
  }

  // ── Promos del establecimiento seleccionado ───────────────────────────────

  Future<void> _loadPromos(EstablishmentModel est) async {
    try {
      final promos = await _repo.getOwnerPromosByEstablishment(
        establishmentId:   est.id,
        establishmentName: est.name,
        establishmentLogo: est.logoUrl,
      );
      final current = state;
      if (current is BusinessLoaded && current.selected.id == est.id) {
        emit(current.copyWith(promos: promos, promosLoaded: true));
      }
    } catch (_) {
      final current = state;
      if (current is BusinessLoaded && current.selected.id == est.id) {
        emit(current.copyWith(promosLoaded: true));
      }
    }
  }

  // ── Toggle destacada ──────────────────────────────────────────────────────

  Future<void> toggleFeatured(String promotionId) async {
    final current = state;
    if (current is! BusinessLoaded) return;

    final target     = current.promos.firstWhere((p) => p.id == promotionId);
    final turningOn  = !target.isFeatured;

    // Optimistic update:
    // • Si se activa → esta queda destacada y TODAS las demás se apagan.
    // • Si se desactiva → solo esta se apaga (ya es la única posible).
    final updated = current.promos.map((p) {
      if (p.id == promotionId) return p.copyWith(isFeatured: turningOn);
      if (turningOn)           return p.copyWith(isFeatured: false);
      return p;
    }).toList();

    emit(current.copyWith(promos: updated));
    try {
      await _repo.toggleFeatured(promotionId);
    } catch (_) {
      emit(current); // revert si el server falla
    }
  }

  // ── Crear establecimiento ─────────────────────────────────────────────────

  Future<void> create({
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
  }) async {
    final previous = state;
    emit(const BusinessSaving());
    try {
      final est = await _repo.createEstablishment(
        userId:            _userId,
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

      final prevEsts = previous is BusinessLoaded ? previous.establishments : <EstablishmentModel>[];
      final prevPlan = previous is BusinessLoaded ? previous.plan
                     : previous is BusinessNoEstablishment ? previous.plan : null;
      final newEsts  = [...prevEsts, est];
      final newIndex = newEsts.length - 1;

      int totalPromos = 0;
      try {
        totalPromos = await _repo.countTotalPromos(newEsts.map((e) => e.id).toList());
      } catch (_) {}

      emit(BusinessLoaded(
        establishments:  newEsts,
        selectedIndex:   newIndex,
        totalPromoCount: totalPromos,
        plan:            prevPlan,
      ));
      _loadPromos(est);
    } catch (_) {
      emit(BusinessError(
        message:       'No se pudo registrar el negocio. Intenta de nuevo.',
        previousState: previous,
      ));
    }
  }

  // ── Actualizar establecimiento ────────────────────────────────────────────

  Future<void> update({
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
  }) async {
    final previous = state;
    emit(const BusinessSaving());
    try {
      final est = await _repo.updateEstablishment(
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

      if (previous is BusinessLoaded) {
        final updatedEsts = previous.establishments
            .map((e) => e.id == est.id ? est : e)
            .toList();
        emit(previous.copyWith(
          establishments: updatedEsts,
          promos:         previous.promos,
          promosLoaded:   previous.promosLoaded,
        ));
      } else {
        emit(BusinessLoaded(establishments: [est]));
      }
    } catch (_) {
      emit(BusinessError(
        message:       'No se pudo actualizar el negocio. Intenta de nuevo.',
        previousState: previous,
      ));
    }
  }

  // ── CRUD de promociones ───────────────────────────────────────────────────

  /// Crea una promoción para el establecimiento seleccionado.
  /// Lanza excepción si falla (el formulario la captura para mostrar error).
  Future<void> createPromo({
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
    final current = state;
    if (current is! BusinessLoaded) return;

    // Regla de negocio: máximo 1 promo flash por establecimiento por mes.
    if (type == 'flash') {
      final alreadyHas = await _repo.hasFlashPromoThisMonth(current.selected.id);
      if (alreadyHas) {
        throw Exception(
          'Ya existe una promo flash este mes para este negocio. '
          'Solo se permite una por mes.',
        );
      }
    }

    final promoId = await _repo.createPromotion(
      establishmentId: current.selected.id,
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

    // Notificar a favoritos (fire-and-forget)
    if (type == 'flash') {
      _sendFlashNotification(
        establishmentId: current.selected.id,
        promoName:       name,
        description:     description,
      );
    } else if (type != 'birthday') {
      // Las promos de cumpleaños no envían notificación al crear
      // (el cron diario las envía en el cumpleaños del usuario)
      _sendNewPromoNotification(
        establishmentId: current.selected.id,
        promoId:         promoId,
        promoName:       name,
      );
    }

    await _refreshPromosAndCount(current);
  }

  /// Actualiza una promoción existente.
  Future<void> updatePromo({
    required String promoId,
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
    final current = state;
    if (current is! BusinessLoaded) return;

    await _repo.updatePromotion(
      id:            promoId,
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

    // El conteo no cambia al editar; solo recarga la lista
    await _refreshPromos(current);
  }

  /// Elimina una promoción y actualiza el conteo total.
  Future<void> deletePromo(String promoId) async {
    final current = state;
    if (current is! BusinessLoaded) return;

    await _repo.deletePromotion(promoId);
    await _refreshPromosAndCount(current);
  }

  /// Sube una foto al bucket `promo-photos` y devuelve la URL pública.
  /// Recibe los bytes ya leídos para evitar problemas con dart:io.
  Future<String?> uploadPromoPhoto(Uint8List bytes, String extension) =>
      _repo.uploadPromoPhoto(
          userId: _userId, bytes: bytes, extension: extension);

  // ── Helpers internos de refresco ──────────────────────────────────────────

  /// Recarga promos + conteo total (usar tras crear o eliminar).
  Future<void> _refreshPromosAndCount(BusinessLoaded snapshot) async {
    try {
      final results = await Future.wait([
        _repo.getOwnerPromosByEstablishment(
          establishmentId:   snapshot.selected.id,
          establishmentName: snapshot.selected.name,
          establishmentLogo: snapshot.selected.logoUrl,
        ),
        _repo.countTotalPromos(
            snapshot.establishments.map((e) => e.id).toList()),
      ]);
      final promos = results[0] as List<PromotionModel>;
      final total  = results[1] as int;

      final s = state;
      if (s is BusinessLoaded && s.selected.id == snapshot.selected.id) {
        emit(s.copyWith(
          promos:          promos,
          promosLoaded:    true,
          totalPromoCount: total,
        ));
      }
    } catch (_) {}
  }

  /// Recarga solo la lista de promos (usar tras editar).
  Future<void> _refreshPromos(BusinessLoaded snapshot) async {
    try {
      final promos = await _repo.getOwnerPromosByEstablishment(
        establishmentId:   snapshot.selected.id,
        establishmentName: snapshot.selected.name,
        establishmentLogo: snapshot.selected.logoUrl,
      );
      final s = state;
      if (s is BusinessLoaded && s.selected.id == snapshot.selected.id) {
        emit(s.copyWith(promos: promos, promosLoaded: true));
      }
    } catch (_) {}
  }

  // ── Notificaciones ───────────────────────────────────────────────────────

  void _sendFlashNotification({
    required String establishmentId,
    required String promoName,
    required String description,
  }) {
    // Fire-and-forget: no bloqueamos la UI si falla
    _repo.sendFlashNotification(
      establishmentId: establishmentId,
      promoName:       promoName,
      description:     description,
    ).catchError((_) {});
  }

  void _sendNewPromoNotification({
    required String establishmentId,
    required String promoId,
    required String promoName,
  }) {
    _repo.sendNewPromoNotification(
      establishmentId: establishmentId,
      promoId:         promoId,
      promoName:       promoName,
    ).catchError((_) {});
  }

  // ── Recuperación de error ─────────────────────────────────────────────────

  void clearError() {
    if (state is BusinessError) {
      final prev = (state as BusinessError).previousState;
      emit(prev ?? const BusinessNoEstablishment());
    }
  }
}
