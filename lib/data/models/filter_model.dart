import 'package:equatable/equatable.dart';

/// Estado de los filtros activos en el home.
class HomeFilters extends Equatable {
  final bool activeNow;
  final bool flashOnly;

  /// Muestra solo las promos marcadas como favoritas por el usuario.
  /// Solo funciona si el usuario está autenticado (userId no nulo).
  final bool favoritesOnly;

  /// Muestra solo promos de tipo 'birthday' (Cumpleañero).
  final bool birthdayOnly;

  final String? categoryId;
  final List<String> characteristicIds;
  final int? dayOfWeek; // 1=Lun … 7=Dom (ISO)
  final String? paymentMethod;

  /// Franja horaria: 'desayuno' | 'comida' | 'cena' | 'madrugada'.
  final String? timeBand;

  /// Texto de búsqueda libre (filtrado server-side por nombre de promo/restaurante).
  /// No se muestra en el badge de filtros — tiene su propia barra de búsqueda.
  final String searchQuery;

  const HomeFilters({
    this.activeNow = false,
    this.flashOnly = false,
    this.favoritesOnly = false,
    this.birthdayOnly = false,
    this.categoryId,
    this.characteristicIds = const [],
    this.dayOfWeek,
    this.paymentMethod,
    this.timeBand,
    this.searchQuery = '',
  });

  /// ¿Hay al menos un filtro avanzado o chip activo?
  bool get hasActiveFilters =>
      activeNow ||
      flashOnly ||
      favoritesOnly ||
      birthdayOnly ||
      categoryId != null ||
      characteristicIds.isNotEmpty ||
      dayOfWeek != null ||
      paymentMethod != null ||
      timeBand != null;

  /// Total de filtros activos (chips rápidos + avanzados) — para el badge del AppBar.
  /// La búsqueda libre no se cuenta aquí.
  int get activeCount {
    int n = 0;
    if (activeNow) n++;
    if (flashOnly) n++;
    if (favoritesOnly) n++;
    if (birthdayOnly) n++;
    if (categoryId != null) n++;
    if (characteristicIds.isNotEmpty) n++;
    if (dayOfWeek != null) n++;
    if (paymentMethod != null) n++;
    if (timeBand != null) n++;
    return n;
  }

  /// Solo filtros del bottom sheet — para el badge del chip "Más filtros".
  int get advancedCount {
    int n = 0;
    if (categoryId != null) n++;
    if (characteristicIds.isNotEmpty) n++;
    if (dayOfWeek != null) n++;
    if (paymentMethod != null) n++;
    if (timeBand != null) n++;
    return n;
  }

  // Sentinel: permite pasar null explícito en copyWith para limpiar valores
  static const _unset = Object();

  HomeFilters copyWith({
    bool? activeNow,
    bool? flashOnly,
    bool? favoritesOnly,
    bool? birthdayOnly,
    Object? categoryId = _unset,
    List<String>? characteristicIds,
    Object? dayOfWeek = _unset,
    Object? paymentMethod = _unset,
    Object? timeBand = _unset,
    String? searchQuery,
  }) {
    return HomeFilters(
      activeNow:         activeNow         ?? this.activeNow,
      flashOnly:         flashOnly         ?? this.flashOnly,
      favoritesOnly:     favoritesOnly     ?? this.favoritesOnly,
      birthdayOnly:      birthdayOnly      ?? this.birthdayOnly,
      categoryId: identical(categoryId, _unset)
          ? this.categoryId
          : categoryId as String?,
      characteristicIds: characteristicIds ?? this.characteristicIds,
      dayOfWeek: identical(dayOfWeek, _unset)
          ? this.dayOfWeek
          : dayOfWeek as int?,
      paymentMethod: identical(paymentMethod, _unset)
          ? this.paymentMethod
          : paymentMethod as String?,
      timeBand: identical(timeBand, _unset)
          ? this.timeBand
          : timeBand as String?,
      searchQuery:       searchQuery       ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        activeNow,
        flashOnly,
        favoritesOnly,
        birthdayOnly,
        categoryId,
        characteristicIds,
        dayOfWeek,
        paymentMethod,
        timeBand,
        searchQuery,
      ];
}
