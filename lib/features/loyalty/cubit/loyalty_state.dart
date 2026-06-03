import 'package:equatable/equatable.dart';
import '../../../data/models/loyalty_program_model.dart';
import '../../../data/models/stamp_card_model.dart';

abstract class LoyaltyState extends Equatable {
  const LoyaltyState();
  @override
  List<Object?> get props => [];
}

/// Carga inicial / esperando datos.
class LoyaltyInitial extends LoyaltyState {}

class LoyaltyLoading extends LoyaltyState {}

class LoyaltySaving extends LoyaltyState {}

/// Estado principal del panel del dueño.
class LoyaltyLoaded extends LoyaltyState {
  /// null → no hay ningún programa (ni activo ni expirado)
  final LoyaltyProgramModel? program;

  /// Tarjetas de clientes del programa actual (puede estar vacío).
  final List<StampCardModel> cards;
  final bool                 cardsLoaded;

  const LoyaltyLoaded({
    this.program,
    this.cards        = const [],
    this.cardsLoaded  = false,
  });

  LoyaltyLoaded copyWith({
    LoyaltyProgramModel? program,
    bool clearProgram        = false,
    List<StampCardModel>? cards,
    bool? cardsLoaded,
  }) {
    return LoyaltyLoaded(
      program:     clearProgram ? null : (program ?? this.program),
      cards:       cards        ?? this.cards,
      cardsLoaded: cardsLoaded  ?? this.cardsLoaded,
    );
  }

  @override
  List<Object?> get props => [program, cards, cardsLoaded];
}

class LoyaltyError extends LoyaltyState {
  final String message;
  const LoyaltyError(this.message);
  @override
  List<Object?> get props => [message];
}

/// Resultado del escaneo (mostrado en el bottom-sheet de confirmación).
class LoyaltyScanResult extends LoyaltyState {
  final bool    ok;
  final String? error;          // código de error de la RPC
  final String? visitId;        // id en loyalty_visit_log (para registrar ticket)
  final int?    programVisits;
  final int?    lifetimeVisits;
  final int?    visitsRequired;
  final bool    rewardReady;

  const LoyaltyScanResult({
    required this.ok,
    this.error,
    this.visitId,
    this.programVisits,
    this.lifetimeVisits,
    this.visitsRequired,
    this.rewardReady = false,
  });

  @override
  List<Object?> get props => [ok, error, visitId, programVisits, rewardReady];
}
