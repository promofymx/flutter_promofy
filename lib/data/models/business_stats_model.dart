import 'package:equatable/equatable.dart';

// ─── Detalle por promo ────────────────────────────────────────────────────────

class PromoStatModel extends Equatable {
  final String promoId;
  final String promoName;
  final int    views;
  final int    totalFavs;
  final int    newFavs;

  const PromoStatModel({
    required this.promoId,
    required this.promoName,
    required this.views,
    required this.totalFavs,
    required this.newFavs,
  });

  factory PromoStatModel.fromJson(Map<String, dynamic> json) {
    return PromoStatModel(
      promoId:   json['promo_id']   as String,
      promoName: json['promo_name'] as String,
      views:     (json['views']     as num?)?.toInt() ?? 0,
      totalFavs: (json['total_favs'] as num?)?.toInt() ?? 0,
      newFavs:   (json['new_favs']   as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [promoId, views, totalFavs, newFavs];
}

// ─── Stats del negocio ────────────────────────────────────────────────────────

class BusinessStatsModel extends Equatable {
  final int                days;
  final int                establishmentViews;
  final List<PromoStatModel> promoStats;
  final Map<String, int>   contactClicks;
  final int                loyaltyVisits;
  final double?            avgTicket;
  final double?            totalRevenue;

  const BusinessStatsModel({
    required this.days,
    required this.establishmentViews,
    required this.promoStats,
    required this.contactClicks,
    required this.loyaltyVisits,
    this.avgTicket,
    this.totalRevenue,
  });

  // Totales de promos (suma sobre todas)
  int get totalPromoViews  => promoStats.fold(0, (s, p) => s + p.views);
  int get totalFavs        => promoStats.fold(0, (s, p) => s + p.totalFavs);
  int get newFavs          => promoStats.fold(0, (s, p) => s + p.newFavs);
  int get totalContacts    => contactClicks.values.fold(0, (s, v) => s + v);

  factory BusinessStatsModel.fromJson(Map<String, dynamic> json, {required int days}) {
    // Promo stats
    final rawPromos = json['promo_stats'];
    final promos = (rawPromos is List)
        ? rawPromos
            .whereType<Map<String, dynamic>>()
            .map(PromoStatModel.fromJson)
            .toList()
        : <PromoStatModel>[];

    // Contact clicks → Map<type, count>
    final rawClicks = json['contact_clicks'];
    final clicks = <String, int>{};
    if (rawClicks is List) {
      for (final item in rawClicks.whereType<Map<String, dynamic>>()) {
        final type  = item['type']  as String?;
        final count = (item['count'] as num?)?.toInt() ?? 0;
        if (type != null) clicks[type] = count;
      }
    }

    return BusinessStatsModel(
      days:               days,
      establishmentViews: (json['establishment_views'] as num?)?.toInt() ?? 0,
      promoStats:         promos,
      contactClicks:      clicks,
      loyaltyVisits:      (json['loyalty_visits'] as num?)?.toInt() ?? 0,
      avgTicket:          (json['avg_ticket']     as num?)?.toDouble(),
      totalRevenue:       (json['total_revenue']  as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    days, establishmentViews, promoStats,
    contactClicks, loyaltyVisits, avgTicket, totalRevenue,
  ];
}
