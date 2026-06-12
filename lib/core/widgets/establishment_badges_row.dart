import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/app_theme.dart';

/// Fila de insignias del establecimiento (🏆 Favorito de la zona, 👑 Más
/// visitado, ⭐ Mejor calificado, 🔥 En tendencia, 🎟️ Más promos).
/// Las trae del RPC get_establishment_badges y las pinta como chips. Si no hay,
/// no ocupa espacio.
class EstablishmentBadgesRow extends StatefulWidget {
  final String establishmentId;
  const EstablishmentBadgesRow({super.key, required this.establishmentId});

  @override
  State<EstablishmentBadgesRow> createState() => _EstablishmentBadgesRowState();
}

class _EstablishmentBadgesRowState extends State<EstablishmentBadgesRow> {
  late Future<List<_Badge>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<List<_Badge>> _fetch() async {
    try {
      final rows = await Supabase.instance.client.rpc(
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
    return FutureBuilder<List<_Badge>>(
      future: _future,
      builder: (context, snap) {
        final badges = snap.data ?? const [];
        if (badges.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: badges.map((b) => _BadgeChip(badge: b)).toList(),
          ),
        );
      },
    );
  }
}

// ─── Modelo ───────────────────────────────────────────────────────────────────

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

// ─── Chip ─────────────────────────────────────────────────────────────────────

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
