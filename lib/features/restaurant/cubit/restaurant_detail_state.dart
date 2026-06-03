import 'package:equatable/equatable.dart';
import '../../../data/models/establishment_model.dart';
import '../../../data/models/loyalty_program_model.dart';
import '../../../data/models/promotion_model.dart';

abstract class RestaurantDetailState extends Equatable {
  const RestaurantDetailState();
  @override
  List<Object?> get props => [];
}

class RestaurantDetailInitial extends RestaurantDetailState {
  const RestaurantDetailInitial();
}

class RestaurantDetailLoading extends RestaurantDetailState {
  const RestaurantDetailLoading();
}

class RestaurantDetailLoaded extends RestaurantDetailState {
  final EstablishmentModel    establishment;
  final List<PromotionModel>  promos;
  final LoyaltyProgramModel?  loyaltyProgram;

  const RestaurantDetailLoaded({
    required this.establishment,
    required this.promos,
    this.loyaltyProgram,
  });

  RestaurantDetailLoaded copyWith({
    EstablishmentModel?   establishment,
    List<PromotionModel>? promos,
    LoyaltyProgramModel?  loyaltyProgram,
  }) {
    return RestaurantDetailLoaded(
      establishment:  establishment  ?? this.establishment,
      promos:         promos         ?? this.promos,
      loyaltyProgram: loyaltyProgram ?? this.loyaltyProgram,
    );
  }

  @override
  List<Object?> get props => [establishment, promos, loyaltyProgram];
}

class RestaurantDetailError extends RestaurantDetailState {
  final String message;
  const RestaurantDetailError({required this.message});
  @override
  List<Object?> get props => [message];
}
