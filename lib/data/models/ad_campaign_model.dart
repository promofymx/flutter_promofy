import 'package:equatable/equatable.dart';

class AdCampaignModel extends Equatable {
  final String      id;
  final String      establishmentId;
  final String      name;
  final String      format;   // splash | featured_list | banner | push | flash
  final String      status;   // draft | active | paused | completed | cancelled
  final double      budgetMxn;
  final double      spentMxn;
  final int         radiusKm;
  final String      geoMode;  // physical_location | search_area | both
  final List<int>   targetCategoryIds;
  final int         targetMinAge;   // 0 = sin mínimo
  final int         targetMaxAge;   // 99 = sin máximo
  final String      targetGender;  // 'all' | 'male' | 'female'
  final String?     promotionId;  // promo que se está publicitando
  final DateTime?   startDate;
  final DateTime?   endDate;
  final DateTime    createdAt;

  const AdCampaignModel({
    required this.id,
    required this.establishmentId,
    required this.name,
    required this.format,
    required this.status,
    required this.budgetMxn,
    required this.spentMxn,
    required this.radiusKm,
    required this.geoMode,
    required this.targetCategoryIds,
    this.targetMinAge  = 0,
    this.targetMaxAge  = 99,
    this.targetGender  = 'all',
    this.promotionId,
    required this.createdAt,
    this.startDate,
    this.endDate,
  });

  factory AdCampaignModel.fromJson(Map<String, dynamic> json) {
    return AdCampaignModel(
      id:                  json['id']               as String,
      establishmentId:     json['establishment_id'] as String,
      name:                json['name']             as String,
      format:              json['format']           as String,
      status:              json['status']           as String,
      budgetMxn:          (json['budget_mxn']       as num).toDouble(),
      spentMxn:           (json['spent_mxn']        as num? ?? 0).toDouble(),
      radiusKm:            json['radius_km']         as int? ?? 5,
      geoMode:             json['geo_mode']          as String? ?? 'both',
      targetCategoryIds:  (json['target_category_ids'] as List<dynamic>? ?? [])
          .map((e) => e as int)
          .toList(),
      targetMinAge:  json['target_min_age']  as int?    ?? 0,
      targetMaxAge:  json['target_max_age']  as int?    ?? 99,
      targetGender:  json['target_gender']   as String? ?? 'all',
      promotionId: json['promotion_id'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Presupuesto restante disponible.
  double get remainingMxn => (budgetMxn - spentMxn).clamp(0, budgetMxn);

  /// Porcentaje gastado [0..1].
  double get spentPct => budgetMxn > 0 ? (spentMxn / budgetMxn).clamp(0, 1) : 0;

  bool get isActive    => status == 'active';
  bool get isPaused    => status == 'paused';
  bool get isDraft     => status == 'draft';
  bool get isCompleted => status == 'completed' || status == 'cancelled';

  String get statusLabel {
    switch (status) {
      case 'active':    return 'Activa';
      case 'paused':    return 'Pausada';
      case 'draft':     return 'Borrador';
      case 'completed': return 'Completada';
      case 'cancelled': return 'Cancelada';
      default:          return status;
    }
  }

  String get formatLabel {
    switch (format) {
      case 'splash':        return 'Splash';
      case 'featured_list': return 'Destacada en lista';
      case 'banner':        return 'Banner';
      case 'push':          return 'Notif. push';
      case 'flash':         return 'Promo Relámpago';
      default:              return format;
    }
  }

  String get geoModeLabel {
    switch (geoMode) {
      case 'physical_location': return 'Ubicación física';
      case 'search_area':       return 'Área de búsqueda';
      case 'both':              return 'Ambas';
      default:                  return geoMode;
    }
  }

  AdCampaignModel copyWith({String? status, double? spentMxn, int? targetMinAge, int? targetMaxAge, String? targetGender, String? promotionId}) {
    return AdCampaignModel(
      id:                 id,
      establishmentId:    establishmentId,
      name:               name,
      format:             format,
      status:             status      ?? this.status,
      budgetMxn:          budgetMxn,
      spentMxn:           spentMxn    ?? this.spentMxn,
      radiusKm:           radiusKm,
      geoMode:            geoMode,
      targetCategoryIds:  targetCategoryIds,
      targetMinAge:       targetMinAge  ?? this.targetMinAge,
      targetMaxAge:       targetMaxAge  ?? this.targetMaxAge,
      targetGender:       targetGender  ?? this.targetGender,
      promotionId:        promotionId   ?? this.promotionId,
      startDate:          startDate,
      endDate:            endDate,
      createdAt:          createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id, establishmentId, name, format, status,
    budgetMxn, spentMxn, radiusKm, geoMode,
    targetCategoryIds, targetMinAge, targetMaxAge, targetGender,
    promotionId, startDate, endDate, createdAt,
  ];
}
