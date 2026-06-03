import 'package:equatable/equatable.dart';
import '../../../data/models/audience_model.dart';
import '../../../data/models/business_stats_model.dart';

abstract class StatsState extends Equatable {
  const StatsState();
  @override
  List<Object?> get props => [];
}

class StatsInitial extends StatsState {}

class StatsLoading extends StatsState {}

class StatsLoaded extends StatsState {
  final BusinessStatsModel stats;
  final AudienceModel?     audience;

  const StatsLoaded(this.stats, {this.audience});

  StatsLoaded copyWith({
    BusinessStatsModel? stats,
    AudienceModel?      audience,
  }) =>
      StatsLoaded(
        stats    ?? this.stats,
        audience: audience ?? this.audience,
      );

  @override
  List<Object?> get props => [stats, audience];
}

class StatsError extends StatsState {
  final String message;
  const StatsError(this.message);

  @override
  List<Object?> get props => [message];
}
