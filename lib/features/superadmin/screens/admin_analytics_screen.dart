import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/demographic_charts.dart';
import '../../../data/models/admin_analytics_model.dart';
import '../../../data/models/audience_stats_model.dart';
import '../../../data/repositories/admin_analytics_repository.dart';

/// Fase 2 — Analítica de superadmin.
class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});
  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  final _repo = AdminAnalyticsRepository();
  late Future<AdminAnalytics> _future;
  int _demo = 0; // 0=descargas, 1=activos

  @override
  void initState() {
    super.initState();
    _future = _repo.getAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        title: const Text('Analítica', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<AdminAnalytics>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snap.hasError || !snap.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.grey.shade400, size: 34),
                  const SizedBox(height: 10),
                  const Text('No se pudo cargar la analítica.'),
                  TextButton(
                    onPressed: () => setState(() => _future = _repo.getAnalytics()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          final a   = snap.data!;
          final grp = _demo == 0 ? a.downloads : a.active;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              // ── Demografía ──────────────────────────────────────────────
              _Card(
                title: 'Demografía de usuarios',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Segmented(
                      labels: const ['Descargas', 'Activos (30d)'],
                      selected: _demo,
                      onSelect: (i) => setState(() => _demo = i),
                    ),
                    const SizedBox(height: 14),
                    _DemoBody(group: grp),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ── Tipos con más favoritos ─────────────────────────────────
              _Card(
                title: 'Tipos con más favoritos',
                subtitle: 'Toca un tipo para ver qué establecimientos lo componen',
                child: RankingBars(
                  items: [for (final t in a.typesByFavorites) (name: t.name, count: t.count, id: t.id)],
                  onTap: (id, name) => _openBreakdown(id!, name, 'favorites'),
                ),
              ),
              const SizedBox(height: 16),
              // ── Tipos más visitados ─────────────────────────────────────
              _Card(
                title: 'Tipos más visitados',
                subtitle: 'Datos del programa de lealtad · toca para desglosar',
                child: RankingBars(
                  items: [for (final t in a.typesByVisits) (name: t.name, count: t.count, id: t.id)],
                  onTap: (id, name) => _openBreakdown(id!, name, 'visits'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openBreakdown(int categoryId, String typeName, String metric) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BreakdownSheet(
        title:  typeName,
        metric: metric,
        future: _repo.getTypeBreakdown(categoryId, metric),
      ),
    );
  }
}

class _DemoBody extends StatelessWidget {
  final AudienceGroup group;
  const _DemoBody({required this.group});
  @override
  Widget build(BuildContext context) {
    if (group.count == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text('Sin datos en este grupo.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Stat(value: '${group.count}', label: 'usuarios'),
            const SizedBox(width: 24),
            if (group.avgAge != null) _Stat(value: '${group.avgAge}', label: 'edad prom.'),
          ],
        ),
        const SizedBox(height: 16),
        const _Label('Género'),
        const SizedBox(height: 8),
        GenderDonut(gender: group.gender),
        const SizedBox(height: 18),
        const _Label('Edades'),
        const SizedBox(height: 8),
        AgeBars(buckets: group.ageBuckets),
      ],
    );
  }
}

class _BreakdownSheet extends StatelessWidget {
  final String title;
  final String metric;
  final Future<List<({String name, int count, int? id})>> future;
  const _BreakdownSheet({required this.title, required this.metric, required this.future});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            ),
            Text(title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            Text(metric == 'visits' ? 'Establecimientos por visitas' : 'Establecimientos por favoritos',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            const SizedBox(height: 14),
            FutureBuilder<List<({String name, int count, int? id})>>(
              future: future,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  );
                }
                final items = snap.data!;
                if (items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text('Sin datos.', style: TextStyle(color: Colors.grey.shade500)),
                  );
                }
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
                  child: RankingBars(
                    items: [for (final e in items) (name: e.name, count: e.count, id: null)],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Auxiliares ──────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final String  title;
  final String? subtitle;
  final Widget  child;
  const _Card({required this.title, this.subtitle, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            ],
            const SizedBox(height: 14),
            child,
          ],
        ),
      );
}

class _Segmented extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;
  const _Segmented({required this.labels, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: i == selected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(labels[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: i == selected ? Colors.white : Colors.grey.shade600)),
                  ),
                ),
              ),
          ],
        ),
      );
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: Colors.grey.shade500, letterSpacing: 0.6));
}
