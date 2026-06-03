import 'package:equatable/equatable.dart';

/// Distribución demográfica de los usuarios que marcaron como favorito
/// un establecimiento o una de sus promociones.
class AgeGroup extends Equatable {
  final String label; // '18-24' | '25-34' | '35-44' | '45-54' | '55+' | 'N/A'
  final int    count;
  const AgeGroup({required this.label, required this.count});
  @override List<Object?> get props => [label, count];
}

class PromoAudienceModel extends Equatable {
  final String        promoId;
  final String        promoName;
  final int           total;
  final Map<String, int> genderCounts; // 'male'|'female'|'unknown' → count
  final List<AgeGroup>   ageBuckets;

  const PromoAudienceModel({
    required this.promoId,
    required this.promoName,
    required this.total,
    required this.genderCounts,
    required this.ageBuckets,
  });

  @override List<Object?> get props => [promoId, total, genderCounts, ageBuckets];

  factory PromoAudienceModel.fromJson(Map<String, dynamic> json) {
    final gMap   = (json['gender'] as Map<String, dynamic>? ?? {});
    final aMap   = (json['age']    as Map<String, dynamic>? ?? {});
    const order  = ['18-24','25-34','35-44','45-54','55+','N/A'];
    final buckets = order
        .where((k) => aMap.containsKey(k))
        .map((k) => AgeGroup(label: k, count: (aMap[k] as num).toInt()))
        .toList();
    return PromoAudienceModel(
      promoId:      json['promo_id']   as String,
      promoName:    json['promo_name'] as String,
      total:        (json['total']     as num?)?.toInt() ?? 0,
      genderCounts: gMap.map((k, v) => MapEntry(k, (v as num).toInt())),
      ageBuckets:   buckets,
    );
  }
}

class AudienceModel extends Equatable {
  final int              total;         // favoriteadores únicos del establecimiento
  final Map<String, int> genderCounts;  // 'male'|'female'|'unknown' → count
  final List<AgeGroup>   ageBuckets;    // rangos de edad
  final List<PromoAudienceModel> perPromo;

  const AudienceModel({
    required this.total,
    required this.genderCounts,
    required this.ageBuckets,
    this.perPromo = const [],
  });

  bool get hasData => total > 0;

  @override List<Object?> get props => [total, genderCounts, ageBuckets, perPromo];

  factory AudienceModel.empty() => const AudienceModel(
    total: 0, genderCounts: {}, ageBuckets: [], perPromo: [],
  );

  factory AudienceModel.fromJson(Map<String, dynamic> json) {
    final gMap   = (json['gender'] as Map<String, dynamic>? ?? {});
    final aMap   = (json['age']    as Map<String, dynamic>? ?? {});
    final ppList = (json['per_promo'] as List<dynamic>? ?? []);
    const order  = ['18-24','25-34','35-44','45-54','55+','N/A'];
    final buckets = order
        .where((k) => aMap.containsKey(k))
        .map((k) => AgeGroup(label: k, count: (aMap[k] as num).toInt()))
        .toList();
    return AudienceModel(
      total:        (json['total'] as num?)?.toInt() ?? 0,
      genderCounts: gMap.map((k, v) => MapEntry(k, (v as num).toInt())),
      ageBuckets:   buckets,
      perPromo:     ppList
          .map((e) => PromoAudienceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
