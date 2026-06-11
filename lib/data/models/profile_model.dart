import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String id;
  final String? fullName;
  final DateTime? birthDate;
  final String? gender;
  final int? cityId;
  /// Valores: 'user' | 'business_owner' | 'admin'
  final String role;
  final String? phone;
  final bool phoneVerified;
  final int adCreditMxn;
  final bool isSuperadmin;
  final int? planId;
  /// Fecha en que vence el plan de membresía. null = sin vencimiento / gratuito.
  final DateTime? planExpiresAt;
  /// Radio de búsqueda preferido (km). Afecta el feed de inicio.
  final int searchRadiusKm;
  /// Tipos de lugar preferidos para notificaciones (ej. ['bar', 'restaurante']).
  final List<String> preferredTypes;
  /// IDs de categorías favoritas (comida favorita), referencian a `categories`.
  final List<int> favoriteCategoryIds;

  // ── Programa de referidos ────────────────────────────────────────────
  /// Código único de referido (ej. "AB12CD34"). Null si aún no se generó.
  final String? referralCode;
  /// Créditos publicitarios acumulados (referidos + promo lanzamiento), en MXN.
  final double adCreditsMxn;

  // Ubicación del usuario (guardada al conceder permiso de GPS)
  final String? city;
  final String? municipality;
  final String? state;
  final String? postalCode;

  /// El usuario ya pasó por el onboarding (aunque haya dejado campos vacíos).
  final bool onboardingCompleted;

  const ProfileModel({
    required this.id,
    this.fullName,
    this.birthDate,
    this.gender,
    this.cityId,
    this.onboardingCompleted = false,
    this.role            = 'user',
    this.phone,
    this.phoneVerified   = false,
    this.adCreditMxn     = 0,
    this.isSuperadmin    = false,
    this.planId,
    this.planExpiresAt,
    this.searchRadiusKm  = 25,
    this.preferredTypes  = const [],
    this.favoriteCategoryIds = const [],
    this.referralCode,
    this.adCreditsMxn    = 0,
    this.city,
    this.municipality,
    this.state,
    this.postalCode,
  });

  // El onboarding se considera completo si el usuario ya lo pasó (bandera) o,
  // por compatibilidad con cuentas previas, si ya tiene nombre capturado.
  // La fecha de nacimiento y el género ahora son OPCIONALES (Apple 5.1.1).
  bool get isOnboardingComplete =>
      onboardingCompleted || (fullName != null && fullName!.isNotEmpty);

  bool get isBusinessOwner => role == 'business_owner' || role == 'admin';
  bool get isAdmin          => role == 'admin';
  /// Verdadero cuando el usuario aceptó una invitación de staff.
  /// accept_staff_invitation actualiza profiles.role = 'staff' en la DB.
  bool get isStaff          => role == 'staff';

  // Determina si es mayor de edad (para mostrar contenido +18)
  bool get isAdult {
    if (birthDate == null) return false;
    final age = DateTime.now().difference(birthDate!).inDays ~/ 365;
    return age >= 18;
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id:            json['id']             as String,
      fullName:      json['full_name']      as String?,
      birthDate:     json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      gender:        json['gender']         as String?,
      cityId:        json['city_id']        as int?,
      role:          json['role']           as String? ?? 'user',
      phone:         json['phone']          as String?,
      phoneVerified: json['phone_verified'] as bool?   ?? false,
      adCreditMxn:   json['ad_credit_mxn']  as int?  ?? 0,
      isSuperadmin:  (json['is_superadmin'] as bool?) ?? false,
      planId:        json['plan_id']             as int?,
      planExpiresAt: json['plan_expires_at'] != null
          ? DateTime.parse(json['plan_expires_at'] as String).toLocal()
          : null,
      searchRadiusKm: (json['search_radius_km'] as int?) ?? 25,
      preferredTypes: (json['preferred_types'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      favoriteCategoryIds: (json['favorite_category_ids'] as List<dynamic>? ?? [])
          .map((e) => e is int ? e : int.tryParse('$e') ?? 0)
          .where((e) => e != 0)
          .toList(),
      referralCode:  json['referral_code'] as String?,
      adCreditsMxn:  ((json['ad_credits_mxn'] as num?) ?? 0).toDouble(),
      city:         json['city']         as String?,
      municipality: json['municipality'] as String?,
      state:        json['state']        as String?,
      postalCode:   json['postal_code']  as String?,
      onboardingCompleted: (json['onboarding_completed'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (fullName != null) 'full_name': fullName,
        if (birthDate != null)
          'birth_date':
              '${birthDate!.year}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}',
        if (gender != null) 'gender': gender,
        if (cityId != null) 'city_id': cityId,
      };

  @override
  List<Object?> get props => [
        id, fullName, birthDate, gender, cityId, role,
        phone, phoneVerified, isSuperadmin, planId, planExpiresAt,
        searchRadiusKm, preferredTypes, favoriteCategoryIds,
        referralCode, adCreditsMxn,
        city, municipality, state, postalCode,
      ];
}