import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}

class AuthGoogleSignInRequested extends AuthEvent {
  /// Código de invitación (referido) opcional, capturado en el registro.
  final String? referralCode;
  const AuthGoogleSignInRequested({this.referralCode});
  @override
  List<Object?> get props => [referralCode];
}

class AuthAppleSignInRequested extends AuthEvent {
  /// Código de invitación (referido) opcional, capturado en el registro.
  final String? referralCode;
  const AuthAppleSignInRequested({this.referralCode});
  @override
  List<Object?> get props => [referralCode];
}

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
  /// Código de invitación (referido) opcional.
  final String? referralCode;
  const AuthEmailSignUpRequested({
    required this.email,
    required this.password,
    this.referralCode,
  });
  @override
  List<Object?> get props => [email, password, referralCode];
}

class AuthOnboardingCompleted extends AuthEvent {
  // Todos opcionales (Apple 5.1.1): el usuario puede dejarlos vacíos.
  final String? fullName;
  final DateTime? birthDate;
  final String? gender;
  const AuthOnboardingCompleted({
    this.fullName,
    this.birthDate,
    this.gender,
  });
  @override
  List<Object?> get props => [fullName, birthDate, gender];
}

/// El usuario decide explorar sin cuenta (modo invitado).
class AuthContinueAsGuest extends AuthEvent {}

// Usuario tocó "Permitir" o "Ahora no" en la pantalla de ubicación
class AuthLocationPermissionHandled extends AuthEvent {}

class AuthSignOutRequested extends AuthEvent {}

/// Re-carga el perfil desde Supabase y actualiza el estado autenticado.
/// Usado después de canjear un código de invitación para reflejar el nuevo rol.
class AuthProfileRefreshRequested extends AuthEvent {}