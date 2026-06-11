import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/profile_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

class AuthNeedsOnboarding extends AuthState {
  final User user;
  const AuthNeedsOnboarding({required this.user});
  @override
  List<Object?> get props => [user.id];
}

// Usuario listo pero aún no vio la pantalla de ubicación
class AuthNeedsLocationPermission extends AuthState {
  final User user;
  final ProfileModel profile;
  const AuthNeedsLocationPermission({
    required this.user,
    required this.profile,
  });
  @override
  List<Object?> get props => [user.id];
}

class AuthAuthenticated extends AuthState {
  final User user;
  final ProfileModel profile;
  const AuthAuthenticated({required this.user, required this.profile});
  @override
  List<Object?> get props => [user.id, profile];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Modo invitado: el usuario explora sin cuenta. Sin perfil; las funciones de
/// cuenta (favoritos, lealtad, negocio) piden iniciar sesión al tocarlas.
class AuthGuest extends AuthState {
  const AuthGuest();
}

class AuthError extends AuthState {
  final String message;
  const AuthError({required this.message});
  @override
  List<Object?> get props => [message];
}