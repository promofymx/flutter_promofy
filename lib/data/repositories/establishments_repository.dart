import '../datasources/supabase/establishments_datasource.dart';
import '../models/establishment_model.dart';

class EstablishmentsRepository {
  final EstablishmentsDatasource _datasource;

  EstablishmentsRepository({EstablishmentsDatasource? datasource})
      : _datasource = datasource ?? EstablishmentsDatasource();

  Future<EstablishmentModel> getById({
    required String id,
    double? userLat,
    double? userLng,
    String? userId,
  }) {
    return _datasource.getById(
      id:      id,
      userLat: userLat,
      userLng: userLng,
      userId:  userId,
    );
  }

  Future<void> toggleFavorite({
    required String userId,
    required String establishmentId,
  }) {
    return _datasource.toggleFavorite(
      userId:          userId,
      establishmentId: establishmentId,
    );
  }

  Future<List<EstablishmentModel>> getByDistance({
    required double lat,
    required double lng,
    int     page      = 0,
    int     pageSize  = 20,
    bool    flashOnly = false,
    String? searchQuery,
    String? userId,
    int?    filterCategoryId,
    List<int>? filterCharacteristicIds,
  }) {
    return _datasource.getByDistance(
      lat:                     lat,
      lng:                     lng,
      page:                    page,
      pageSize:                pageSize,
      flashOnly:               flashOnly,
      searchQuery:             searchQuery,
      userId:                  userId,
      filterCategoryId:        filterCategoryId,
      filterCharacteristicIds: filterCharacteristicIds,
    );
  }

  Future<List<EstablishmentModel>> getFavoriteEstablishments({
    required String userId,
    required double lat,
    required double lng,
  }) {
    return _datasource.getFavoriteEstablishments(
      userId: userId,
      lat:    lat,
      lng:    lng,
    );
  }
}
