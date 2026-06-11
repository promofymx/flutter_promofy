import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../core/services/geocoding_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import 'package:promofy/l10n/app_localizations.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState
    extends State<LocationPermissionScreen> {
  bool _isRequesting = false;

  Future<void> _requestLocation() async {
    setState(() => _isRequesting = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        // Si el usuario concedió permiso, obtenemos posición y geocodificamos
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          await _saveLocationToProfile();
        }
      }
    } catch (_) {
      // Si falla el permiso o la posición, seguimos de todas formas
    }

    if (mounted) {
      context.read<AuthBloc>().add(AuthLocationPermissionHandled());
    }
  }

  /// Obtiene la posición GPS, hace reverse geocoding y guarda
  /// ciudad/municipio/estado/CP en el perfil del usuario.
  /// Fire-and-forget: cualquier error se ignora silenciosamente.
  Future<void> _saveLocationToProfile() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 6),
      );

      final address = await GeocodingService.instance.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      if (address == null || address.isEmpty) return;

      // Obtenemos el userId del estado actual del AuthBloc
      final authState = context.read<AuthBloc>().state;
      final userId = authState is AuthNeedsLocationPermission
          ? authState.user.id
          : supabase.auth.currentUser?.id;

      if (userId == null) return;

      await supabase
          .from('profiles')
          .update(address.toUpdateMap())
          .eq('id', userId);
    } catch (e) {
      debugPrint('⚠️ LocationPermission._saveLocationToProfile error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // Ícono de ubicación
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 64,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  AppLocalizations.of(context).locationPermTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  AppLocalizations.of(context).locationPermSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),

                const Spacer(flex: 3),

                // Botón principal
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isRequesting ? null : _requestLocation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isRequesting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            AppLocalizations.of(context).locationPermAllowButton,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}