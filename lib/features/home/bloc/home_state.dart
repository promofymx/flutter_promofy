import 'package:equatable/equatable.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/characteristic_model.dart';
import '../../../data/models/filter_model.dart';
import '../../../data/models/promotion_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<PromotionModel> promos;
  final bool hasMore;
  final int currentPage;
  final double? userLat;
  final double? userLng;
  final HomeFilters filters;
  final List<CategoryModel> categories;
  final List<CharacteristicModel> characteristics;

  /// true mientras se está re-fetching por cambio de filtro
  /// (muestra barra de progreso sin quitar las promos actuales)
  final bool isApplyingFilters;

  const HomeLoaded({
    required this.promos,
    required this.hasMore,
    required this.currentPage,
    this.userLat,
    this.userLng,
    this.filters          = const HomeFilters(),
    this.categories       = const [],
    this.characteristics  = const [],
    this.isApplyingFilters = false,
  });

  HomeLoaded copyWith({
    List<PromotionModel>?      promos,
    bool?                      hasMore,
    int?                       currentPage,
    double?                    userLat,
    double?                    userLng,
    HomeFilters?               filters,
    List<CategoryModel>?       categories,
    List<CharacteristicModel>? characteristics,
    bool?                      isApplyingFilters,
  }) {
    return HomeLoaded(
      promos:            promos            ?? this.promos,
      hasMore:           hasMore           ?? this.hasMore,
      currentPage:       currentPage       ?? this.currentPage,
      userLat:           userLat           ?? this.userLat,
      userLng:           userLng           ?? this.userLng,
      filters:           filters           ?? this.filters,
      categories:        categories        ?? this.categories,
      characteristics:   characteristics   ?? this.characteristics,
      isApplyingFilters: isApplyingFilters ?? this.isApplyingFilters,
    );
  }

  @override
  List<Object?> get props => [
        promos, hasMore, currentPage, userLat, userLng,
        filters, categories, characteristics, isApplyingFilters,
      ];
}

/// Cargando la siguiente página mientras se muestran las actuales
class HomeLoadingMore extends HomeState {
  final List<PromotionModel> promos;
  final HomeFilters filters;
  final List<CategoryModel> categories;
  final List<CharacteristicModel> characteristics;

  const HomeLoadingMore({
    required this.promos,
    required this.filters,
    required this.categories,
    required this.characteristics,
  });

  @override
  List<Object?> get props => [promos, filters, categories, characteristics];
}

class HomeError extends HomeState {
  final String message;
  const HomeError({required this.message});
  @override
  List<Object?> get props => [message];
}
