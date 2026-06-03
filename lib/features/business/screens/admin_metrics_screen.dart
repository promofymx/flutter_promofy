import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/admin_platform_metrics_model.dart';
import '../../../data/repositories/stats_repository.dart';
import '../cubit/admin_metrics_cubit.dart';
import '../cubit/admin_metrics_state.dart';
import 'admin_lugares_screen.dart';

/// Pantalla de métricas globales de la plataforma.
/// Solo visible para usuarios con role = 'admin'.
class AdminMetricsScreen extends StatelessWidget {
  const AdminMetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminMetricsCubit(repository: StatsRepository())..load(),
      child: const _AdminMetricsView(),
    );
  }
}

class _AdminMetricsView extends StatelessWidget {
  const _AdminMetricsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation:       0,
        title: const Text(
          'Panel Admin',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        actions: [
          IconButton(
            icon:    const Icon(Icons.add_business_rounded, color: AppColors.primary),
            tooltip: 'Gestionar restaurantes',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AdminLugaresScreen(),
              ),
            ),
          ),
          IconButton(
            icon:      const Icon(Icons.refresh_rounded, color: AppColors.textDark),
            tooltip:   'Actualizar métricas',
            onPressed: () => context.read<AdminMetricsCubit>().refresh(),
          ),
        ],
      ),
      body: BlocBuilder<AdminMetricsCubit, AdminMetricsState>(
        builder: (context, state) {
          if (state is AdminMetricsLoading || state is AdminMetricsInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is AdminMetricsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AdminMetricsCubit>().refresh(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is AdminMetricsLoaded) {
            return RefreshIndicator(
              color:     AppColors.primary,
              onRefresh: () => context.read<AdminMetricsCubit>().refresh(),
              child: _MetricsBody(m: state.metrics),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Cuerpo principal ─────────────────────────────────────────────────────────

class _MetricsBody extends StatelessWidget {
  final AdminPlatformMetrics m;
  const _MetricsBody({required this.m});

  @override
  Widget build(BuildContext context) {
    final mxn = NumberFormat.currency(locale: 'es_MX', symbol: r'$');
    final num = NumberFormat.decimalPattern('es_MX');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [

        // ── Acceso rápido: Restaurantes ───────────────────────────────────────
        _QuickAccessTile(
          icon:     Icons.add_business_rounded,
          color:    const Color(0xFF00897B),
          title:    'Admin Lugares',
          subtitle: 'Gestionar establecimientos y promociones del admin',
          onTap:    () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AdminLugaresScreen(),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ── Usuarios ──────────────────────────────────────────────────────────
        _SectionHeader(icon: Icons.people_rounded, title: 'Usuarios', color: Colors.blue),
        const SizedBox(height: 10),

        // Totales por rol
        _RoleSummaryCard(m: m),
        const SizedBox(height: 10),

        // Nuevos usuarios
        _PeriodCard(
          title: 'Nuevos usuarios',
          icon:  Icons.person_add_rounded,
          color: Colors.green,
          items: [
            _PeriodItem('Hoy',     num.format(m.newToday)),
            _PeriodItem('7 días',  num.format(m.new7d)),
            _PeriodItem('15 días', num.format(m.new15d)),
            _PeriodItem('30 días', num.format(m.new30d)),
          ],
        ),
        const SizedBox(height: 10),

        // Usuarios activos
        _PeriodCard(
          title: 'Usuarios activos',
          icon:  Icons.online_prediction_rounded,
          color: Colors.orange,
          items: [
            _PeriodItem('7 días',  num.format(m.active7d)),
            _PeriodItem('15 días', num.format(m.active15d)),
            _PeriodItem('30 días', num.format(m.active30d)),
          ],
        ),
        const SizedBox(height: 20),

        // ── Plataforma ────────────────────────────────────────────────────────
        _SectionHeader(icon: Icons.store_rounded, title: 'Plataforma', color: Colors.purple),
        const SizedBox(height: 10),

        Row(children: [
          Expanded(
            child: _SimpleMetricCard(
              label:   'Establecimientos',
              value:   num.format(m.totalEstablishments),
              sub:     '+${m.newEstablishments30d} este mes',
              icon:    Icons.storefront_rounded,
              color:   Colors.purple,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SimpleMetricCard(
              label:   'Promos activas',
              value:   num.format(m.activePromotions),
              sub:     '${num.format(m.totalPromotions)} total',
              icon:    Icons.local_offer_rounded,
              color:   Colors.deepOrange,
            ),
          ),
        ]),
        const SizedBox(height: 20),

        // ── Lealtad / QR ──────────────────────────────────────────────────────
        _SectionHeader(icon: Icons.qr_code_scanner_rounded, title: 'Lealtad & QR', color: Colors.teal),
        const SizedBox(height: 10),

        Row(children: [
          Expanded(
            child: _SimpleMetricCard(
              label:  'Escaneos totales',
              value:  num.format(m.totalQrScans),
              sub:    '${num.format(m.qrScans30d)} últimos 30d',
              icon:   Icons.qr_code_rounded,
              color:  Colors.teal,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SimpleMetricCard(
              label:  'Ticket promedio',
              value:  mxn.format(m.avgTicket),
              sub:    '',
              icon:   Icons.receipt_rounded,
              color:  Colors.teal,
            ),
          ),
        ]),
        const SizedBox(height: 10),

        _PeriodCard(
          title: 'Monto subido por meseros',
          icon:  Icons.attach_money_rounded,
          color: Colors.teal,
          items: [
            _PeriodItem('30 días',  mxn.format(m.ticketRevenue30d)),
            _PeriodItem('Total',    mxn.format(m.totalTicketRevenue)),
          ],
        ),
        const SizedBox(height: 20),

        // ── Campañas ──────────────────────────────────────────────────────────
        _SectionHeader(icon: Icons.campaign_rounded, title: 'Campañas Publicitarias', color: Colors.amber.shade700),
        const SizedBox(height: 10),

        Row(children: [
          Expanded(
            child: _SimpleMetricCard(
              label:  'Campañas activas',
              value:  num.format(m.activeCampaigns),
              sub:    '${num.format(m.totalCampaigns)} total',
              icon:   Icons.play_circle_rounded,
              color:  Colors.amber.shade700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SimpleMetricCard(
              label:  'Créditos vendidos',
              value:  mxn.format(m.creditsSold30d),
              sub:    'últimos 30 días',
              icon:   Icons.monetization_on_rounded,
              color:  Colors.amber.shade700,
            ),
          ),
        ]),
        const SizedBox(height: 10),

        _PeriodCard(
          title: 'Gasto en campañas',
          icon:  Icons.bar_chart_rounded,
          color: Colors.amber.shade700,
          items: [
            _PeriodItem('Hoy',    mxn.format(m.campaignSpendToday)),
            _PeriodItem('7 días', mxn.format(m.campaignSpend7d)),
            _PeriodItem('30 días',mxn.format(m.campaignSpend30d)),
          ],
        ),
        const SizedBox(height: 20),

        // ── Suscripciones ────────────────────────────────────────────────────
        _SectionHeader(icon: Icons.workspace_premium_rounded, title: 'Suscripciones', color: AppColors.primary),
        const SizedBox(height: 10),

        Row(children: [
          Expanded(
            child: _SimpleMetricCard(
              label:  'Suscripciones activas',
              value:  num.format(m.activeSubscriptions),
              sub:    '+${m.newSubscriptions30d} este mes',
              icon:   Icons.verified_rounded,
              color:  AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SimpleMetricCard(
              label:  'MRR',
              value:  mxn.format(m.monthlyRevenue),
              sub:    'ingresos mensuales',
              icon:   Icons.trending_up_rounded,
              color:  AppColors.primary,
            ),
          ),
        ]),
        const SizedBox(height: 20),

        // ── Rendimiento plataforma ───────────────────────────────────────────
        _SectionHeader(icon: Icons.insights_rounded, title: 'Rendimiento', color: Colors.indigo),
        const SizedBox(height: 10),

        _RevenueCard(m: m, mxn: mxn),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─── Widgets auxiliares ────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String   title;
  final Color    color;
  const _SectionHeader({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize:   12,
            fontWeight: FontWeight.w700,
            color:      color,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _RoleSummaryCard extends StatelessWidget {
  final AdminPlatformMetrics m;
  const _RoleSummaryCard({required this.m});

  @override
  Widget build(BuildContext context) {
    final num = NumberFormat.decimalPattern('es_MX');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            num.format(m.total),
            style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue,
            ),
          ),
          const Text('usuarios registrados', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 14),
          Row(children: [
            _RoleBadge(label: 'Usuarios',    count: m.userCount,  color: Colors.blue.shade300),
            const SizedBox(width: 8),
            _RoleBadge(label: 'Staff',       count: m.staffCount, color: Colors.green.shade400),
            const SizedBox(width: 8),
            _RoleBadge(label: 'Negocios',    count: m.ownerCount, color: AppColors.primary),
            const SizedBox(width: 8),
            _RoleBadge(label: 'Admin',       count: m.adminCount, color: Colors.red.shade400),
          ]),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String label;
  final int    count;
  final Color  color;
  const _RoleBadge({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color:        color.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
          border:       Border.all(color: color.withAlpha(80)),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
            Text(label, style: TextStyle(fontSize: 10, color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final String         title;
  final IconData       icon;
  final Color          color;
  final List<_PeriodItem> items;
  const _PeriodCard({
    required this.title, required this.icon, required this.color, required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: color)),
          ]),
          const SizedBox(height: 12),
          Row(
            children: items.map((item) => Expanded(
              child: Column(
                children: [
                  Text(item.value,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(item.label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _PeriodItem {
  final String label;
  final String value;
  const _PeriodItem(this.label, this.value);
}

class _SimpleMetricCard extends StatelessWidget {
  final String   label;
  final String   value;
  final String   sub;
  final IconData icon;
  final Color    color;
  const _SimpleMetricCard({
    required this.label, required this.value, required this.sub,
    required this.icon,  required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          if (sub.isNotEmpty)
            Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final AdminPlatformMetrics m;
  final NumberFormat         mxn;
  const _RevenueCard({required this.m, required this.mxn});

  @override
  Widget build(BuildContext context) {
    final roasVal = m.roas;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade700, Colors.indigo.shade400],
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ingresos plataforma (30 días)',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(mxn.format(m.totalRevenue30d),
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(children: [
            _RevenueItem('Suscripciones\n(MRR)', mxn.format(m.monthlyRevenue)),
            Container(width: 1, height: 40, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 12)),
            _RevenueItem('Créditos ad\n(30d)',   mxn.format(m.creditsSold30d)),
            Container(width: 1, height: 40, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 12)),
            _RevenueItem(
              'ROAS\n(ingresos/gasto ad)',
              roasVal > 0 ? '${roasVal.toStringAsFixed(1)}x' : 'N/A',
            ),
          ]),
        ],
      ),
    );
  }
}

class _RevenueItem extends StatelessWidget {
  final String label;
  final String value;
  const _RevenueItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Tile de acceso rápido ────────────────────────────────────────────────────

class _QuickAccessTile extends StatelessWidget {
  final IconData     icon;
  final Color        color;
  final String       title;
  final String       subtitle;
  final VoidCallback onTap;

  const _QuickAccessTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: color.withAlpha(60)),
          boxShadow: [
            BoxShadow(
                color:      Colors.black.withAlpha(10),
                blurRadius: 6,
                offset:     const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width:  48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize:   15,
                          fontWeight: FontWeight.bold,
                          color:      color)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
