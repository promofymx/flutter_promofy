import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:promofy/l10n/app_localizations.dart';
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
        title: Text(
          AppLocalizations.of(context).adminMetricsTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        actions: [
          IconButton(
            icon:    const Icon(Icons.add_business_rounded, color: AppColors.primary),
            tooltip: AppLocalizations.of(context).adminMetricsManageRestaurants,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const AdminLugaresScreen(),
              ),
            ),
          ),
          IconButton(
            icon:      const Icon(Icons.refresh_rounded, color: AppColors.textDark),
            tooltip:   AppLocalizations.of(context).adminMetricsRefresh,
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
                    child: Text(AppLocalizations.of(context).adminMetricsRetry),
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
          title:    AppLocalizations.of(context).adminMetricsAdminPlaces,
          subtitle: AppLocalizations.of(context).adminMetricsAdminPlacesSubtitle,
          onTap:    () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AdminLugaresScreen(),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ── Usuarios ──────────────────────────────────────────────────────────
        _SectionHeader(icon: Icons.people_rounded, title: AppLocalizations.of(context).adminMetricsSectionUsers, color: Colors.blue),
        const SizedBox(height: 10),

        // Totales por rol
        _RoleSummaryCard(m: m),
        const SizedBox(height: 10),

        // Nuevos usuarios
        _PeriodCard(
          title: AppLocalizations.of(context).adminMetricsNewUsers,
          icon:  Icons.person_add_rounded,
          color: Colors.green,
          items: [
            _PeriodItem(AppLocalizations.of(context).adminMetricsPeriodToday,  num.format(m.newToday)),
            _PeriodItem(AppLocalizations.of(context).adminMetricsPeriod7d,     num.format(m.new7d)),
            _PeriodItem(AppLocalizations.of(context).adminMetricsPeriod15d,    num.format(m.new15d)),
            _PeriodItem(AppLocalizations.of(context).adminMetricsPeriod30d,    num.format(m.new30d)),
          ],
        ),
        const SizedBox(height: 10),

        // Usuarios activos
        _PeriodCard(
          title: AppLocalizations.of(context).adminMetricsActiveUsers,
          icon:  Icons.online_prediction_rounded,
          color: Colors.orange,
          items: [
            _PeriodItem(AppLocalizations.of(context).adminMetricsPeriod7d,  num.format(m.active7d)),
            _PeriodItem(AppLocalizations.of(context).adminMetricsPeriod15d, num.format(m.active15d)),
            _PeriodItem(AppLocalizations.of(context).adminMetricsPeriod30d, num.format(m.active30d)),
          ],
        ),
        const SizedBox(height: 20),

        // ── Plataforma ────────────────────────────────────────────────────────
        _SectionHeader(icon: Icons.store_rounded, title: AppLocalizations.of(context).adminMetricsSectionPlatform, color: Colors.purple),
        const SizedBox(height: 10),

        Row(children: [
          Expanded(
            child: _SimpleMetricCard(
              label:   AppLocalizations.of(context).adminMetricsEstablishments,
              value:   num.format(m.totalEstablishments),
              sub:     AppLocalizations.of(context).adminMetricsNewThisMonth('+${m.newEstablishments30d}'),
              icon:    Icons.storefront_rounded,
              color:   Colors.purple,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SimpleMetricCard(
              label:   AppLocalizations.of(context).adminMetricsActivePromos,
              value:   num.format(m.activePromotions),
              sub:     AppLocalizations.of(context).adminMetricsTotalCount(num.format(m.totalPromotions)),
              icon:    Icons.local_offer_rounded,
              color:   Colors.deepOrange,
            ),
          ),
        ]),
        const SizedBox(height: 20),

        // ── Lealtad / QR ──────────────────────────────────────────────────────
        _SectionHeader(icon: Icons.qr_code_scanner_rounded, title: AppLocalizations.of(context).adminMetricsSectionLoyaltyQr, color: Colors.teal),
        const SizedBox(height: 10),

        Row(children: [
          Expanded(
            child: _SimpleMetricCard(
              label:  AppLocalizations.of(context).adminMetricsTotalScans,
              value:  num.format(m.totalQrScans),
              sub:    AppLocalizations.of(context).adminMetricsLast30dValue(num.format(m.qrScans30d)),
              icon:   Icons.qr_code_rounded,
              color:  Colors.teal,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SimpleMetricCard(
              label:  AppLocalizations.of(context).adminMetricsAvgTicket,
              value:  mxn.format(m.avgTicket),
              sub:    '',
              icon:   Icons.receipt_rounded,
              color:  Colors.teal,
            ),
          ),
        ]),
        const SizedBox(height: 10),

        _PeriodCard(
          title: AppLocalizations.of(context).adminMetricsWaiterUploadedAmount,
          icon:  Icons.attach_money_rounded,
          color: Colors.teal,
          items: [
            _PeriodItem(AppLocalizations.of(context).adminMetricsPeriod30d,    mxn.format(m.ticketRevenue30d)),
            _PeriodItem(AppLocalizations.of(context).adminMetricsPeriodTotal,  mxn.format(m.totalTicketRevenue)),
          ],
        ),
        const SizedBox(height: 20),

        // ── Campañas ──────────────────────────────────────────────────────────
        _SectionHeader(icon: Icons.campaign_rounded, title: AppLocalizations.of(context).adminMetricsSectionCampaigns, color: Colors.amber.shade700),
        const SizedBox(height: 10),

        Row(children: [
          Expanded(
            child: _SimpleMetricCard(
              label:  AppLocalizations.of(context).adminMetricsActiveCampaigns,
              value:  num.format(m.activeCampaigns),
              sub:    AppLocalizations.of(context).adminMetricsTotalCount(num.format(m.totalCampaigns)),
              icon:   Icons.play_circle_rounded,
              color:  Colors.amber.shade700,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SimpleMetricCard(
              label:  AppLocalizations.of(context).adminMetricsCreditsSold,
              value:  mxn.format(m.creditsSold30d),
              sub:    AppLocalizations.of(context).adminMetricsLast30days,
              icon:   Icons.monetization_on_rounded,
              color:  Colors.amber.shade700,
            ),
          ),
        ]),
        const SizedBox(height: 10),

        _PeriodCard(
          title: AppLocalizations.of(context).adminMetricsCampaignSpend,
          icon:  Icons.bar_chart_rounded,
          color: Colors.amber.shade700,
          items: [
            _PeriodItem(AppLocalizations.of(context).adminMetricsPeriodToday, mxn.format(m.campaignSpendToday)),
            _PeriodItem(AppLocalizations.of(context).adminMetricsPeriod7d,    mxn.format(m.campaignSpend7d)),
            _PeriodItem(AppLocalizations.of(context).adminMetricsPeriod30d,   mxn.format(m.campaignSpend30d)),
          ],
        ),
        const SizedBox(height: 20),

        // ── Suscripciones ────────────────────────────────────────────────────
        _SectionHeader(icon: Icons.workspace_premium_rounded, title: AppLocalizations.of(context).adminMetricsSectionSubscriptions, color: AppColors.primary),
        const SizedBox(height: 10),

        Row(children: [
          Expanded(
            child: _SimpleMetricCard(
              label:  AppLocalizations.of(context).adminMetricsActiveSubscriptions,
              value:  num.format(m.activeSubscriptions),
              sub:    AppLocalizations.of(context).adminMetricsNewThisMonth('+${m.newSubscriptions30d}'),
              icon:   Icons.verified_rounded,
              color:  AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _SimpleMetricCard(
              label:  'MRR',
              value:  mxn.format(m.monthlyRevenue),
              sub:    AppLocalizations.of(context).adminMetricsMonthlyIncome,
              icon:   Icons.trending_up_rounded,
              color:  AppColors.primary,
            ),
          ),
        ]),
        const SizedBox(height: 20),

        // ── Rendimiento plataforma ───────────────────────────────────────────
        _SectionHeader(icon: Icons.insights_rounded, title: AppLocalizations.of(context).adminMetricsSectionPerformance, color: Colors.indigo),
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
          Text(AppLocalizations.of(context).adminMetricsRegisteredUsers, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 14),
          Row(children: [
            _RoleBadge(label: AppLocalizations.of(context).adminMetricsRoleUsers,    count: m.userCount,  color: Colors.blue.shade300),
            const SizedBox(width: 8),
            _RoleBadge(label: AppLocalizations.of(context).adminMetricsRoleStaff,    count: m.staffCount, color: Colors.green.shade400),
            const SizedBox(width: 8),
            _RoleBadge(label: AppLocalizations.of(context).adminMetricsRoleBusiness, count: m.ownerCount, color: AppColors.primary),
            const SizedBox(width: 8),
            _RoleBadge(label: AppLocalizations.of(context).adminMetricsRoleAdmin,    count: m.adminCount, color: Colors.red.shade400),
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
          Text(AppLocalizations.of(context).adminMetricsPlatformRevenue30d,
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(mxn.format(m.totalRevenue30d),
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(children: [
            _RevenueItem(AppLocalizations.of(context).adminMetricsRevenueSubscriptions, mxn.format(m.monthlyRevenue)),
            Container(width: 1, height: 40, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 12)),
            _RevenueItem(AppLocalizations.of(context).adminMetricsRevenueAdCredits,     mxn.format(m.creditsSold30d)),
            Container(width: 1, height: 40, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 12)),
            _RevenueItem(
              AppLocalizations.of(context).adminMetricsRevenueRoas,
              roasVal > 0 ? '${roasVal.toStringAsFixed(1)}x' : AppLocalizations.of(context).adminMetricsNotAvailable,
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
