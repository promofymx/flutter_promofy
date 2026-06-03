import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../../main.dart';

// ─── Web Client ID de Google Cloud Console ────────────────────────────────────
// APIs & Services → Credentials → OAuth 2.0 Client IDs → tipo "Web application"
// Es el mismo que configuraste en Supabase → Auth → Providers → Google.
const _googleWebClientId =
    '612781804475-c3rotrmvu7cqi0ju063smr4vkvvgueoi.apps.googleusercontent.com';

class AuthRepository {
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;
  User? get currentUser => supabase.auth.currentUser;

  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      // Web: OAuth redirect — el browser maneja todo, Supabase recibe el callback
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: '${Uri.base.origin}/auth/callback',
      );
    } else {
      // Android / iOS: SDK nativo — sin abrir browser
      final googleSignIn = GoogleSignIn(serverClientId: _googleWebClientId);
      final googleUser   = await googleSignIn.signIn();
      if (googleUser == null) return; // usuario canceló
      final googleAuth = await googleUser.authentication;
      final idToken    = googleAuth.idToken;
      if (idToken == null) {
        throw Exception(
            'Google no devolvió un ID token. '
            'Verifica que el SHA-1 esté registrado en Google Cloud Console.');
      }
      await supabase.auth.signInWithIdToken(
        provider:    OAuthProvider.google,
        idToken:     idToken,
        accessToken: googleAuth.accessToken,
      );
    }
  }

  /// Envía un correo de recuperación de contraseña.
  /// El enlace redirige a la app mediante deep link promofy:///auth/reset-password.
  Future<void> resetPasswordForEmail(String email) async {
    await supabase.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: 'promofy:///auth/reset-password',
    );
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'http://localhost:3000',
    );
  }

  Future<void> signOut() async => await supabase.auth.signOut();

  Future<ProfileModel?> getProfile(String userId) async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (response == null) return null;
    return ProfileModel.fromJson(response);
  }

  Future<void> saveProfile({
    required String userId,
    required String fullName,
    required DateTime birthDate,
    required String gender,
  }) async {
    await supabase.from('profiles').upsert({
      'id': userId,
      'full_name': fullName,
      'birth_date':
          '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}',
      'gender': gender,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Guarda nombre, radio de búsqueda y tipos preferidos del usuario.
  Future<void> updateSettings({
    required String      userId,
    required String      fullName,
    required int         searchRadiusKm,
    required List<String> preferredTypes,
  }) async {
    await supabase.from('profiles').update({
      'full_name':         fullName,
      'search_radius_km':  searchRadiusKm,
      'preferred_types':   preferredTypes,
      'updated_at':        DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  // ── Ubicación ──────────────────────────────────────────────────
  Future<bool> hasShownLocationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('location_permission_shown') ?? false;
  }

  Future<void> markLocationPermissionShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_permission_shown', true);
  }
}