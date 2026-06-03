import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Resultado del reverse geocoding.
class LocationAddress {
  final String? city;
  final String? municipality;
  final String? state;
  final String? postalCode;

  const LocationAddress({
    this.city,
    this.municipality,
    this.state,
    this.postalCode,
  });

  bool get isEmpty =>
      city == null &&
      municipality == null &&
      state == null &&
      postalCode == null;

  Map<String, dynamic> toUpdateMap() => {
        if (city         != null) 'city':         city,
        if (municipality != null) 'municipality': municipality,
        if (state        != null) 'state':        state,
        if (postalCode   != null) 'postal_code':  postalCode,
      };
}

/// Servicio singleton de geocodificación inversa usando Nominatim (OSM).
/// No requiere API key. Usa el paquete `http` ya incluido en el proyecto.
class GeocodingService {
  GeocodingService._();
  static final instance = GeocodingService._();

  /// Convierte coordenadas GPS en dirección (ciudad, municipio, estado, CP).
  /// Devuelve null si la red falla o Nominatim no puede resolver la posición.
  Future<LocationAddress?> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json&lat=$lat&lon=$lng&accept-language=es',
      );
      final response = await http
          .get(uri, headers: {
            // Nominatim exige User-Agent identificatorio
            'User-Agent': 'Promofy/1.0 (soporte@promofy.mx)',
            'Accept':     'application/json',
          })
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final addr = data['address'] as Map<String, dynamic>?;
      if (addr == null) return null;

      // En México: 'city' > 'town' > 'village' para la localidad
      final city = (addr['city'] ?? addr['town'] ?? addr['village']) as String?;
      // 'municipality' = municipio en respuestas de México
      final municipality = addr['municipality'] as String?;
      final state        = addr['state']        as String?;
      final postalCode   = addr['postcode']     as String?;

      final result = LocationAddress(
        city:         city,
        municipality: municipality,
        state:        state,
        postalCode:   postalCode,
      );

      debugPrint(
        '📍 GeocodingService: $city / $municipality / $state / $postalCode',
      );

      return result.isEmpty ? null : result;
    } catch (e) {
      debugPrint('⚠️ GeocodingService.reverseGeocode error: $e');
      return null;
    }
  }
}
