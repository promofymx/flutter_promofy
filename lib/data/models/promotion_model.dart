import 'package:equatable/equatable.dart';

class PromotionModel extends Equatable {
  final String id;
  final String establishmentId;
  final String establishmentName;
  final String? establishmentLogo;
  final String name;
  final String description;
  final List<int> activeDays; // 1=Lunes … 7=Domingo
  final String startTime;    // "HH:mm:ss"
  final String endTime;
  final bool isAdultOnly;
  final String type;         // 'normal' | 'flash'
  final DateTime? flashStartsAt;
  final DateTime? flashEndsAt;
  final String? photoUrl;
  final double? distanceMeters;
  final int favoritesCount;
  final double? avgRating;
  final bool isFavorited;
  final bool    isFeatured;
  final int?    categoryId;
  final String? categoryName;
  final DateTime? createdAt;
  // Campos exclusivos de promos de cumpleaños
  final String? birthdayGift;
  final String? birthdayTerms;

  const PromotionModel({
    required this.id,
    required this.establishmentId,
    required this.establishmentName,
    this.establishmentLogo,
    required this.name,
    required this.description,
    required this.activeDays,
    required this.startTime,
    required this.endTime,
    required this.isAdultOnly,
    required this.type,
    this.flashStartsAt,
    this.flashEndsAt,
    this.photoUrl,
    this.distanceMeters,
    this.favoritesCount = 0,
    this.avgRating,
    this.isFavorited = false,
    this.isFeatured  = false,
    this.categoryId,
    this.categoryName,
    this.createdAt,
    this.birthdayGift,
    this.birthdayTerms,
  });

  bool get isFlash    => type == 'flash';
  bool get isBirthday => type == 'birthday';

  /// Una promo flash expiró si tiene fecha de fin y ya pasó.
  bool get isFlashExpired =>
      isFlash && flashEndsAt != null && DateTime.now().isAfter(flashEndsAt!);

  /// Una promo flash todavía no ha comenzado.
  bool get isFlashNotStarted =>
      isFlash && flashStartsAt != null && DateTime.now().isBefore(flashStartsAt!);

  // Distancia legible: "85 m" (< 100 m) o "0.1 km" (≥ 100 m)
  String get distanceFormatted {
    if (distanceMeters == null) return '';
    if (distanceMeters! < 100) {
      return '${distanceMeters!.round()} m';
    }
    final km = distanceMeters! / 1000;
    return '${km.toStringAsFixed(1)} km';
  }

  // Rating a mostrar: promedio real si ya hay calificaciones, 5.0 si es nuevo
  double get displayRating => avgRating ?? 5.0;
  bool   get hasRealRating => avgRating != null;

  /// La promo está bloqueada (no editable) durante 15 días desde su creación.
  bool get isLocked =>
      createdAt != null &&
      DateTime.now().isBefore(createdAt!.add(const Duration(days: 15)));

  /// Fecha a partir de la cual se puede editar.
  DateTime? get lockedUntil => createdAt?.add(const Duration(days: 15));

  // ─── WhatsApp share ────────────────────────────────────────────────────────

  static const _dayNames = {
    1: 'Lun', 2: 'Mar', 3: 'Mié',
    4: 'Jue', 5: 'Vie', 6: 'Sáb', 7: 'Dom',
  };

  String get _formattedDays {
    if (activeDays.isEmpty) return '';
    if (activeDays.length == 7) return 'Todos los días';
    final sorted = [...activeDays]..sort();
    bool isConsecutive = true;
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] - sorted[i - 1] != 1) { isConsecutive = false; break; }
    }
    if (isConsecutive && sorted.length >= 3) {
      return '${_dayNames[sorted.first]} a ${_dayNames[sorted.last]}';
    }
    return sorted.map((d) => _dayNames[d] ?? '').join(', ');
  }

  /// Texto listo para compartir por WhatsApp
  String get whatsAppText {
    final time = '${startTime.substring(0, 5)} - ${endTime.substring(0, 5)}';
    return '🍽️ $establishmentName\n'
        '🏷️ $name\n'
        '⏰ $_formattedDays, $time\n'
        '¡Descúbrelo en Promofy! 🎉\n'
        '👉 https://promofy.fun';
  }

  // ¿La promo está activa ahora mismo?
  bool get isCurrentlyActive {
    final now = DateTime.now();
    final todayIso = now.weekday; // 1=Lun, 7=Dom
    if (!activeDays.contains(todayIso)) return false;

    final startParts = startTime.split(':');
    final endParts   = endTime.split(':');
    final startMin   = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMin     = int.parse(endParts[0])   * 60 + int.parse(endParts[1]);
    final currentMin = now.hour * 60 + now.minute;

    return currentMin >= startMin && currentMin <= endMin;
  }

  /// Factory para construir el modelo desde una fila directa de la tabla
  /// `promotions` (sin los campos calculados del RPC).
  factory PromotionModel.fromTable(
    Map<String, dynamic> json, {
    required String establishmentName,
    String? establishmentLogo,
  }) {
    return PromotionModel(
      id:                json['id']               as String,
      establishmentId:   json['establishment_id'] as String,
      establishmentName: establishmentName,
      establishmentLogo: establishmentLogo,
      name:              json['name']             as String,
      description:       (json['description']     as String?) ?? '',
      activeDays: (json['active_days'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
      startTime:    (json['start_time']  as String?) ?? '00:00:00',
      endTime:      (json['end_time']    as String?) ?? '23:59:00',
      isAdultOnly:  (json['is_adult_only'] as bool?) ?? false,
      type:         (json['type']          as String?) ?? 'normal',
      flashStartsAt: json['flash_starts_at'] != null
          ? DateTime.parse(json['flash_starts_at'] as String)
          : null,
      flashEndsAt: json['flash_ends_at'] != null
          ? DateTime.parse(json['flash_ends_at'] as String)
          : null,
      photoUrl:   json['photo_url']  as String?,
      isFeatured: (json['is_featured'] as bool?) ?? false,
      // Campos calculados no disponibles en la tabla directa
      distanceMeters: null,
      favoritesCount: 0,
      avgRating:      null,
      isFavorited:    false,
      categoryId:     (json['category_id'] as num?)?.toInt(),
      categoryName:   null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : null,
      birthdayGift:  json['birthday_gift']  as String?,
      birthdayTerms: json['birthday_terms'] as String?,
    );
  }

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id:                json['id']                as String,
      establishmentId:   json['establishment_id']  as String,
      establishmentName: json['establishment_name'] as String,
      establishmentLogo: json['establishment_logo'] as String?,
      name:              json['name']               as String,
      description:       json['description']        as String,
      activeDays: (json['active_days'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      startTime: json['start_time'] as String,
      endTime:   json['end_time']   as String,
      isAdultOnly:   (json['is_adult_only'] as bool?) ?? false,
      type:           json['type']             as String,
      flashStartsAt: json['flash_starts_at'] != null
          ? DateTime.parse(json['flash_starts_at'] as String)
          : null,
      flashEndsAt: json['flash_ends_at'] != null
          ? DateTime.parse(json['flash_ends_at'] as String)
          : null,
      photoUrl:       json['photo_url']       as String?,
      distanceMeters: (json['distance_meters'] as num?)?.toDouble(),
      favoritesCount: (json['favorites_count'] as num?)?.toInt() ?? 0,
      avgRating:      (json['avg_rating'] as num?)?.toDouble(),
      isFavorited:  (json['is_favorited']  as bool?) ?? false,
      isFeatured:   (json['is_featured']   as bool?) ?? false,
      categoryId:   (json['category_id']   as num?)?.toInt(),
      categoryName: json['category_name']  as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : null,
      birthdayGift:  json['birthday_gift']  as String?,
      birthdayTerms: json['birthday_terms'] as String?,
    );
  }

  PromotionModel copyWith({
    bool? isFavorited,
    int?  favoritesCount,
    bool? isFeatured,
    int?  categoryId,
  }) {
    return PromotionModel(
      id: id, establishmentId: establishmentId,
      establishmentName: establishmentName,
      establishmentLogo: establishmentLogo,
      name: name, description: description,
      activeDays: activeDays, startTime: startTime, endTime: endTime,
      isAdultOnly: isAdultOnly, type: type,
      flashStartsAt: flashStartsAt, flashEndsAt: flashEndsAt,
      photoUrl: photoUrl, distanceMeters: distanceMeters,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      avgRating:     avgRating,
      isFavorited:   isFavorited  ?? this.isFavorited,
      isFeatured:    isFeatured   ?? this.isFeatured,
      categoryId:    categoryId   ?? this.categoryId,
      categoryName:  categoryName,
      createdAt:     createdAt,
      birthdayGift:  birthdayGift,
      birthdayTerms: birthdayTerms,
    );
  }

  @override
  List<Object?> get props => [id, isFavorited, favoritesCount, isFeatured, categoryId];
}