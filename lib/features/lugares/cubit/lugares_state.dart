import 'package:equatable/equatable.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/characteristic_model.dart';
import '../../../data/models/establishment_model.dart';

abstract class LugaresState extends Equatable {
  const LugaresState();
  @override
  List<Object?> get props => [];
}

class LugaresInitial extends LugaresState {}

class LugaresLoading extends LugaresState {}

class LugaresLoaded extends LugaresState {
  final List<EstablishmentModel>   establishments;
  final bool                       hasMore;
  final int                        currentPage;
  final bool                       isRefreshing;

  // ── Filtros rápidos (chips) ──────────────────────────────────────────────
  final bool flashOnly;
  final bool openNow;
  final bool favoritesOnly;

  // ── Filtros avanzados (bottom sheet) ─────────────────────────────────────
  final String?       selectedCategoryId;
  final List<String>  selectedCharacteristicIds;
  final int?          dayOfWeek;       // 1=Lun … 7=Dom (ISO)
  final String?       paymentMethod;   // efectivo|tarjeta|transferencia|mercadopago
  final String?       timeBand;        // desayuno|comida|cena|madrugada

  // ── Búsqueda ─────────────────────────────────────────────────────────────
  final String searchQuery;

  // ── Catálogos para los filtros ────────────────────────────────────────────
  final List<CategoryModel>       categories;
  final List<CharacteristicModel> characteristics;

  const LugaresLoaded({
    required this.establishments,
    required this.hasMore,
    required this.currentPage,
    this.isRefreshing              = false,
    this.flashOnly                 = false,
    this.openNow                   = false,
    this.favoritesOnly             = false,
    this.selectedCategoryId,
    this.selectedCharacteristicIds = const [],
    this.dayOfWeek,
    this.paymentMethod,
    this.timeBand,
    this.searchQuery               = '',
    this.categories                = const [],
    this.characteristics           = const [],
  });

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool get hasCategoryFilter       => selectedCategoryId != null;
  bool get hasCharacteristicFilter => selectedCharacteristicIds.isNotEmpty;

  /// Filtros activos contados para el badge "Más filtros".
  int get advancedFilterCount {
    int n = 0;
    if (hasCategoryFilter) n++;
    if (hasCharacteristicFilter) n++;
    if (dayOfWeek != null) n++;
    if (paymentMethod != null) n++;
    if (timeBand != null) n++;
    return n;
  }

  /// Total de filtros activos (badge del AppBar si lo hubiera).
  int get activeFilterCount {
    int n = advancedFilterCount;
    if (flashOnly) n++;
    if (openNow) n++;
    if (favoritesOnly) n++;
    return n;
  }

  String? get selectedCategoryName {
    if (selectedCategoryId == null) return null;
    try {
      return categories.firstWhere((c) => c.id == selectedCategoryId).name;
    } catch (_) {
      return null;
    }
  }

  // ── copyWith con sentinel para nulables ───────────────────────────────────

  static const _sentinel = Object();

  LugaresLoaded copyWith({
    List<EstablishmentModel>?  establishments,
    bool?                      hasMore,
    int?                       currentPage,
    bool?                      isRefreshing,
    bool?                      flashOnly,
    bool?                      openNow,
    bool?                      favoritesOnly,
    Object?                    selectedCategoryId       = _sentinel,
    List<String>?              selectedCharacteristicIds,
    Object?                    dayOfWeek                = _sentinel,
    Object?                    paymentMethod            = _sentinel,
    Object?                    timeBand                 = _sentinel,
    String?                    searchQuery,
    List<CategoryModel>?       categories,
    List<CharacteristicModel>? characteristics,
  }) {
    return LugaresLoaded(
      establishments:           establishments           ?? this.establishments,
      hasMore:                  hasMore                  ?? this.hasMore,
      currentPage:              currentPage              ?? this.currentPage,
      isRefreshing:             isRefreshing             ?? this.isRefreshing,
      flashOnly:                flashOnly                ?? this.flashOnly,
      openNow:                  openNow                  ?? this.openNow,
      favoritesOnly:            favoritesOnly            ?? this.favoritesOnly,
      selectedCategoryId:       identical(selectedCategoryId, _sentinel)
          ? this.selectedCategoryId
          : selectedCategoryId as String?,
      selectedCharacteristicIds: selectedCharacteristicIds
          ?? this.selectedCharacteristicIds,
      dayOfWeek:    identical(dayOfWeek, _sentinel)
          ? this.dayOfWeek
          : dayOfWeek as int?,
      paymentMethod: identical(paymentMethod, _sentinel)
          ? this.paymentMethod
          : paymentMethod as String?,
      timeBand: identical(timeBand, _sentinel)
          ? this.timeBand
          : timeBand as String?,
      searchQuery:              searchQuery              ?? this.searchQuery,
      categories:               categories               ?? this.categories,
      characteristics:          characteristics          ?? this.characteristics,
    );
  }

  @override
  List<Object?> get props => [
        establishments, hasMore, currentPage, isRefreshing,
        flashOnly, openNow, favoritesOnly,
        selectedCategoryId, selectedCharacteristicIds,
        dayOfWeek, paymentMethod, timeBand,
        searchQuery, categories, characteristics,
      ];
}

class LugaresError extends LugaresState {
  final String message;
  const LugaresError({required this.message});
  @override
  List<Object?> get props => [message];
}
