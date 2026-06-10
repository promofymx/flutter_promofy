/// Demografía agregada de un grupo de personas (favoritos, lealtad, etc.).
class AudienceGroup {
  final int             count;
  final bool            enough;      // false = muy pocos datos (<5) → se oculta
  final int?            avgAge;
  final Map<String, int> gender;     // male, female, unknown
  final Map<String, int> ageBuckets; // 18-24, 25-34, 35-44, 45-54, 55+, unknown

  const AudienceGroup({
    required this.count,
    required this.enough,
    this.avgAge,
    this.gender     = const {},
    this.ageBuckets = const {},
  });

  factory AudienceGroup.fromJson(Map<String, dynamic> j) => AudienceGroup(
        count:      (j['count']   as num?)?.toInt() ?? 0,
        enough:     j['enough'] as bool? ?? false,
        avgAge:     (j['avg_age'] as num?)?.toInt(),
        gender:     _intMap(j['gender']),
        ageBuckets: _intMap(j['age_buckets']),
      );

  static Map<String, int> _intMap(dynamic m) {
    if (m is! Map) return {};
    return m.map((k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0));
  }
}

/// Audiencia del dueño: 3 grupos.
class AudienceStats {
  final AudienceGroup establishmentFavorites;
  final AudienceGroup promoFavorites;
  final AudienceGroup loyalty;

  const AudienceStats({
    required this.establishmentFavorites,
    required this.promoFavorites,
    required this.loyalty,
  });

  factory AudienceStats.fromJson(Map<String, dynamic> j) => AudienceStats(
        establishmentFavorites:
            AudienceGroup.fromJson((j['establishment_favorites'] as Map?)?.cast<String, dynamic>() ?? {}),
        promoFavorites:
            AudienceGroup.fromJson((j['promo_favorites'] as Map?)?.cast<String, dynamic>() ?? {}),
        loyalty:
            AudienceGroup.fromJson((j['loyalty'] as Map?)?.cast<String, dynamic>() ?? {}),
      );
}
