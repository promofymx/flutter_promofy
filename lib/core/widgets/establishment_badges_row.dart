import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/app_theme.dart';

/// Fila con la calificación de Google (atribuida con su logo) + las insignias
/// del establecimiento (🏆 Favorito de la zona, 👑 Más visitado, ⭐ Mejor
/// calificado, 🔥 En tendencia, 🎟️ Más promos).
///
/// La calificación se muestra SIEMPRE con el logo de Google a la izquierda para
/// dejar claro que el dato es de Google, no nuestro. Si el negocio no tiene
/// calificación, simplemente no aparecen estrellas. Si no hay nada que mostrar,
/// el widget no ocupa espacio.
class EstablishmentBadgesRow extends StatefulWidget {
  final String establishmentId;
  const EstablishmentBadgesRow({super.key, required this.establishmentId});

  @override
  State<EstablishmentBadgesRow> createState() => _EstablishmentBadgesRowState();
}

class _EstablishmentBadgesRowState extends State<EstablishmentBadgesRow> {
  late Future<_RowData> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<_RowData> _fetch() async {
    final client = Supabase.instance.client;
    final results = await Future.wait([
      _fetchRating(client),
      _fetchBadges(client),
    ]);
    return _RowData(
      rating: results[0] as _GoogleRating?,
      badges: results[1] as List<_Badge>,
    );
  }

  Future<_GoogleRating?> _fetchRating(SupabaseClient client) async {
    try {
      final rows = await client.rpc(
        'get_establishment_google_rating',
        params: {'p_establishment_id': widget.establishmentId},
      );
      if (rows is! List || rows.isEmpty) return null;
      final m = Map<String, dynamic>.from(rows.first as Map);
      final r = (m['rating'] as num?)?.toDouble();
      if (r == null || r <= 0) return null;
      return _GoogleRating(r, (m['reviews'] as num?)?.toInt());
    } catch (_) {
      return null;
    }
  }

  Future<List<_Badge>> _fetchBadges(SupabaseClient client) async {
    try {
      final rows = await client.rpc(
        'get_establishment_badges',
        params: {'p_establishment_id': widget.establishmentId},
      );
      return (rows as List)
          .map((e) => _Badge.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_RowData>(
      future: _future,
      builder: (context, snap) {
        final data = snap.data;
        if (data == null) return const SizedBox.shrink();
        if (data.rating == null && data.badges.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (data.rating != null) _GoogleRatingChip(rating: data.rating!),
              ...data.badges.map((b) => _BadgeChip(badge: b)),
            ],
          ),
        );
      },
    );
  }
}

// ─── Datos ──────────────────────────────────────────────────────────────────

class _RowData {
  final _GoogleRating? rating;
  final List<_Badge> badges;
  const _RowData({required this.rating, required this.badges});
}

class _GoogleRating {
  final double value;
  final int? reviews;
  const _GoogleRating(this.value, this.reviews);
}

// ─── Chip de calificación de Google (con atribución) ──────────────────────────

class _GoogleRatingChip extends StatelessWidget {
  final _GoogleRating rating;
  const _GoogleRatingChip({required this.rating});

  @override
  Widget build(BuildContext context) {
    final reviews = rating.reviews;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/images/google_g.svg', height: 14, width: 14),
          const SizedBox(width: 6),
          const Icon(Icons.star_rounded, size: 15, color: Color(0xFFFBBC05)),
          const SizedBox(width: 2),
          Text(
            rating.value.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3C4043),
            ),
          ),
          if (reviews != null && reviews > 0) ...[
            const SizedBox(width: 4),
            Text(
              '($reviews)',
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF70757A)),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Modelo de insignia ───────────────────────────────────────────────────────

class _Badge {
  final String type;       // fav | visited | rating | trending | promos
  final String? zone;      // Centro|Norte|Sur|Oriente|Poniente|Única
  final int rank;
  const _Badge({required this.type, this.zone, required this.rank});

  factory _Badge.fromJson(Map<String, dynamic> j) => _Badge(
        type: j['badge'] as String? ?? '',
        zone: j['zone'] as String?,
        rank: (j['rank'] as num?)?.toInt() ?? 1,
      );

  static const _meta = {
    'fav':      ('🏆', 'Favorito',        Color(0xFFF59E0B)),
    'visited':  ('👑', 'Más visitado',    Color(0xFF7C3AED)),
    'rating':   ('⭐', 'Mejor calificado', Color(0xFF2563EB)),
    'trending': ('🔥', 'En tendencia',    Color(0xFFEF4444)),
    'promos':   ('🎟️', 'Más promos',      AppColors.primary),
  };

  (String, String, Color) get meta => _meta[type] ?? ('🏅', 'Destacado', AppColors.primary);

  String get label {
    final name = meta.$2;
    final z = (zone != null && zone!.isNotEmpty && zone != 'Única') ? ' del $zone' : '';
    return rank == 1 ? '$name$z' : 'Top $name$z';
  }

  String get emoji => meta.$1;
  Color  get color => meta.$3;
}

// ─── Chip de insignia ─────────────────────────────────────────────────────────

class _BadgeChip extends StatelessWidget {
  final _Badge badge;
  const _BadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badge.color.withAlpha(22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badge.color.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(badge.emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            badge.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: badge.color,
            ),
          ),
        ],
      ),
    );
  }
}
