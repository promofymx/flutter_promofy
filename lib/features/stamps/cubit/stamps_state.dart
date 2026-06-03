import 'package:equatable/equatable.dart';
import '../../../data/models/stamp_card_model.dart';

abstract class StampsState extends Equatable {
  const StampsState();
  @override
  List<Object?> get props => [];
}

class StampsInitial  extends StampsState {}
class StampsLoading  extends StampsState {}

class StampsLoaded extends StampsState {
  final List<StampCardModel> cards;
  const StampsLoaded({required this.cards});
  @override
  List<Object?> get props => [cards];
}

class StampsError extends StampsState {
  final String message;
  const StampsError(this.message);
  @override
  List<Object?> get props => [message];
}
