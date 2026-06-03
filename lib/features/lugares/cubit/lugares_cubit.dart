import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/characteristic_model.dart';
import '../../../data/models/establishment_model.dart';
import '../../../data/repositories/categories_repository.dart';
import '../../../data/repositories/establishments_repository.dart';
import 'lugares_state.dart';

class LugaresCubit extends Cubit<LugaresState> {
  final EstablishmentsRepository _repo;
  final CategoriesRepository     _categoriesRepo;
  final String?                  _userId;

  double? _lat;
  double? _lng;

  // Catálogos cacheados
  List<CategoryModel>       _cachedCategories      = [];
  List<CharacteristicModel> _cachedCharacteristics = [];

  static const _fallbackLat = 21.8853;
  static const _fallbackLng = -102.2916;
  static const _pageSize    = 20;

  LugaresCubit({
    required EstablishmentsRepository repository,
    CategoriesRepository? categoriesRepository,
    String? userId,
  })  : _repo           = repository,
        _categoriesRepo = categoriesRepository ?? CategoriesRepository(),
        _userId         = userId,
        super(LugaresInitial());

  // ── Carga inicial ──────────────────────────────────────────────────────────

  Future<void> load() async {
    emit(LugaresLoading());
    await _fetchLocation();
    await _loadCatalogs();
    await _doFetch(page: 0);
  }

  // ── Refresh ────────────────────────────────────────────────────────────────

  Future<void> refresh() async {
    if (state is! LugaresLoaded) { await load(); return; }
    await _fetchLocation();
    await _doFetch(page: 0);
  }

  // ── Paginación ─────────────────────────────────────────────────────────────

  Future<void> loadMore() async {
    final s = state;
    if (s is! LugaresLoaded || !s.hasMore) return;
    // No paginar cuando el filtro de favoritos está activo
    if (s.favoritesOnly) return;
    final nextPage = s.currentPage + 1;
    try {
      final more = await _repo.getByDistance(
        lat:      _lat ?? _fallbackLat,
        lng:      _lng ?? _fallbackLng,
        page:     nextPage,
        pageSize: _pageSize,
        flashOnly:   s.flashOnly,
        searchQuery: s.searchQuery.isEmpty ? null : s.searchQuery,
        userId:      _userId,
        filterCategoryId: s.selectedCategoryId != null
            ? int.tryParse(s.selectedCategoryId!)
            : null,
        filterCharacteristicIds: s.selectedCharacteristicIds.isNotEmpty
            ? s.selectedCharacteristicIds
                .map((id) => int.tryParse(id))
                .whereType<int>()
                .toList()
            : null,
      );
      final filtered = _applyClientFilters(
        more,
        openNow:       s.openNow,
        dayOfWeek:     s.dayOfWeek,
        paymentMethod: s.paymentMethod,
      );
      if (!isClosed) {
        emit(s.copyWith(
          establishments: [...s.establishments, ...filtered],
          hasMore:        more.length == _pageSize,
          currentPage:    nextPage,
        ));
      }
    } catch (_) {}
  }

  // ── Filtros rápidos (chips) ────────────────────────────────────────────────

  Future<void> toggleFlash() async {
    if (state is! LugaresLoaded) return;
    final s = currentLoaded;
    emit(s.copyWith(isRefreshing: true, flashOnly: !s.flashOnly));
    await _doFetch(page: 0);
  }

  Future<void> toggleOpenNow() async {
    if (state is! LugaresLoaded) return;
    final s = currentLoaded;
    emit(s.copyWith(isRefreshing: true, openNow: !s.openNow));
    await _doFetch(page: 0);
  }

  Future<void> toggleFavoritesOnly() async {
    if (state is! LugaresLoaded) return;
    final s = currentLoaded;
    emit(s.copyWith(isRefreshing: true, favoritesOnly: !s.favoritesOnly));
    await _doFetch(page: 0);
  }

  // ── Búsqueda ────────────────────────────────────────────────────────────────

  Future<void> search(String query) async {
    if (state is! LugaresLoaded) return;
    emit(currentLoaded.copyWith(isRefreshing: true, searchQuery: query));
    await _doFetch(page: 0);
  }

  // ── Filtros avanzados (bottom sheet) ──────────────────────────────────────

  /// Aplica todos los filtros del bottom sheet a la vez.
  Future<void> applyAdvancedFilters({
    required String?      categoryId,
    required List<String> characteristicIds,
    required int?         dayOfWeek,
    required String?      paymentMethod,
  }) async {
    if (state is! LugaresLoaded) return;
    final s = currentLoaded;
    emit(s.copyWith(
      isRefreshing:              true,
      selectedCategoryId:        categoryId,
      selectedCharacteristicIds: characteristicIds,
      dayOfWeek:                 dayOfWeek,
      paymentMethod:             paymentMethod,
    ));
    await _doFetch(page: 0);
  }

  // ── Limpiar todos los filtros ──────────────────────────────────────────────

  Future<void> clearAllFilters() async {
    if (state is! LugaresLoaded) return;
    emit(currentLoaded.copyWith(
      isRefreshing:              true,
      flashOnly:                 false,
      openNow:                   false,
      favoritesOnly:             false,
      selectedCategoryId:        null,
      selectedCharacteristicIds: [],
      dayOfWeek:                 null,
      paymentMethod:             null,
    ));
    await _doFetch(page: 0);
  }

  // ── Helpers internos ──────────────────────────────────────────────────────

  LugaresLoaded get currentLoaded => state as LugaresLoaded;

  Future<void> _loadCatalogs() async {
    try {
      _cachedCategories      = await _categoriesRepo.getCategories();
      _cachedCharacteristics = await _categoriesRepo.getCharacteristics();
    } catch (_) {
      _cachedCategories      = [];
      _cachedCharacteristics = [];
    }
  }

  Future<void> _fetchLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _lat = _fallbackLat; _lng = _fallbackLng; return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );
      _lat = pos.latitude;
      _lng = pos.longitude;
    } catch (_) {
      _lat = _fallbackLat; _lng = _fallbackLng;
    }
  }

  /// Fetch principal. Lee el estado actual para obtener los filtros vigentes.
  Future<void> _doFetch({required int page}) async {
    final s = state is LugaresLoaded ? currentLoaded : null;

    final flashOnly              = s?.flashOnly              ?? false;
    final openNow                = s?.openNow                ?? false;
    final favoritesOnly          = s?.favoritesOnly          ?? false;
    final searchQuery            = s?.searchQuery            ?? '';
    final selectedCategoryId     = s?.selectedCategoryId;
    final selectedCharIds        = s?.selectedCharacteristicIds ?? [];
    final dayOfWeek              = s?.dayOfWeek;
    final paymentMethod          = s?.paymentMethod;

    try {
      List<EstablishmentModel> items;
      bool hasMore;

      final uid = _userId;
      if (favoritesOnly && uid != null) {
        // Carga directamente los favoritos (sin paginación)
        final favs = await _repo.getFavoriteEstablishments(
          userId: uid,
          lat:    _lat ?? _fallbackLat,
          lng:    _lng ?? _fallbackLng,
        );
        items   = favs;
        hasMore = false;
      } else {
        // Carga paginada normal
        items = await _repo.getByDistance(
          lat:      _lat ?? _fallbackLat,
          lng:      _lng ?? _fallbackLng,
          page:     page,
          pageSize: _pageSize,
          flashOnly:   flashOnly,
          searchQuery: searchQuery.isEmpty ? null : searchQuery,
          userId:      _userId,
          filterCategoryId: selectedCategoryId != null
              ? int.tryParse(selectedCategoryId)
              : null,
          filterCharacteristicIds: selectedCharIds.isNotEmpty
              ? selectedCharIds
                  .map((id) => int.tryParse(id))
                  .whereType<int>()
                  .toList()
              : null,
        );
        hasMore = items.length == _pageSize;
      }

      // Aplica filtros client-side (horario y método de pago)
      items = _applyClientFilters(
        items,
        openNow:       openNow,
        dayOfWeek:     dayOfWeek,
        paymentMethod: paymentMethod,
      );

      if (!isClosed) {
        emit(LugaresLoaded(
          establishments:           items,
          hasMore:                  hasMore,
          currentPage:              page,
          flashOnly:                flashOnly,
          openNow:                  openNow,
          favoritesOnly:            favoritesOnly,
          searchQuery:              searchQuery,
          categories:               _cachedCategories,
          characteristics:          _cachedCharacteristics,
          selectedCategoryId:       selectedCategoryId,
          selectedCharacteristicIds: selectedCharIds,
          dayOfWeek:                dayOfWeek,
          paymentMethod:            paymentMethod,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(const LugaresError(message: 'No se pudieron cargar los lugares.'));
      }
    }
  }

  /// Filtros que se aplican localmente sobre los resultados del servidor.
  List<EstablishmentModel> _applyClientFilters(
    List<EstablishmentModel> items, {
    required bool    openNow,
    required int?    dayOfWeek,
    required String? paymentMethod,
  }) {
    return items.where((e) {
      // ── Método de pago ───────────────────────────────────────────────────
      if (paymentMethod != null && !e.paymentMethods.contains(paymentMethod)) {
        return false;
      }

      // ── Horario (openNow usa el día de hoy; dayOfWeek usa el día elegido) ─
      if (openNow || dayOfWeek != null) {
        // Si no tiene horario configurado, no lo excluimos — no podemos saber
        // si está cerrado, así que lo mostramos por defecto.
        if (e.schedule != null && e.schedule!.isNotEmpty) {
          final isoDay = dayOfWeek ?? DateTime.now().weekday; // 1=Lun…7=Dom
          final key    = _isoToKey(isoDay);
          final day    = e.schedule![key];

          // Si tiene el día configurado, revisamos closed y horario
          if (day != null && day is Map) {
            final dayMap = Map<String, dynamic>.from(day);

            // Marcado explícitamente como cerrado ese día
            if (dayMap['closed'] == true) return false;

            // Verificar rango de horas solo para "Abiertos ahora"
            if (openNow) {
              final openStr  = dayMap['open']  as String? ?? '09:00';
              final closeStr = dayMap['close'] as String? ?? '22:00';
              final now      = TimeOfDay.now();
              final nowMin   = now.hour * 60 + now.minute;
              final openMin  = _timeToMinutes(openStr);
              final closeMin = _timeToMinutes(closeStr);
              // Si closeMin < openMin el horario cruza medianoche (ej. 13:00–01:00)
              final bool isOpen = closeMin < openMin
                  ? nowMin >= openMin || nowMin <= closeMin
                  : nowMin >= openMin && nowMin <= closeMin;
              if (!isOpen) return false;
            }
          }
          // Si el día no está en el schedule, tampoco lo excluimos
        }
      }

      return true;
    }).toList();
  }

  /// Mapea ISO weekday (1=Lun … 7=Dom) a la clave del schedule JSON.
  static String _isoToKey(int iso) {
    const keys = [
      '', // 0 unused
      'monday', 'tuesday', 'wednesday', 'thursday',
      'friday', 'saturday', 'sunday',
    ];
    return (iso >= 1 && iso <= 7) ? keys[iso] : 'monday';
  }

  static int _timeToMinutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }
}
