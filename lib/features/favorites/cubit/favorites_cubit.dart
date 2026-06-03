import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/establishment_model.dart';
import '../../../data/models/promotion_model.dart';
import '../../../data/repositories/establishments_repository.dart';
import '../../../data/repositories/promotions_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final PromotionsRepository     _promosRepo;
  final EstablishmentsRepository _estsRepo;
  final String _userId;

  static const _fallbackLat = 21.8853;
  static const _fallbackLng = -102.2916;

  double? _lat;
  double? _lng;

  FavoritesCubit({
    required PromotionsRepository     repository,
    required EstablishmentsRepository establishmentsRepository,
    required String                   userId,
  })  : _promosRepo = repository,
        _estsRepo   = establishmentsRepository,
        _userId     = userId,
        super(FavoritesInitial());

  Future<void> load() async {
    emit(FavoritesLoading());
    await _fetchLocation();
    try {
      final results = await Future.wait([
        _promosRepo.getFavorites(
          userId: _userId,
          lat:    _lat!,
          lng:    _lng!,
        ),
        _estsRepo.getFavoriteEstablishments(
          userId: _userId,
          lat:    _lat!,
          lng:    _lng!,
        ),
      ]);
      emit(FavoritesLoaded(
        promos:         results[0] as List<PromotionModel>,
        establishments: results[1] as List<EstablishmentModel>,
      ));
    } catch (_) {
      emit(const FavoritesError(
          message: 'No se pudieron cargar tus favoritos.'));
    }
  }

  /// Recarga en segundo plano sin mostrar spinner.
  Future<void> refresh() async {
    if (_lat == null) await _fetchLocation();
    try {
      final results = await Future.wait([
        _promosRepo.getFavorites(
          userId: _userId,
          lat:    _lat!,
          lng:    _lng!,
        ),
        _estsRepo.getFavoriteEstablishments(
          userId: _userId,
          lat:    _lat!,
          lng:    _lng!,
        ),
      ]);
      emit(FavoritesLoaded(
        promos:         results[0] as List<PromotionModel>,
        establishments: results[1] as List<EstablishmentModel>,
      ));
    } catch (_) {
      // Fallo silencioso — no ocultamos los datos ya cargados
    }
  }

  /// Quita una promo de favoritos con optimistic update.
  Future<void> removeFavorite(PromotionModel promo) async {
    final current = state;
    if (current is! FavoritesLoaded) return;

    final updated = current.promos.where((p) => p.id != promo.id).toList();
    emit(current.copyWith(promos: updated));

    try {
      await _promosRepo.toggleFavorite(userId: _userId, promo: promo);
    } catch (_) {
      emit(current);
    }
  }

  /// Quita un establecimiento de favoritos con optimistic update.
  Future<void> removeFavoriteEstablishment(EstablishmentModel est) async {
    final current = state;
    if (current is! FavoritesLoaded) return;

    final updated =
        current.establishments.where((e) => e.id != est.id).toList();
    emit(current.copyWith(establishments: updated));

    try {
      await _estsRepo.toggleFavorite(
        userId:          _userId,
        establishmentId: est.id,
      );
    } catch (_) {
      emit(current);
    }
  }

  Future<void> _fetchLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _lat = _fallbackLat;
        _lng = _fallbackLng;
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );
      _lat = pos.latitude;
      _lng = pos.longitude;
    } catch (_) {
      _lat = _fallbackLat;
      _lng = _fallbackLng;
    }
  }
}
