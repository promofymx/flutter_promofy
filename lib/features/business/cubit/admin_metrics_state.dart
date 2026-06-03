import 'package:equatable/equatable.dart';
import '../../../data/models/admin_platform_metrics_model.dart';

abstract class AdminMetricsState extends Equatable {
  const AdminMetricsState();
  @override List<Object?> get props => [];
}

class AdminMetricsInitial extends AdminMetricsState {}

class AdminMetricsLoading extends AdminMetricsState {}

class AdminMetricsLoaded extends AdminMetricsState {
  final AdminPlatformMetrics metrics;
  const AdminMetricsLoaded(this.metrics);
  @override List<Object?> get props => [metrics];
}

class AdminMetricsError extends AdminMetricsState {
  final String message;
  const AdminMetricsError(this.message);
  @override List<Object?> get props => [message];
}
