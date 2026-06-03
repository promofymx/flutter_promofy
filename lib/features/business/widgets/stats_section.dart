import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/audience_model.dart';
import '../../../data/models/business_stats_model.dart';
import '../cubit/stats_cubit.dart';
import '../cubit/stats_state.dart';

class StatsSection extends StatefulWidget {
  /// ID del establecimiento seleccionado — necesario para la audiencia demográfica.
  final String? establishmentId;
  const StatsSection({super.key, this.establishmentId});

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection> {
  int _days = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Always propagate the establishmentId so demographics are always fetched,
      // even when the cubit already has stats from a previous load.
      context.read<StatsCubit>().load(
        days:            _days,
        establishmentId: widget.establishmentId,
      );
    });
  }

  @override
  void didUpdateWidget(StatsSection old) {
    super.didUpdateWidget(old);
    if (old.establishmentId != widget.establishmentId) {
      context.read<StatsCubit>().load(
        days:            _days,
        establishmentId: widget.establishmentId,
      );
    }
  }

  void _setDays(int days) {
    if (_days == days) return;
    setState(() => _days = days);
    context.read<StatsCubit>().load(
      days:            days,
      establishmentId: widget.establishmentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withAlpha(13),
            blurRadius: 8,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.bar_chart_rounded,
                  size:  20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Estadísticas',
                    style: TextStyle(
                      fontSize:   15,
                      fontWeight: FontWeight.bold,
                      color:      AppColors.textDark,
                    ),
                  ),
                ),
                // Botón de recarga
                BlocBuilder<StatsCubit, StatsState>(
                  builder: (context, state) {
                    if (state is StatsLoading) {
                      return const SizedBox(
                        width:  16,
                        height: 16,
                        child:  CircularProgressIndicator(
                          strokeWidth: 2,
                          color:       AppColors.primary,
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () =>
                          context.read<StatsCubit>().load(days: _days),
                      child: Icon(
                        Icons.refresh_rounded,
                        size:  18,
                        color: Colors.grey.shade400,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                // Toggle período
                _PeriodToggle(days: _days, onChanged: _setDays),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          // ── Contenido ──────────────────────────────────────────────────────
          BlocBuilder<StatsCubit, StatsState>(
            builder: (context, state) {
              if (state is StatsLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color:       AppColors.primary,
                    ),
                  ),
                );
              }
              if (state is StatsError) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline,
                          color: Colors.grey.shade400, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () =>
                            context.read<StatsCubit>().load(days: _days),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }
              if (state is StatsLoaded) {
                return _StatsContent(stats: state.stats, audience: state.audience);
              }
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── Toggle de período ────────────────────────────────────────────────────────

class _PeriodToggle extends StatelessWidget {
  final int              days;
  final void Function(int) onChanged;

  const _PeriodToggle({required this.days, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(label: '7d',  selected: days == 7,  onTap: () => onChanged(7)),
          _ToggleBtn(label: '30d', selected: days == 30, onTap: () => onChanged(30)),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String       label;
  final bool         selected;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color:        selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize:   11,
            fontWeight: FontWeight.w600,
            color:      selected ? Colors.white : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}

// ─── Contenido con datos ──────────────────────────────────────────────────────

class _StatsContent extends StatelessWidget {
  final BusinessStatsModel stats;
  final AudienceModel?     audience;

  const _StatsContent({required this.stats, this.audience});

  static final _moneyFmt = NumberFormat.currency(
    locale:        'es_MX',
    symbol:        '\$',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final hasTicket  = stats.avgTicket   != null;
    final hasRevenue = stats.totalRevenue != null && stats.totalRevenue! > 0;
    final hasPromos  = stats.promoStats.isNotEmpty;
    final hasClicks  = stats.contactClicks.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // ── Grid de métricas principales ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              // Fila 1
              Row(
                children: [
                  _StatTile(
                    icon:    Icons.storefront_outlined,
                    label:   'Vistas negocio',
                    value:   '${stats.establishmentViews}',
                    color:   AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  _StatTile(
                    icon:    Icons.campaign_outlined,
                    label:   'Vistas promos',
                    value:   '${stats.totalPromoViews}',
                    color:   AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  _StatTile(
                    icon:    Icons.favorite_rounded,
                    label:   'Nuevos favs',
                    value:   '${stats.newFavs}',
                    color:   Colors.pinkAccent.shade100,
                    iconColor: Colors.pinkAccent,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Fila 2
              Row(
                children: [
                  _StatTile(
                    icon:    Icons.phone_in_talk_outlined,
                    label:   'Contactos',
                    value:   '${stats.totalContacts}',
                    color:   Colors.teal.shade300,
                  ),
                  const SizedBox(width: 8),
                  _StatTile(
                    icon:    Icons.qr_code_scanner,
                    label:   'Visitas QR',
                    value:   '${stats.loyaltyVisits}',
                    color:   Colors.deepPurple.shade300,
                  ),
                  const SizedBox(width: 8),
                  _StatTile(
                    icon:      Icons.favorite_rounded,
                    label:     'Favs totales',
                    value:     '${stats.totalFavs}',
                    color:     Colors.pink.shade200,
                    iconColor: Colors.pinkAccent,
                  ),
                ],
              ),

              // Fila 3 — ticket promedio (si hay datos)
              if (hasTicket) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatTile(
                      icon:  Icons.receipt_long_outlined,
                      label: 'Ticket prom.',
                      value: _moneyFmt.format(stats.avgTicket!),
                      color: Colors.amber.shade600,
                      // Sin spacers — el único Expanded llena el Row completo
                    ),
                  ],
                ),
              ],

              // Fila 4 — ingresos (solo si hay datos)
              if (hasRevenue) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StatTile(
                      icon:  Icons.payments_outlined,
                      label: 'Ingresos generados',
                      value: _moneyFmt.format(stats.totalRevenue!),
                      color: Colors.green.shade600,
                      // Sin spacers — el único Expanded llena el Row completo
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // ── Desglose por promo ──────────────────────────────────────────────
        if (hasPromos) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DETALLE POR PROMO',
                  style: TextStyle(
                    fontSize:    10,
                    fontWeight:  FontWeight.w700,
                    color:       Colors.grey.shade500,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),

                // Encabezado tabla
                const Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Promo',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    _PromoCol(label: 'Vistas', tooltip: 'Veces que abrieron el detalle'),
                    _PromoCol(label: 'Favs +', tooltip: 'Nuevos favoritos en el período'),
                    _PromoCol(label: 'Favs Σ', tooltip: 'Total de favoritos acumulados'),
                  ],
                ),
                const Divider(height: 10, color: Color(0xFFF0F0F0)),

                // Filas
                ...stats.promoStats.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          p.promoName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      _PromoVal(value: p.views),
                      _PromoVal(
                        value: p.newFavs,
                        color: p.newFavs > 0
                            ? Colors.pinkAccent
                            : null,
                      ),
                      _PromoVal(value: p.totalFavs),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],

        // ── Desglose de canales de contacto ─────────────────────────────────
        if (hasClicks) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CANALES DE CONTACTO',
                  style: TextStyle(
                    fontSize:    10,
                    fontWeight:  FontWeight.w700,
                    color:       Colors.grey.shade500,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                ...stats.contactClicks.entries.map((e) => _ContactRow(
                  type:  e.key,
                  count: e.value,
                )),
              ],
            ),
          ),
        ],

        // ── Demografía de audiencia ─────────────────────────────────────────
        if (audience != null && audience!.hasData)
          _AudienceSection(audience: audience!),

        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── Tile de estadística ──────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final Color    color;
  final Color?   iconColor;
  final bool     wide;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.iconColor,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final iColor = iconColor ?? color;
    final widget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color:        color.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize:   18,
              fontWeight: FontWeight.bold,
              color:      iColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color:    Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
    if (wide) return Expanded(flex: 2, child: widget);
    return Expanded(child: widget);
  }
}

// ─── Celda de encabezado de tabla ────────────────────────────────────────────

class _PromoCol extends StatelessWidget {
  final String label;
  final String tooltip;
  const _PromoCol({required this.label, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize:   11,
            fontWeight: FontWeight.w600,
            color:      AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

// ─── Celda de valor de tabla ──────────────────────────────────────────────────

class _PromoVal extends StatelessWidget {
  final int    value;
  final Color? color;
  const _PromoVal({required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        '$value',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize:   12,
          fontWeight: FontWeight.w500,
          color:      color ?? Colors.grey.shade700,
        ),
      ),
    );
  }
}

// ─── Fila de canal de contacto ────────────────────────────────────────────────

class _ContactRow extends StatelessWidget {
  final String type;
  final int    count;

  const _ContactRow({required this.type, required this.count});

  static const _icons = {
    'whatsapp':  Icons.chat_rounded,
    'phone':     Icons.phone_outlined,
    'facebook':  Icons.facebook_outlined,
    'instagram': Icons.camera_alt_outlined,
    'website':   Icons.language_outlined,
    'maps':      Icons.map_outlined,
  };

  static const _labels = {
    'whatsapp':  'WhatsApp',
    'phone':     'Llamada',
    'facebook':  'Facebook',
    'instagram': 'Instagram',
    'website':   'Sitio web',
    'maps':      'Mapa',
  };

  static const _colors = {
    'whatsapp':  Color(0xFF25D366),
    'phone':     AppColors.primary,
    'facebook':  Color(0xFF1877F2),
    'instagram': Color(0xFFE1306C),
    'website':   Colors.grey,
    'maps':      Colors.teal,
  };

  @override
  Widget build(BuildContext context) {
    final icon  = _icons[type]  ?? Icons.touch_app_outlined;
    final label = _labels[type] ?? type;
    final color = _colors[type] ?? Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textDark),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color:        color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize:   12,
                fontWeight: FontWeight.w600,
                color:      color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sección de demografía de audiencia ──────────────────────────────────────

class _AudienceSection extends StatefulWidget {
  final AudienceModel audience;
  const _AudienceSection({required this.audience});
  @override
  State<_AudienceSection> createState() => _AudienceSectionState();
}

class _AudienceSectionState extends State<_AudienceSection> {
  bool _expanded = false; // per-promo collapsed by default

  @override
  Widget build(BuildContext context) {
    final aud = widget.audience;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AUDIENCIA (${aud.total} favoriteadores)',
                style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700,
                  color: Colors.grey.shade500, letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 12),

              // ── Sexo ──────────────────────────────────────────────────────
              Text('Sexo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700)),
              const SizedBox(height: 6),
              _GenderBars(genderCounts: aud.genderCounts, total: aud.total),

              if (aud.ageBuckets.isNotEmpty) ...[
                const SizedBox(height: 14),
                // ── Edad ────────────────────────────────────────────────────
                Text('Edad', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700)),
                const SizedBox(height: 6),
                _AgeBars(buckets: aud.ageBuckets, total: aud.total),
              ],

              // ── Por promo (colapsable) ────────────────────────────────────
              if (aud.perPromo.isNotEmpty) ...[
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Row(
                    children: [
                      Text('Por promoción',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700)),
                      const Spacer(),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 18, color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),
                if (_expanded) ...[
                  const SizedBox(height: 8),
                  ...aud.perPromo.map((p) => _PromoAudienceRow(promo: p)),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _GenderBars extends StatelessWidget {
  final Map<String, int> genderCounts;
  final int total;
  const _GenderBars({required this.genderCounts, required this.total});

  static const _order  = ['male', 'female', 'unknown'];
  static const _labels = {'male': 'Hombres', 'female': 'Mujeres', 'unknown': 'N/E'};
  static const _colors = {
    'male':    Color(0xFF1976D2),
    'female':  Color(0xFFE91E8C),
    'unknown': Color(0xFF9E9E9E),
  };

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();
    final entries = _order.where((k) => genderCounts.containsKey(k)).toList();
    return Column(
      children: entries.map((key) {
        final count = genderCounts[key] ?? 0;
        final pct   = total > 0 ? count / total : 0.0;
        final color = _colors[key] ?? Colors.grey;
        final label = _labels[key] ?? key;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(
                width: 60,
                child: Text(label,
                    style: const TextStyle(fontSize: 11, color: AppColors.textDark)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:           pct,
                    backgroundColor: color.withAlpha(25),
                    color:           color,
                    minHeight:       10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 38,
                child: Text(
                  '${(pct * 100).round()}%',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _AgeBars extends StatelessWidget {
  final List<AgeGroup> buckets;
  final int            total;
  const _AgeBars({required this.buckets, required this.total});

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty || total == 0) return const SizedBox.shrink();
    final maxCount = buckets.map((b) => b.count).reduce((a, b) => a > b ? a : b);
    return Column(
      children: buckets.map((b) {
        final pct = maxCount > 0 ? b.count / maxCount : 0.0;
        final globalPct = total > 0 ? b.count / total : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              SizedBox(
                width: 46,
                child: Text(b.label,
                    style: const TextStyle(fontSize: 11, color: AppColors.textDark)),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value:           pct,
                    backgroundColor: AppColors.primary.withAlpha(20),
                    color:           AppColors.primary,
                    minHeight:       10,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 38,
                child: Text(
                  '${(globalPct * 100).round()}%',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PromoAudienceRow extends StatelessWidget {
  final PromoAudienceModel promo;
  const _PromoAudienceRow({required this.promo});

  @override
  Widget build(BuildContext context) {
    if (promo.total == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            promo.promoName,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          _GenderBars(genderCounts: promo.genderCounts, total: promo.total),
          if (promo.ageBuckets.isNotEmpty) ...[
            const SizedBox(height: 4),
            _AgeBars(buckets: promo.ageBuckets, total: promo.total),
          ],
        ],
      ),
    );
  }
}
