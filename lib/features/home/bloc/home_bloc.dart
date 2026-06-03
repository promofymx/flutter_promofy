import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/characteristic_model.dart';
import '../../../data/models/filter_model.dart';
import '../../../data/models/promotion_model.dart';
import '../../../data/repositories/categories_repository.dart';
import '../../../data/repositories/promotions_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final PromotionsRepository _promotionsRepo;
  final CategoriesRepository _categoriesRepo;
  final String? _userId;

  Timer? _locationTimer;
  double? _lat;
  double? _lng;
  int     _radiusKm = 25;

  // Catálogos cacheados en memoria — se cargan una sola vez al inicio
  List<CategoryModel> _cachedCategories = [];
  List<CharacteristicModel> _cachedCharacteristics = [];

  static const _fallbackLat = 21.8853;
  static const _fallbackLng = -102.2916;

  HomeBloc({
    required PromotionsRepository promotionsRepository,
    required CategoriesRepository categoriesRepository,
    String? userId,
    int initialRadiusKm = 25,
  })  : _promotionsRepo = promotionsRepository,
        _categoriesRepo = categoriesRepository,
        _userId = userId,
        _radiusKm = initialRadiusKm,
        super(HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshRequested>(_onRefresh);
    on<HomeNextPageRequested>(_onNextPage);
    on<HomePromoFavoriteToggled>(_onFavoriteToggled);
    on<HomePromoFavoriteSynced>(_onFavoriteSynced);
    on<HomeLocationRefreshed>(_onLocationRefreshed);
    on<HomeFiltersChanged>(_onFiltersChanged);
    on<HomeSearchChanged>(_onSearchChanged);
    on<HomeRadiusChanged>(_onRadiusChanged);
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Ejecuta la consulta correcta según los filtros activos.
  /// Cuando [birthdayOnly] está activado, llama al RPC de cumpleaños;
  /// en caso contrario usa el RPC estándar por distancia.
  Future<List<PromotionModel>> _getPromos({
    required HomeFilters filters,
    int page = 0,
  }) async {
    if (filters.birthdayOnly) {
      return _promotionsRepo.getBirthdayPromos(
        lat:      _lat!,
        lng:      _lng!,
        page:     page,
        radiusKm: _radiusKm,
        userId:   _userId,
      );
    }
    return _promotionsRepo.getByDistance(
      lat:      _lat!,
      lng:      _lng!,
      page:     page,
      radiusKm: _radiusKm,
      userId:   _userId,
      filters:  filters,
    );
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

  void _startLocationTimer() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => add(const HomeLocationRefreshed()),
    );
  }

  /// Devuelve los filtros activos del estado actual (o vacío si no aplica)
  HomeFilters _currentFilters() {
    final s = state;
    if (s is HomeLoaded) return s.filters;
    if (s is HomeLoadingMore) return s.filters;
    return const HomeFilters();
  }

  // ─── Handlers ──────────────────────────────────────────────────────────────

  // Filtros iniciales: "Activas ahora" pre-seleccionado al arrancar la app.
  static const _defaultFilters = HomeFilters(activeNow: true);

  Future<void> _onStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    await _fetchLocation();

    try {
      final promos = await _getPromos(filters: _defaultFilters);

      // Carga catálogos para filtros; si falla no bloquea las promos
      try {
        _cachedCategories      = await _categoriesRepo.getCategories();
        _cachedCharacteristics = await _categoriesRepo.getCharacteristics();
      } catch (_) {
        _cachedCategories      = [];
        _cachedCharacteristics = [];
      }

      emit(HomeLoaded(
        promos:          promos,
        hasMore:         promos.length == 10,
        currentPage:     0,
        userLat:         _lat,
        userLng:         _lng,
        filters:         _defaultFilters,
        categories:      _cachedCategories,
        characteristics: _cachedCharacteristics,
      ));
      _startLocationTimer();
    } catch (_) {
      emit(const HomeError(message: 'No se pudieron cargar las promociones.'));
    }
  }

  Future<void> _onRefresh(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    await _fetchLocation();
    final filters = _currentFilters();
    try {
      final promos = await _getPromos(filters: filters);
      emit(HomeLoaded(
        promos:          promos,
        hasMore:         promos.length == 10,
        currentPage:     0,
        userLat:         _lat,
        userLng:         _lng,
        filters:         filters,
        categories:      _cachedCategories,
        characteristics: _cachedCharacteristics,
      ));
    } catch (_) {
      // Refresh silencioso: mantener estado actual si falla
    }
  }

  Future<void> _onNextPage(
    HomeNextPageRequested event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is! HomeLoaded || !current.hasMore) return;

    emit(HomeLoadingMore(
      promos:          current.promos,
      filters:         current.filters,
      categories:      current.categories,
      characteristics: current.characteristics,
    ));

    try {
      final nextPage  = current.currentPage + 1;
      final newPromos = await _getPromos(
        filters: current.filters,
        page:    nextPage,
      );
      emit(HomeLoaded(
        promos:          [...current.promos, ...newPromos],
        hasMore:         newPromos.length == 10,
        currentPage:     nextPage,
        userLat:         _lat,
        userLng:         _lng,
        filters:         current.filters,
        categories:      current.categories,
        characteristics: current.characteristics,
      ));
    } catch (_) {
      emit(current); // volver al estado anterior si falla
    }
  }

  Future<void> _onFavoriteToggled(
    HomePromoFavoriteToggled event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is! HomeLoaded || _userId == null) return;

    // Actualiza la UI inmediatamente (optimistic update)
    final updated = current.promos.map((p) {
      if (p.id != event.promo.id) return p;
      return p.copyWith(
        isFavorited:    !p.isFavorited,
        favoritesCount: p.isFavorited
            ? p.favoritesCount - 1
            : p.favoritesCount + 1,
      );
    }).toList();

    emit(current.copyWith(promos: updated));

    // Luego persiste en Supabase
    try {
      await _promotionsRepo.toggleFavorite(
        userId: _userId,
        promo:  event.promo,
      );
    } catch (_) {
      emit(current); // revertir si falla
    }
  }

  /// Sincroniza el estado local de una promo después de que el usuario
  /// cambió el favorito desde la pantalla de detalle (sin llamar a la API).
  void _onFavoriteSynced(
    HomePromoFavoriteSynced event,
    Emitter<HomeState> emit,
  ) {
    final current = state;
    if (current is! HomeLoaded) return;

    final updated = current.promos.map((p) {
      if (p.id != event.promoId || p.isFavorited == event.isFavorited) return p;
      return p.copyWith(
        isFavorited:    event.isFavorited,
        favoritesCount: p.favoritesCount + (event.isFavorited ? 1 : -1),
      );
    }).toList();

    emit(current.copyWith(promos: updated));
  }

  Future<void> _onLocationRefreshed(
    HomeLocationRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    await _fetchLocation();
    add(const HomeRefreshRequested());
  }

  Future<void> _onFiltersChanged(
    HomeFiltersChanged event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is! HomeLoaded) return;

    // Muestra barra de progreso manteniendo las promos actuales visibles
    emit(current.copyWith(
      isApplyingFilters: true,
      filters: event.filters,
    ));

    try {
      final promos = await _getPromos(filters: event.filters);
      emit(HomeLoaded(
        promos:          promos,
        hasMore:         promos.length == 10,
        currentPage:     0,
        userLat:         _lat,
        userLng:         _lng,
        filters:         event.filters,
        categories:      _cachedCategories,
        characteristics: _cachedCharacteristics,
      ));
    } catch (_) {
      // Si falla, revertir al estado anterior sin la barra de progreso
      emit(current.copyWith(isApplyingFilters: false));
    }
  }

  Future<void> _onSearchChanged(
    HomeSearchChanged event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is! HomeLoaded) return;

    final newFilters = current.filters.copyWith(searchQuery: event.query);

    emit(current.copyWith(isApplyingFilters: true, filters: newFilters));

    try {
      final promos = await _getPromos(filters: newFilters);
      emit(HomeLoaded(
        promos:          promos,
        hasMore:         promos.length == 10,
        currentPage:     0,
        userLat:         _lat,
        userLng:         _lng,
        filters:         newFilters,
        categories:      _cachedCategories,
        characteristics: _cachedCharacteristics,
      ));
    } catch (_) {
      emit(current.copyWith(isApplyingFilters: false));
    }
  }

  Future<void> _onRadiusChanged(
    HomeRadiusChanged event,
    Emitter<HomeState> emit,
  ) async {
    _radiusKm = event.radiusKm;
    // Si todavía no se ha cargado la ubicación, el nuevo radio se usará
    // automáticamente en la próxima carga.
    if (_lat == null) return;
    // Recargar el feed con el nuevo radio
    await _fetchLocation();
    final filters = _currentFilters();
    try {
      final promos = await _getPromos(filters: filters);
      emit(HomeLoaded(
        promos:          promos,
        hasMore:         promos.length == 10,
        currentPage:     0,
        userLat:         _lat,
        userLng:         _lng,
        filters:         filters,
        categories:      _cachedCategories,
        characteristics: _cachedCharacteristics,
      ));
    } catch (_) {
      // Fallo silencioso — el radio queda guardado para la próxima carga.
    }
  }

  @override
  Future<void> close() {
    _locationTimer?.cancel();
    return super.close();
  }
}
