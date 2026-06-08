import '../../../main.dart';
import '../../models/establishment_model.dart';

class EstablishmentsDatasource {
  Future<EstablishmentModel> getById({
    required String id,
    double? userLat,
    double? userLng,
    String? userId,
  }) async {
    final response = await supabase.rpc(
      'get_establishment_detail',
      params: {
        'p_establishment_id': id,
        'user_lat':           userLat,
        'user_lng':           userLng,
        'p_user_id':          userId,
      },
    );
    return EstablishmentModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> toggleFavorite({
    required String userId,
    required String establishmentId,
  }) async {
    await supabase.rpc('toggle_favorite_establishment', params: {
      'p_user_id':          userId,
      'p_establishment_id': establishmentId,
    });
  }

  /// Lista de establecimientos ordenados por distancia para la pantalla Lugares.
  Future<List<EstablishmentModel>> getByDistance({
    required double  lat,
    required double  lng,
    int     page     = 0,
    int     pageSize = 20,
    bool    flashOnly = false,
    String? searchQuery,
    String? userId,
    int?    filterCategoryId,
    List<int>? filterCharacteristicIds,
    String? filterTimeBand,
  }) async {
    final rows = await supabase.rpc(
      'get_establishments_by_distance',
      params: {
        'user_lat':                  lat,
        'user_lng':                  lng,
        'page_number':               page,
        'page_size':                 pageSize,
        'flash_only':                flashOnly,
        'search_query':              (searchQuery == null || searchQuery.isEmpty)
            ? null
            : searchQuery,
        'current_user_id':           userId,
        'radius_km':                 50.0,
        'filter_category_id':        filterCategoryId,
        'filter_characteristic_ids': (filterCharacteristicIds == null ||
                filterCharacteristicIds.isEmpty)
            ? null
            : filterCharacteristicIds,
        'filter_time_band':          filterTimeBand,
      },
    );
    return (rows as List)
        .map((e) => EstablishmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<EstablishmentModel>> getFavoriteEstablishments({
    required String userId,
    required double lat,
    required double lng,
  }) async {
    final rows = await supabase.rpc('get_favorite_establishments', params: {
      'p_user_id': userId,
      'user_lat':  lat,
      'user_lng':  lng,
    });
    return (rows as List)
        .map((e) => EstablishmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
