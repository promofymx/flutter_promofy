import 'package:equatable/equatable.dart';
import '../../../data/models/establishment_model.dart';
import '../../../data/models/membership_plan_model.dart';
import '../../../data/models/promotion_model.dart';

abstract class BusinessState extends Equatable {
  const BusinessState();
  @override
  List<Object?> get props => [];
}

class BusinessInitial extends BusinessState {
  const BusinessInitial();
}

class BusinessLoading extends BusinessState {
  const BusinessLoading();
}

/// El usuario no tiene establecimientos registrados aún.
class BusinessNoEstablishment extends BusinessState {
  final MembershipPlanModel? plan;
  const BusinessNoEstablishment({this.plan});
  @override
  List<Object?> get props => [plan];
}

/// Uno o más establecimientos cargados.
/// [selectedIndex]       — cuál está activo en la UI.
/// [promos]              — promociones del establecimiento seleccionado.
/// [totalPromoCount]     — suma de promos en TODOS los establecimientos del usuario.
/// [isSubscriptionActive] — true si tiene suscripción mensual autorizada.
class BusinessLoaded extends BusinessState {
  final List<EstablishmentModel> establishments;
  final int                      selectedIndex;
  final List<PromotionModel>     promos;
  final bool                     promosLoaded;
  final int                      totalPromoCount;
  final MembershipPlanModel?     plan;
  final bool                     isSubscriptionActive;
  /// Promos/locales extra comprados como add-on (suscripción activa).
  final int                      extraPromotions;
  final int                      extraEstablishments;

  const BusinessLoaded({
    required this.establishments,
    this.selectedIndex        = 0,
    this.promos               = const [],
    this.promosLoaded         = false,
    this.totalPromoCount      = 0,
    this.plan,
    this.isSubscriptionActive = false,
    this.extraPromotions      = 0,
    this.extraEstablishments  = 0,
  });

  EstablishmentModel get selected => establishments[selectedIndex];

  /// Límite efectivo de promociones = plan + add-ons activos.
  int get maxPromotionsEffective =>
      (plan?.maxPromotions ?? 2) + extraPromotions;

  /// Límite efectivo de establecimientos = plan + add-ons activos.
  int get maxEstablishmentsEffective =>
      (plan?.maxEstablishments ?? 1) + extraEstablishments;

  BusinessLoaded copyWith({
    List<EstablishmentModel>? establishments,
    int?                      selectedIndex,
    List<PromotionModel>?     promos,
    bool?                     promosLoaded,
    int?                      totalPromoCount,
    MembershipPlanModel?      plan,
    bool?                     isSubscriptionActive,
    int?                      extraPromotions,
    int?                      extraEstablishments,
  }) =>
      BusinessLoaded(
        establishments:       establishments       ?? this.establishments,
        selectedIndex:        selectedIndex        ?? this.selectedIndex,
        promos:               promos               ?? this.promos,
        promosLoaded:         promosLoaded         ?? this.promosLoaded,
        totalPromoCount:      totalPromoCount      ?? this.totalPromoCount,
        plan:                 plan                 ?? this.plan,
        isSubscriptionActive: isSubscriptionActive ?? this.isSubscriptionActive,
        extraPromotions:      extraPromotions      ?? this.extraPromotions,
        extraEstablishments:  extraEstablishments  ?? this.extraEstablishments,
      );

  @override
  List<Object?> get props =>
      [establishments, selectedIndex, promos, promosLoaded, totalPromoCount,
       plan, isSubscriptionActive, extraPromotions, extraEstablishments];
}

class BusinessSaving extends BusinessState {
  const BusinessSaving();
}

class BusinessError extends BusinessState {
  final String        message;
  final BusinessState? previousState;
  const BusinessError({required this.message, this.previousState});
  @override
  List<Object?> get props => [message];
}
