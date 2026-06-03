import 'package:equatable/equatable.dart';
import '../../../data/models/establishment_model.dart';
import '../../../data/models/promotion_model.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();
  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<PromotionModel>     promos;
  final List<EstablishmentModel> establishments;

  const FavoritesLoaded({
    required this.promos,
    required this.establishments,
  });

  FavoritesLoaded copyWith({
    List<PromotionModel>?     promos,
    List<EstablishmentModel>? establishments,
  }) =>
      FavoritesLoaded(
        promos:         promos         ?? this.promos,
        establishments: establishments ?? this.establishments,
      );

  @override
  List<Object?> get props => [promos, establishments];
}

class FavoritesError extends FavoritesState {
  final String message;
  const FavoritesError({required this.message});
  @override
  List<Object?> get props => [message];
}
