import 'package:equatable/equatable.dart';
import 'characteristic_model.dart';

class EstablishmentModel extends Equatable {
  final String  id;
  final String  name;
  final String? description;
  final String? address;
  final String? phone;
  final String? website;
  final String? logoUrl;
  final double? distanceMeters;
  final double? lat;
  final double? lng;
  final double? avgRating;
  final List<CharacteristicModel> characteristics;
  final List<String> photoUrls;

  // ── Campos Fase 6B ────────────────────────────────────────────────────────
  final int?       categoryId;   // primera categoría (compat)
  final List<int>  categoryIds;  // todas las categorías seleccionadas
  final String? establishmentType;   // 'local' | 'urban_mobile'
  final Map<String, dynamic>? schedule;
  final List<String> paymentMethods;
  final bool    adultPromotions;
  final String? facebookUrl;
  final String? instagramUrl;
  final bool    isFavorited;
  final int     favoritesCount;

  const EstablishmentModel({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.website,
    this.logoUrl,
    this.distanceMeters,
    this.lat,
    this.lng,
    this.avgRating,
    this.characteristics   = const [],
    this.photoUrls         = const [],
    this.categoryId,
    this.categoryIds       = const [],
    this.establishmentType,
    this.schedule,
    this.paymentMethods    = const [],
    this.adultPromotions   = false,
    this.facebookUrl,
    this.instagramUrl,
    this.isFavorited       = false,
    this.favoritesCount    = 0,
  });

  EstablishmentModel copyWith({
    String?  id,
    String?  name,
    String?  description,
    String?  address,
    String?  phone,
    String?  website,
    String?  logoUrl,
    double?  distanceMeters,
    double?  lat,
    double?  lng,
    double?  avgRating,
    List<CharacteristicModel>? characteristics,
    List<String>? photoUrls,
    int?          categoryId,
    List<int>?    categoryIds,
    String?       establishmentType,
    Map<String, dynamic>? schedule,
    List<String>? paymentMethods,
    bool?    adultPromotions,
    String?  facebookUrl,
    String?  instagramUrl,
    bool?    isFavorited,
    int?     favoritesCount,
  }) {
    return EstablishmentModel(
      id:                id                ?? this.id,
      name:              name              ?? this.name,
      description:       description       ?? this.description,
      address:           address           ?? this.address,
      phone:             phone             ?? this.phone,
      website:           website           ?? this.website,
      logoUrl:           logoUrl           ?? this.logoUrl,
      distanceMeters:    distanceMeters    ?? this.distanceMeters,
      lat:               lat               ?? this.lat,
      lng:               lng               ?? this.lng,
      avgRating:         avgRating         ?? this.avgRating,
      characteristics:   characteristics  ?? this.characteristics,
      photoUrls:         photoUrls         ?? this.photoUrls,
      categoryId:        categoryId        ?? this.categoryId,
      categoryIds:       categoryIds       ?? this.categoryIds,
      establishmentType: establishmentType ?? this.establishmentType,
      schedule:          schedule          ?? this.schedule,
      paymentMethods:    paymentMethods    ?? this.paymentMethods,
      adultPromotions:   adultPromotions   ?? this.adultPromotions,
      facebookUrl:       facebookUrl       ?? this.facebookUrl,
      instagramUrl:      instagramUrl      ?? this.instagramUrl,
      isFavorited:       isFavorited       ?? this.isFavorited,
      favoritesCount:    favoritesCount    ?? this.favoritesCount,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String get distanceFormatted {
    if (distanceMeters == null) return '';
    if (distanceMeters! < 100) return '${distanceMeters!.round()} m';
    return '${(distanceMeters! / 1000).toStringAsFixed(1)} km';
  }

  double get displayRating => avgRating ?? 5.0;
  bool   get hasRealRating => avgRating != null;

  String? get googleMapsUrl {
    if (lat == null || lng == null) return null;
    return 'https://maps.google.com/?q=$lat,$lng';
  }

  String? get whatsAppUrl {
    if (phone == null || phone!.isEmpty) return null;
    final digits     = phone!.replaceAll(RegExp(r'\D'), '');
    final normalized = digits.startsWith('52') ? digits : '52$digits';
    return 'https://wa.me/$normalized';
  }

  // ── fromTable — respuesta directa de INSERT/UPDATE/SELECT ─────────────────

  factory EstablishmentModel.fromTable(Map<String, dynamic> json) {
    return EstablishmentModel(
      id:               json['id']               as String,
      name:             json['name']             as String,
      description:      json['description']      as String?,
      address:          (json['street'] ?? json['address']) as String?,
      phone:            json['phone']            as String?,
      website:          json['website']          as String?,
      logoUrl:          json['logo_url']         as String?,
      categoryId:       json['category_id']      as int?,
      categoryIds:      _parseCategoryIds(json['category_ids']),
      establishmentType: json['establishment_type'] as String?,
      schedule:         json['schedule']         as Map<String, dynamic>?,
      paymentMethods:   (json['payment_methods'] as List<dynamic>?)
                            ?.cast<String>() ?? const [],
      adultPromotions:  (json['adult_promotions'] as bool?) ?? false,
      facebookUrl:      json['facebook_url']     as String?,
      instagramUrl:     json['instagram_url']    as String?,
    );
  }

  static List<int> _parseCategoryIds(dynamic raw) {
    if (raw == null) return const [];
    if (raw is List) return raw.whereType<int>().toList();
    return const [];
  }

  // ── fromJson — respuesta de RPC con campos enriquecidos ───────────────────

  factory EstablishmentModel.fromJson(Map<String, dynamic> json) {
    final rawChars  = json['characteristics'];
    final chars = (rawChars is List)
        ? rawChars.whereType<Map<String, dynamic>>()
            .map(CharacteristicModel.fromJson).toList()
        : <CharacteristicModel>[];

    final rawPhotos = json['photos'];
    final photos = (rawPhotos is List)
        ? rawPhotos.whereType<String>().toList()
        : <String>[];

    return EstablishmentModel(
      id:               json['id']               as String,
      name:             json['name']             as String,
      description:      json['description']      as String?,
      address:          json['address']          as String?,
      phone:            json['phone']            as String?,
      website:          json['website']          as String?,
      logoUrl:          json['logo_url']         as String?,
      distanceMeters:  (json['distance_meters']  as num?)?.toDouble(),
      lat:             (json['lat']              as num?)?.toDouble(),
      lng:             (json['lng']              as num?)?.toDouble(),
      avgRating:       (json['avg_rating']       as num?)?.toDouble(),
      characteristics:  chars,
      photoUrls:        photos,
      categoryId:       json['category_id']      as int?,
      categoryIds:      _parseCategoryIds(json['category_ids']),
      establishmentType: json['establishment_type'] as String?,
      schedule:         json['schedule']         as Map<String, dynamic>?,
      paymentMethods:   (json['payment_methods'] as List<dynamic>?)
                            ?.cast<String>() ?? const [],
      adultPromotions:  (json['adult_promotions'] as bool?) ?? false,
      facebookUrl:      json['facebook_url']     as String?,
      instagramUrl:     json['instagram_url']    as String?,
      isFavorited:      (json['is_favorited']    as bool?) ?? false,
      favoritesCount:   (json['favorites_count'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, categoryIds, isFavorited, favoritesCount];
}
