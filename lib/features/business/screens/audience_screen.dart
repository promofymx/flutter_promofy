import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/audience_stats_model.dart';
import '../../../data/repositories/audience_repository.dart';

/// Fase 1 — "Mi audiencia": demografía (edad/género) de favoritos y clientes
/// de lealtad de un establecimiento.
class AudienceScreen extends StatefulWidget {
  final String establishmentId;
  final String establishmentName;
  const AudienceScreen({
    super.key,
    required this.establishmentId,
    required this.establishmentName,
  });

  @override
  State<AudienceScreen> createState() => _AudienceScreenState();
}

class _AudienceScreenState extends State<AudienceScreen> {
  late Future<AudienceStats> _future;

  @override
  void initState() {
    super.initState();
    _future = AudienceRepository().getOwnerAudience(widget.establishmentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        title: const Text('Mi audiencia',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(widget.establishmentName,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ),
          ),
        ),
      ),
      body: FutureBuilder<AudienceStats>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snap.hasError || !snap.hasData) {
            return _ErrorView(onRetry: () => setState(() {
                  _future = AudienceRepository()
                      .getOwnerAudience(widget.establishmentId);
                }));
          }
          final s = snap.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              const _Intro(),
              const SizedBox(height: 16),
              _AudienceCard(
                title:    'Favoritos del local',
                subtitle: 'Personas que marcaron tu negocio como favorito',
                icon:     Icons.store_outlined,
                group:    s.establishmentFavorites,
              ),
              const SizedBox(height: 16),
              _AudienceCard(
                title:    'Favoritos de tus promos',
                subtitle: 'Personas que guardaron alguna promoción tuya',
                icon:     Icons.local_offer_outlined,
                group:    s.promoFavorites,
              ),
              const SizedBox(height: 16),
              _AudienceCard(
                title:    'Clientes recurrentes',
                subtitle: 'Quienes participan en tu programa de lealtad',
                icon:     Icons.card_giftcard_outlined,
                group:    s.loyalty,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        AppColors.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.insights_outlined, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Conoce la edad y el género de quienes siguen tu negocio. '
              'Los datos son anónimos y agregados.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _AudienceCard extends StatelessWidget {
  final String        title;
  final String        subtitle;
  final IconData      icon;
  final AudienceGroup group;
  const _AudienceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold,
                            color: AppColors.textDark)),
                    Text(subtitle,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              _Pill(label: '${group.count}', sub: 'personas'),
            ],
          ),
          const SizedBox(height: 14),
          if (!group.enough)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.hourglass_empty, color: Colors.grey.shade400, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      group.count == 0
                          ? 'Aún no tienes datos en este grupo.'
                          : 'Pocos datos todavía (mín. 5 personas\npara mostrar la demografía).',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500, height: 1.4),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            if (group.avgAge != null)
              Row(
                children: [
                  const Icon(Icons.cake_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text('Edad promedio: ',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                  Text('${group.avgAge} años',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold,
                          color: AppColors.textDark)),
                ],
              ),
            const SizedBox(height: 16),
            const _SectionLabel('Género'),
            const SizedBox(height: 8),
            _GenderChart(gender: group.gender),
            const SizedBox(height: 20),
            const _SectionLabel('Edades'),
            const SizedBox(height: 8),
            _AgeChart(buckets: group.ageBuckets),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: Colors.grey.shade500, letterSpacing: 0.6),
      );
}

class _Pill extends StatelessWidget {
  final String label;
  final String sub;
  const _Pill({required this.label, required this.sub});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
          Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        ],
      );
}

// ─── Gráfica de género (donut + leyenda con %) ───────────────────────────────
class _GenderChart extends StatelessWidget {
  final Map<String, int> gender;
  const _GenderChart({required this.gender});

  @override
  Widget build(BuildContext context) {
    final male    = gender['male']    ?? 0;
    final female  = gender['female']  ?? 0;
    final unknown = gender['unknown'] ?? 0;
    final total   = male + female + unknown;
    if (total == 0) return const SizedBox.shrink();

    const cMale    = Color(0xFF3B82F6);
    const cFemale  = Color(0xFFEC4899);
    final  cUnk    = Colors.grey.shade400;

    String pct(int v) => '${(v / total * 100).round()}%';

    return Row(
      children: [
        SizedBox(
          width: 110, height: 110,
          child: PieChart(PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 30,
            sections: [
              if (male > 0)
                PieChartSectionData(value: male.toDouble(), color: cMale,
                    title: pct(male), radius: 22,
                    titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              if (female > 0)
                PieChartSectionData(value: female.toDouble(), color: cFemale,
                    title: pct(female), radius: 22,
                    titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              if (unknown > 0)
                PieChartSectionData(value: unknown.toDouble(), color: cUnk,
                    title: '', radius: 22),
            ],
          )),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (male > 0)    _LegendRow(color: cMale,   label: 'Hombres', value: '${pct(male)} ($male)'),
              if (female > 0)  _LegendRow(color: cFemale, label: 'Mujeres', value: '${pct(female)} ($female)'),
              if (unknown > 0) _LegendRow(color: cUnk,    label: 'Sin dato', value: '${pct(unknown)} ($unknown)'),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _LegendRow({required this.color, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Container(width: 11, height: 11,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 8),
            Expanded(child: Text(label,
                style: const TextStyle(fontSize: 13, color: AppColors.textDark))),
            Text(value,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
          ],
        ),
      );
}

// ─── Gráfica de edades (barras) ──────────────────────────────────────────────
class _AgeChart extends StatelessWidget {
  final Map<String, int> buckets;
  const _AgeChart({required this.buckets});

  static const _order = ['18-24', '25-34', '35-44', '45-54', '55+'];

  @override
  Widget build(BuildContext context) {
    final values = _order.map((k) => buckets[k] ?? 0).toList();
    final maxV   = (values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b)).toDouble();
    if (maxV == 0) {
      return Text('Sin datos de edad.',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500));
    }

    return SizedBox(
      height: 150,
      child: BarChart(BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxV * 1.2,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
              '${rod.toY.toInt()}',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= _order.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_order[i],
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: values[i].toDouble(),
                color: AppColors.primary,
                width: 22,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
              ),
            ]),
        ],
      )),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.grey.shade400, size: 36),
            const SizedBox(height: 10),
            Text('No se pudo cargar la audiencia.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      );
}
