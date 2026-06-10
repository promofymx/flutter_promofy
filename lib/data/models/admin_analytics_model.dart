import 'audience_stats_model.dart';

class TypeStat {
  final int    id;
  final String name;
  final int    count;
  const TypeStat({required this.id, required this.name, required this.count});

  factory TypeStat.fromJson(Map<String, dynamic> j) => TypeStat(
        id:    (j['id'] as num?)?.toInt() ?? 0,
        name:  j['name'] as String? ?? '—',
        count: (j['count'] as num?)?.toInt() ?? 0,
      );
}

class AdminAnalytics {
  final AudienceGroup  downloads;
  final AudienceGroup  active;
  final List<TypeStat> typesByFavorites;
  final List<TypeStat> typesByVisits;

  const AdminAnalytics({
    required this.downloads,
    required this.active,
    required this.typesByFavorites,
    required this.typesByVisits,
  });

  factory AdminAnalytics.fromJson(Map<String, dynamic> j) {
    List<TypeStat> parseTypes(dynamic v) => (v as List? ?? [])
        .map((e) => TypeStat.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    return AdminAnalytics(
      downloads: AudienceGroup.fromJson((j['downloads'] as Map?)?.cast<String, dynamic>() ?? {}),
      active:    AudienceGroup.fromJson((j['active']    as Map?)?.cast<String, dynamic>() ?? {}),
      typesByFavorites: parseTypes(j['types_by_favorites']),
      typesByVisits:    parseTypes(j['types_by_visits']),
    );
  }
}

/// Descargas por geografía (País → Estado).
class GeoStats {
  final String country;
  final int    total;
  final List<({String state, int count})> states;

  const GeoStats({required this.country, required this.total, required this.states});

  factory GeoStats.fromJson(Map<String, dynamic> j) => GeoStats(
        country: j['country'] as String? ?? 'México',
        total:   (j['total'] as num?)?.toInt() ?? 0,
        states: (j['states'] as List? ?? []).map((e) {
          final m = (e as Map);
          return (state: m['state'] as String? ?? '—', count: (m['count'] as num?)?.toInt() ?? 0);
        }).toList(),
      );
}
