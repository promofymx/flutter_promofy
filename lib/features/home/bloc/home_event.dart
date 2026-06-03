import 'package:equatable/equatable.dart';
import '../../../data/models/filter_model.dart';
import '../../../data/models/promotion_model.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

/// Carga inicial al abrir el home
class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// Pull to refresh
class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

/// Scroll llegó al final → cargar siguiente página
class HomeNextPageRequested extends HomeEvent {
  const HomeNextPageRequested();
}

/// Toque en el corazón de una promo
class HomePromoFavoriteToggled extends HomeEvent {
  final PromotionModel promo;
  const HomePromoFavoriteToggled({required this.promo});
  @override
  List<Object?> get props => [promo.id];
}

/// Timer de 30 segundos → refrescar ubicación y promos
class HomeLocationRefreshed extends HomeEvent {
  const HomeLocationRefreshed();
}

/// El usuario aplicó o cambió filtros
class HomeFiltersChanged extends HomeEvent {
  final HomeFilters filters;
  const HomeFiltersChanged({required this.filters});
  @override
  List<Object?> get props => [filters];
}

/// El usuario escribió (o borró) texto en la barra de búsqueda.
/// El debounce se gestiona en la UI — el BLoC recibe solo el término final.
class HomeSearchChanged extends HomeEvent {
  final String query;
  const HomeSearchChanged({required this.query});
  @override
  List<Object?> get props => [query];
}

/// El usuario cambió su radio de búsqueda en Configuración.
class HomeRadiusChanged extends HomeEvent {
  final int radiusKm;
  const HomeRadiusChanged({required this.radiusKm});
  @override
  List<Object?> get props => [radiusKm];
}

/// El usuario cambió el favorito desde la pantalla de detalle.
/// Solo sincroniza el estado local — la llamada a la API ya se hizo allá.
class HomePromoFavoriteSynced extends HomeEvent {
  final String promoId;
  final bool   isFavorited;
  const HomePromoFavoriteSynced({
    required this.promoId,
    required this.isFavorited,
  });
  @override
  List<Object?> get props => [promoId, isFavorited];
}
