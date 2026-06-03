import '../datasources/supabase/promotions_datasource.dart';
import '../models/filter_model.dart';
import '../models/promotion_model.dart';

class PromotionsRepository {
  final PromotionsDatasource _datasource;

  PromotionsRepository({PromotionsDatasource? datasource})
      : _datasource = datasource ?? PromotionsDatasource();

  Future<List<PromotionModel>> getByDistance({
    required double lat,
    required double lng,
    int page     = 0,
    int radiusKm = 25,
    String? userId,
    HomeFilters filters = const HomeFilters(),
  }) async {
    final results = await _datasource.getByDistance(
      lat:      lat,
      lng:      lng,
      page:     page,
      limit:    10,
      radiusKm: radiusKm,
      userId:   userId,
      filters:  filters,
    );
    // Filtrar promos relámpago que ya expiraron
    return results.where((p) => !p.isFlashExpired).toList();
  }

  /// Devuelve todas las promos marcadas como favorito por el usuario,
  /// ordenadas por distancia.
  Future<List<PromotionModel>> getFavorites({
    required String userId,
    required double lat,
    required double lng,
  }) async {
    return _datasource.getByDistance(
      lat:                 lat,
      lng:                 lng,
      page:                0,
      limit:               50,
      userId:              userId,
      filterFavoritesOnly: true,
    );
  }

  /// Todas las promos activas de un establecimiento específico.
  Future<List<PromotionModel>> getByEstablishment({
    required String establishmentId,
    required double lat,
    required double lng,
    String? userId,
  }) async {
    return _datasource.getByDistance(
      lat:                    lat,
      lng:                    lng,
      page:                   0,
      limit:                  50,
      userId:                 userId,
      filterEstablishmentId:  establishmentId,
    );
  }

  Future<List<PromotionModel>> getBirthdayPromos({
    required double lat,
    required double lng,
    int page     = 0,
    int radiusKm = 25,
    String? userId,
  }) async {
    return _datasource.getBirthdayPromos(
      lat:      lat,
      lng:      lng,
      page:     page,
      limit:    20,
      radiusKm: radiusKm,
      userId:   userId,
    );
  }

  Future<void> toggleFavorite({
    required String userId,
    required PromotionModel promo,
  }) async {
    if (promo.isFavorited) {
      await _datasource.removeFavorite(userId, promo.id);
    } else {
      await _datasource.addFavorite(userId, promo.id);
    }
  }
}
