import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../core/services/notification_service.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<supa.AuthState>? _authSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthEmailSignInRequested>(_onEmailSignIn);
    on<AuthEmailSignUpRequested>(_onEmailSignUp);
    on<AuthOnboardingCompleted>(_onOnboardingCompleted);
    on<AuthLocationPermissionHandled>(_onLocationPermissionHandled);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthProfileRefreshRequested>(_onProfileRefresh);

    _authSubscription =
        _authRepository.authStateChanges.listen((authState) {
      if (authState.event == supa.AuthChangeEvent.signedIn ||
          authState.event == supa.AuthChangeEvent.tokenRefreshed) {
        add(AuthStarted());
      } else if (authState.event == supa.AuthChangeEvent.signedOut) {
        add(AuthStarted());
      }
    });
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    try {
      final profile = await _authRepository.getProfile(user.id);
      if (profile == null || !profile.isOnboardingComplete) {
        emit(AuthNeedsOnboarding(user: user));
      } else {
        // Reintento de canje del código de invitación si quedó pendiente.
        await _redeemPendingReferralIfAny();
        final locationShown =
            await _authRepository.hasShownLocationPermission();
        if (!locationShown) {
          emit(AuthNeedsLocationPermission(user: user, profile: profile));
        } else {
          emit(AuthAuthenticated(user: user, profile: profile));
        }
      }
    } catch (_) {
      emit(AuthNeedsOnboarding(user: user));
    }
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Guardar el código de invitación (si lo hay) para canjearlo cuando
      // el perfil exista (tras el onboarding).
      final code = event.referralCode;
      if (code != null && code.trim().isNotEmpty) {
        await _authRepository.savePendingReferralCode(code);
      }
      await _authRepository.signInWithGoogle();
    } catch (e) {
      emit(AuthError(message: 'No se pudo iniciar con Google. $e'));
    }
  }

  Future<void> _onEmailSignIn(
    AuthEmailSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      if (response.user != null) {
        final profile =
            await _authRepository.getProfile(response.user!.id);
        if (profile == null || !profile.isOnboardingComplete) {
          emit(AuthNeedsOnboarding(user: response.user!));
        } else {
          final locationShown =
              await _authRepository.hasShownLocationPermission();
          if (!locationShown) {
            emit(AuthNeedsLocationPermission(
                user: response.user!, profile: profile));
          } else {
            emit(AuthAuthenticated(user: response.user!, profile: profile));
          }
        }
      }
    } on supa.AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (_) {
      emit(const AuthError(message: 'Error inesperado. Intenta de nuevo.'));
    }
  }

  Future<void> _onEmailSignUp(
    AuthEmailSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // Respaldo: guardar el código para canjearlo tras crear el perfil,
      // además de enviarlo en la metadata del signUp.
      final code = event.referralCode;
      if (code != null && code.trim().isNotEmpty) {
        await _authRepository.savePendingReferralCode(code);
      }
      final response = await _authRepository.signUpWithEmail(
        email: event.email,
        password: event.password,
        referralCode: code,
      );
      if (response.user != null) {
        emit(AuthNeedsOnboarding(user: response.user!));
      }
    } on supa.AuthException catch (e) {
      emit(AuthError(message: e.message));
    } catch (_) {
      emit(const AuthError(message: 'Error inesperado. Intenta de nuevo.'));
    }
  }

  Future<void> _onOnboardingCompleted(
    AuthOnboardingCompleted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = _authRepository.currentUser!;
      await _authRepository.saveProfile(
        userId: user.id,
        fullName: event.fullName,
        birthDate: event.birthDate,
        gender: event.gender,
      );
      // Canjear el código de invitación ahora que el perfil ya existe.
      await _redeemPendingReferralIfAny();
      final profile = await _authRepository.getProfile(user.id);
      // Siempre mostrar pantalla de ubicación después del onboarding
      emit(AuthNeedsLocationPermission(user: user, profile: profile!));
    } catch (_) {
      emit(const AuthError(
          message: 'No se pudo guardar tu perfil. Intenta de nuevo.'));
    }
  }

  Future<void> _onLocationPermissionHandled(
    AuthLocationPermissionHandled event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.markLocationPermissionShown();
    final user = _authRepository.currentUser!;
    final profile = await _authRepository.getProfile(user.id);
    emit(AuthAuthenticated(user: user, profile: profile!));
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Eliminar token FCM antes de cerrar sesión (necesitamos el userId)
    final userId = _authRepository.currentUser?.id;
    if (userId != null) {
      await NotificationService.instance.removeToken(userId);
    }
    await _authRepository.signOut();
    emit(const AuthUnauthenticated());
  }

  /// Recarga el perfil desde Supabase y emite el estado actualizado.
  /// Silencioso: si falla, mantiene el estado actual sin lanzar error.
  Future<void> _onProfileRefresh(
    AuthProfileRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is! AuthAuthenticated) return;
    try {
      final updated = await _authRepository.getProfile(current.user.id);
      if (updated != null) {
        emit(AuthAuthenticated(user: current.user, profile: updated));
      }
    } catch (_) {
      // Fallo silencioso — el estado actual se mantiene intacto.
    }
  }

  /// Canjea el código de invitación pendiente si el perfil ya existe.
  /// Idempotente y silencioso: si falla, se reintenta en el próximo arranque.
  Future<void> _redeemPendingReferralIfAny() async {
    final pending = await _authRepository.getPendingReferralCode();
    if (pending == null || pending.isEmpty) return;
    try {
      await _authRepository.linkReferral(pending);
      await _authRepository.clearPendingReferralCode();
    } catch (_) {
      // Se reintenta en el próximo arranque.
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}