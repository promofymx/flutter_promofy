import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

/// Dona de género (male/female/unknown) con leyenda y %.
class GenderDonut extends StatelessWidget {
  final Map<String, int> gender;
  const GenderDonut({super.key, required this.gender});

  @override
  Widget build(BuildContext context) {
    final male    = gender['male']    ?? 0;
    final female  = gender['female']  ?? 0;
    final unknown = gender['unknown'] ?? 0;
    final total   = male + female + unknown;
    if (total == 0) return const SizedBox.shrink();

    const cMale   = Color(0xFF3B82F6);
    const cFemale = Color(0xFFEC4899);
    final  cUnk   = Colors.grey.shade400;
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
                PieChartSectionData(value: unknown.toDouble(), color: cUnk, title: '', radius: 22),
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

/// Barras de edades por rango.
class AgeBars extends StatelessWidget {
  final Map<String, int> buckets;
  const AgeBars({super.key, required this.buckets});

  static const _order = ['18-24', '25-34', '35-44', '45-54', '55+'];

  @override
  Widget build(BuildContext context) {
    final values = _order.map((k) => buckets[k] ?? 0).toList();
    final maxV   = (values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b)).toDouble();
    if (maxV == 0) {
      return Text('Sin datos de edad.', style: TextStyle(fontSize: 12, color: Colors.grey.shade500));
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
          leftTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= _order.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(_order[i], style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
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

/// Ranking horizontal (nombre + barra proporcional + conteo), con tap opcional.
class RankingBars extends StatelessWidget {
  final List<({String name, int count, int? id})> items;
  final void Function(int? id, String name)? onTap;
  const RankingBars({super.key, required this.items, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text('Sin datos todavía.', style: TextStyle(fontSize: 12, color: Colors.grey.shade500));
    }
    final maxV = items.map((e) => e.count).reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        for (final it in items.take(8))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: GestureDetector(
              onTap: onTap == null ? null : () => onTap!(it.id, it.name),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(it.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                  ),
                  Expanded(
                    flex: 6,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(height: 16, decoration: BoxDecoration(
                          color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6))),
                        FractionallySizedBox(
                          widthFactor: maxV == 0 ? 0 : it.count / maxV,
                          child: Container(height: 16, decoration: BoxDecoration(
                            color: AppColors.primary, borderRadius: BorderRadius.circular(6))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(width: 34, child: Text('${it.count}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark))),
                  if (onTap != null)
                    Icon(Icons.chevron_right, size: 16, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
