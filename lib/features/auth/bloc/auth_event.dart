import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}
class AuthGoogleSignInRequested extends AuthEvent {}

class AuthEmailSignInRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthEmailSignInRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthEmailSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthEmailSignUpRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthOnboardingCompleted extends AuthEvent {
  final String fullName;
  final DateTime birthDate;
  final String gender;
  const AuthOnboardingCompleted({
    required this.fullName,
    required this.birthDate,
    required this.gender,
  });
  @override
  List<Object?> get props => [fullName, birthDate, gender];
}

// Usuario tocó "Permitir" o "Ahora no" en la pantalla de ubicación
class AuthLocationPermissionHandled extends AuthEvent {}

class AuthSignOutRequested extends AuthEvent {}

/// Re-carga el perfil desde Supabase y actualiza el estado autenticado.
/// Usado después de canjear un código de invitación para reflejar el nuevo rol.
class AuthProfileRefreshRequested extends AuthEvent {}