import 'package:flutter/material.dart';

// ── Insignia de visitas anuales ───────────────────────────────────────────────

enum BadgeTier {
  none,
  explorador,         // ≥  5
  comensal,           // ≥ 15
  comensalFrecuente,  // ≥ 40
  topComensal,        // ≥ 80
  vipPromofy,         // ≥150
}

extension BadgeTierX on BadgeTier {
  int get minVisits {
    switch (this) {
      case BadgeTier.none:              return 0;
      case BadgeTier.explorador:        return 5;
      case BadgeTier.comensal:          return 15;
      case BadgeTier.comensalFrecuente: return 40;
      case BadgeTier.topComensal:       return 80;
      case BadgeTier.vipPromofy:        return 150;
    }
  }

  String get label {
    switch (this) {
      case BadgeTier.none:              return 'Nuevo miembro';
      case BadgeTier.explorador:        return 'Explorador';
      case BadgeTier.comensal:          return 'Comensal';
      case BadgeTier.comensalFrecuente: return 'Comensal Frecuente';
      case BadgeTier.topComensal:       return 'Top Comensal';
      case BadgeTier.vipPromofy:        return 'VIP Promofy';
    }
  }

  String get emoji {
    switch (this) {
      case BadgeTier.none:              return '👋';
      case BadgeTier.explorador:        return '🧭';
      case BadgeTier.comensal:          return '🍽️';
      case BadgeTier.comensalFrecuente: return '⭐';
      case BadgeTier.topComensal:       return '🏆';
      case BadgeTier.vipPromofy:        return '💎';
    }
  }

  Color get color {
    switch (this) {
      case BadgeTier.none:              return const Color(0xFF78909C);
      case BadgeTier.explorador:        return const Color(0xFF5C6BC0);
      case BadgeTier.comensal:          return const Color(0xFF43A047);
      case BadgeTier.comensalFrecuente: return const Color(0xFF00897B);
      case BadgeTier.topComensal:       return const Color(0xFFFF8F00);
      case BadgeTier.vipPromofy:        return const Color(0xFFE8302A);
    }
  }

  /// Descripción breve para la pantalla de logros.
  String get description {
    switch (this) {
      case BadgeTier.none:              return 'Empieza a escanear QR en tus lugares favoritos';
      case BadgeTier.explorador:        return 'Completaste 5 visitas a negocios en Promofy';
      case BadgeTier.comensal:          return 'Completaste 15 visitas — ¡ya eres un habitual!';
      case BadgeTier.comensalFrecuente: return '40 visitas: eres un comensal de verdad';
      case BadgeTier.topComensal:       return '80 visitas — estás en la élite de tu ciudad';
      case BadgeTier.vipPromofy:        return '150 visitas: ¡leyenda viva de Promofy!';
    }
  }
}

// ── Insignia de racha semanal ─────────────────────────────────────────────────

enum StreakBadge {
  none,
  enRacha,   // ≥ 3 semanas
  imparable, // ≥ 8 semanas
  leyenda,   // ≥26 semanas
}

extension StreakBadgeX on StreakBadge {
  int get minWeeks {
    switch (this) {
      case StreakBadge.none:      return 0;
      case StreakBadge.enRacha:   return 3;
      case StreakBadge.imparable: return 8;
      case StreakBadge.leyenda:   return 26;
    }
  }

  String get label {
    switch (this) {
      case StreakBadge.none:      return 'Sin racha';
      case StreakBadge.enRacha:   return 'En Racha';
      case StreakBadge.imparable: return 'Imparable';
      case StreakBadge.leyenda:   return 'Leyenda';
    }
  }

  String get emoji {
    switch (this) {
      case StreakBadge.none:      return '💤';
      case StreakBadge.enRacha:   return '🔥';
      case StreakBadge.imparable: return '⚡';
      case StreakBadge.leyenda:   return '👑';
    }
  }

  Color get color {
    switch (this) {
      case StreakBadge.none:      return const Color(0xFF90A4AE);
      case StreakBadge.enRacha:   return const Color(0xFFFF7043);
      case StreakBadge.imparable: return const Color(0xFF7E57C2);
      case StreakBadge.leyenda:   return const Color(0xFFFFB300);
    }
  }
}

// ── Modelo de estadísticas de usuario ────────────────────────────────────────

class UserStatsModel {
  final int      annualVisits;
  final int      currentStreakWeeks;
  final double?  topPercent;       // null si no hay datos de ciudad suficientes
  final DateTime? annualCycleStart;

  const UserStatsModel({
    required this.annualVisits,
    required this.currentStreakWeeks,
    this.topPercent,
    this.annualCycleStart,
  });

  factory UserStatsModel.empty() => const UserStatsModel(
    annualVisits: 0,
    currentStreakWeeks: 0,
  );

  factory UserStatsModel.fromJson(Map<String, dynamic> j) {
    return UserStatsModel(
      annualVisits:       (j['annual_visits']        as num?)?.toInt() ?? 0,
      currentStreakWeeks: (j['current_streak_weeks'] as num?)?.toInt() ?? 0,
      topPercent:         (j['top_percent']          as num?)?.toDouble(),
      annualCycleStart:   j['annual_cycle_start'] != null
          ? DateTime.tryParse(j['annual_cycle_start'] as String)
          : null,
    );
  }

  // ── Insignia anual ────────────────────────────────────────────────────────

  BadgeTier get currentBadge {
    if (annualVisits >= 150) return BadgeTier.vipPromofy;
    if (annualVisits >= 80)  return BadgeTier.topComensal;
    if (annualVisits >= 40)  return BadgeTier.comensalFrecuente;
    if (annualVisits >= 15)  return BadgeTier.comensal;
    if (annualVisits >= 5)   return BadgeTier.explorador;
    return BadgeTier.none;
  }

  /// Siguiente nivel; null si ya se alcanzó el máximo.
  BadgeTier? get nextBadge {
    for (final tier in BadgeTier.values) {
      if (tier == BadgeTier.none) continue;
      if (annualVisits < tier.minVisits) return tier;
    }
    return null;
  }

  /// Visitas que faltan para el siguiente badge.
  int get visitsToNextBadge {
    final next = nextBadge;
    if (next == null) return 0;
    return next.minVisits - annualVisits;
  }

  /// Progreso [0.0 – 1.0] dentro del rango actual → siguiente badge.
  double get badgeProgress {
    final curr = currentBadge;
    final next = nextBadge;
    if (next == null) return 1.0;
    final from = curr.minVisits;
    final to   = next.minVisits;
    if (to == from) return 1.0;
    return ((annualVisits - from) / (to - from)).clamp(0.0, 1.0);
  }

  // ── Racha ─────────────────────────────────────────────────────────────────

  StreakBadge get streakBadge {
    if (currentStreakWeeks >= 26) return StreakBadge.leyenda;
    if (currentStreakWeeks >= 8)  return StreakBadge.imparable;
    if (currentStreakWeeks >= 3)  return StreakBadge.enRacha;
    return StreakBadge.none;
  }
}
