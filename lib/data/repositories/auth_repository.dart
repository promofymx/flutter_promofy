import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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

  /// Inicia sesión con Apple (Sign in with Apple) — requerido por Apple si se
  /// ofrece login con Google. Usa el flujo nativo con nonce y lo intercambia
  /// con Supabase vía signInWithIdToken.
  Future<void> signInWithApple() async {
    final rawNonce    = _generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw Exception('Apple no devolvió un token de identidad.');
    }

    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken:  idToken,
      nonce:    rawNonce,
    );

    // Apple solo envía el nombre la PRIMERA vez. Si vino, lo guardamos en el
    // perfil para que el onboarding lo tenga.
    final given  = credential.givenName ?? '';
    final family = credential.familyName ?? '';
    final full   = '$given $family'.trim();
    final uid    = supabase.auth.currentUser?.id;
    if (full.isNotEmpty && uid != null) {
      try {
        await supabase.from('profiles').update({'full_name': full}).eq('id', uid);
      } catch (_) {/* no crítico */}
    }
  }

  /// Nonce aleatorio para el flujo de Apple.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
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
    String? referralCode,
  }) async {
    final code = referralCode?.trim().toUpperCase();
    return await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'http://localhost:3000',
      // El trigger handle_referral_from_signup() lee 'referring_code' del
      // raw_user_meta_data y crea el registro en referrals al crear el perfil.
      data: (code != null && code.isNotEmpty)
          ? {'referring_code': code}
          : null,
    );
  }

  // ── Referidos ──────────────────────────────────────────────────
  /// Vincula al usuario activo con quien lo refirió (RPC SECURITY DEFINER).
  /// Idempotente: si ya tiene referidor o el código no existe, no hace nada.
  Future<void> linkReferral(String referrerCode) async {
    final code = referrerCode.trim().toUpperCase();
    if (code.isEmpty) return;
    await supabase.rpc('link_referral', params: {'p_referrer_code': code});
  }

  /// Guarda el código de invitación para canjearlo tras completar el perfil
  /// (cubre tanto registro con correo como con Google).
  Future<void> savePendingReferralCode(String code) async {
    final clean = code.trim().toUpperCase();
    if (clean.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_referral_code', clean);
  }

  Future<String?> getPendingReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pending_referral_code');
  }

  Future<void> clearPendingReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_referral_code');
  }

  Future<void> signOut() async => await supabase.auth.signOut();

  /// Elimina permanentemente la cuenta del usuario y todos sus datos.
  /// Llama a la edge function `delete-account` (service role) y luego cierra
  /// la sesión local. Lanza una excepción si el borrado falla.
  Future<void> deleteAccount() async {
    final res = await supabase.functions.invoke('delete-account');
    final data = res.data;
    if (res.status != 200 || (data is Map && data['error'] != null)) {
      throw Exception(
        (data is Map ? data['error'] : null) ?? 'No se pudo eliminar la cuenta.',
      );
    }
    // La cuenta ya no existe → la sesión es inválida; cerrar localmente.
    try {
      await supabase.auth.signOut();
    } catch (_) {/* sesión ya invalidada tras borrar el usuario */}
  }

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

  /// Guarda nombre, radio de búsqueda, tipos preferidos y categorías favoritas.
  Future<void> updateSettings({
    required String       userId,
    required String       fullName,
    required int          searchRadiusKm,
    required List<String> preferredTypes,
    List<int>             favoriteCategoryIds = const [],
  }) async {
    await supabase.from('profiles').update({
      'full_name':             fullName,
      'search_radius_km':      searchRadiusKm,
      'preferred_types':       preferredTypes,
      'favorite_category_ids': favoriteCategoryIds,
      'updated_at':            DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  /// Cambia la contraseña del usuario con sesión activa.
  Future<void> changePassword(String newPassword) async {
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
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