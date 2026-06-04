import 'package:equatable/equatable.dart';
import '../../../data/models/user_stats_model.dart';

abstract class AchievementsState extends Equatable {
  const AchievementsState();
  @override
  List<Object?> get props => [];
}

class AchievementsInitial extends AchievementsState {}

class AchievementsLoading extends AchievementsState {}

class AchievementsLoaded extends AchievementsState {
  final UserStatsModel stats;
  const AchievementsLoaded(this.stats);
  @override
  List<Object?> get props => [stats];
}

class AchievementsError extends AchievementsState {}
