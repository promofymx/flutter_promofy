import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/promotion_model.dart';
import '../../../data/repositories/establishments_repository.dart';
import '../../../data/repositories/loyalty_repository.dart';
import '../../../data/repositories/promotions_repository.dart';
import '../../../data/repositories/stats_repository.dart';
import 'restaurant_detail_state.dart';

class RestaurantDetailCubit extends Cubit<RestaurantDetailState> {
  final EstablishmentsRepository _estRepo;
  final PromotionsRepository     _promosRepo;
  final LoyaltyRepository        _loyaltyRepo;
  final StatsRepository          _statsRepo;
  final String  _establishmentId;
  final String? _userId;

  static const _fallbackLat = 21.8853;
  static const _fallbackLng = -102.2916;

  RestaurantDetailCubit({
    required String establishmentId,
    required EstablishmentsRepository establishmentsRepository,
    required PromotionsRepository promotionsRepository,
    LoyaltyRepository? loyaltyRepository,
    StatsRepository?   statsRepository,
    String? userId,
  })  : _establishmentId = establishmentId,
        _estRepo          = establishmentsRepository,
        _promosRepo       = promotionsRepository,
        _loyaltyRepo      = loyaltyRepository ?? LoyaltyRepository(),
        _statsRepo        = statsRepository   ?? StatsRepository(),
        _userId           = userId,
        super(const RestaurantDetailInitial());

  Future<void> load() async {
    emit(const RestaurantDetailLoading());

    final (lat, lng) = await _fetchLocation();

    try {
      // Carga establecimiento, promos y programa de lealtad en paralelo
      final results = await Future.wait([
        _estRepo.getById(
          id:      _establishmentId,
          userLat: lat,
          userLng: lng,
          userId:  _userId,
        ),
        _promosRepo.getByEstablishment(
          establishmentId: _establishmentId,
          lat:    lat,
          lng:    lng,
          userId: _userId,
        ),
      ]);

      final est = results[0] as dynamic;

      // Carga el programa de lealtad silenciosamente (no bloquea la pantalla)
      dynamic loyaltyProgram;
      try {
        loyaltyProgram = await _loyaltyRepo.getActiveProgram(
          establishmentId:   _establishmentId,
          establishmentName: est.name as String,
        );
      } catch (_) {
        loyaltyProgram = null;
      }

      emit(RestaurantDetailLoaded(
        establishment:  est,
        promos:         results[1] as dynamic,
        loyaltyProgram: loyaltyProgram,
      ));

      // Registra la vista del establecimiento (fire-and-forget)
      _statsRepo.logEstablishmentView(_establishmentId);
    } catch (e, st) {
      debugPrint('❌ RestaurantDetailCubit.load error: $e');
      debugPrint('$st');
      emit(const RestaurantDetailError(
          message: 'No se pudo cargar el restaurante.'));
    }
  }

  // ── Toggle favorito de establecimiento (optimistic update) ───────────────

  Future<void> toggleEstablishmentFavorite() async {
    final current = state;
    final userId  = _userId;
    if (current is! RestaurantDetailLoaded || userId == null) return;

    final newFav   = !current.establishment.isFavorited;
    final newCount = (current.establishment.favoritesCount + (newFav ? 1 : -1))
        .clamp(0, 999999);
    emit(current.copyWith(
      establishment: current.establishment.copyWith(
        isFavorited:    newFav,
        favoritesCount: newCount,
      ),
    ));

    try {
      await _estRepo.toggleFavorite(
        userId:          userId,
        establishmentId: _establishmentId,
      );
    } catch (_) {
      emit(current); // revertir si falla
    }
  }

  // ── Toggle favorito de promo (optimistic update) ──────────────────────────

  Future<void> toggleFavorite(PromotionModel promo) async {
    final current = state;
    final userId  = _userId;
    if (current is! RestaurantDetailLoaded || userId == null) return;

    final updated = current.promos.map((p) {
      if (p.id != promo.id) return p;
      return p.copyWith(
        isFavorited:    !p.isFavorited,
        favoritesCount: p.isFavorited
            ? p.favoritesCount - 1
            : p.favoritesCount + 1,
      );
    }).toList();
    emit(current.copyWith(promos: updated));

    try {
      await _promosRepo.toggleFavorite(userId: userId, promo: promo);
    } catch (_) {
      emit(current); // revertir si falla
    }
  }

  // ── Registrar clic en botón de contacto (fire-and-forget) ───────────────

  void logContactClick(String type) {
    _statsRepo.logContactClick(
      establishmentId: _establishmentId,
      clickType:       type,
    );
  }

  Future<(double, double)> _fetchLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return (_fallbackLat, _fallbackLng);
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );
      return (pos.latitude, pos.longitude);
    } catch (_) {
      return (_fallbackLat, _fallbackLng);
    }
  }
}
