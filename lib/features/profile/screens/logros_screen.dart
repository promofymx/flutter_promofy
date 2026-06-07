import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promofy/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_stats_model.dart';
import '../cubit/achievements_cubit.dart';
import '../cubit/achievements_state.dart';

/// Pantalla completa "Mis Logros": insignias, racha y top%.
class LogrosScreen extends StatelessWidget {
  final String userId;
  const LogrosScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AchievementsCubit(userId: userId)..load(),
      child: const _LogrosView(),
    );
  }
}

class _LogrosView extends StatelessWidget {
  const _LogrosView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          AppLocalizations.of(context).logrosTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<AchievementsCubit, AchievementsState>(
        builder: (context, state) {
          if (state is AchievementsLoading || state is AchievementsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AchievementsError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off_rounded,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).logrosLoadError,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () =>
                        context.read<AchievementsCubit>().load(),
                    child: Text(AppLocalizations.of(context).logrosRetry),
                  ),
                ],
              ),
            );
          }
          final stats =
              (state as AchievementsLoaded).stats;
          return _LogrosContent(stats: stats);
        },
      ),
    );
  }
}

class _LogrosContent extends StatelessWidget {
  final UserStatsModel stats;
  const _LogrosContent({required this.stats});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Insignia actual (grande) ──────────────────────────────────────
        _CurrentBadgeHero(stats: stats),
        const SizedBox(height: 20),

        // ── Barra de progreso ─────────────────────────────────────────────
        if (stats.nextBadge != null) ...[
          _ProgressSection(stats: stats),
          const SizedBox(height: 20),
        ],

        // ── Stats rápidos ─────────────────────────────────────────────────
        _QuickStatsRow(stats: stats),
        const SizedBox(height: 24),

        // ── Insignias anuales ─────────────────────────────────────────────
        _SectionTitle(AppLocalizations.of(context).logrosSectionVisits),
        const SizedBox(height: 12),
        ...BadgeTier.values.where((t) => t != BadgeTier.none).map(
          (tier) => _BadgeTile(
            emoji:     tier.emoji,
            label:     tier.label,
            subtitle:  AppLocalizations.of(context)
                .logrosAnnualVisits(tier.minVisits),
            desc:      tier.description,
            unlocked:  stats.annualVisits >= tier.minVisits,
            color:     tier.color,
          ),
        ),
        const SizedBox(height: 24),

        // ── Insignias de racha ────────────────────────────────────────────
        _SectionTitle(AppLocalizations.of(context).logrosSectionStreaks),
        const SizedBox(height: 12),
        ...StreakBadge.values.where((s) => s != StreakBadge.none).map(
          (sb) => _BadgeTile(
            emoji:    sb.emoji,
            label:    sb.label,
            subtitle: AppLocalizations.of(context)
                .logrosConsecutiveWeeks(sb.minWeeks),
            desc:     _streakDesc(context, sb),
            unlocked: stats.currentStreakWeeks >= sb.minWeeks,
            color:    sb.color,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  String _streakDesc(BuildContext context, StreakBadge sb) {
    final l10n = AppLocalizations.of(context);
    switch (sb) {
      case StreakBadge.enRacha:   return l10n.logrosStreakDescEnRacha;
      case StreakBadge.imparable: return l10n.logrosStreakDescImparable;
      case StreakBadge.leyenda:   return l10n.logrosStreakDescLeyenda;
      default:                    return '';
    }
  }
}

// ─── Hero de insignia actual ──────────────────────────────────────────────────

class _CurrentBadgeHero extends StatelessWidget {
  final UserStatsModel stats;
  const _CurrentBadgeHero({required this.stats});

  @override
  Widget build(BuildContext context) {
    final badge = stats.currentBadge;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            badge.color.withAlpha(30),
            badge.color.withAlpha(10),
          ],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badge.color.withAlpha(60)),
      ),
      child: Column(
        children: [
          Text(badge.emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 10),
          Text(
            badge.label,
            style: TextStyle(
              fontSize:   22,
              fontWeight: FontWeight.bold,
              color:      badge.color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color:    badge.color.withAlpha(200),
              height:   1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Barra de progreso al siguiente badge ─────────────────────────────────────

class _ProgressSection extends StatelessWidget {
  final UserStatsModel stats;
  const _ProgressSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final next     = stats.nextBadge!;
    final progress = stats.badgeProgress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(next.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).logrosNextLevel(next.label),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Text(
                '${stats.annualVisits} / ${next.minVisits}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: next.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value:            progress,
              minHeight:        10,
              backgroundColor:  next.color.withAlpha(25),
              valueColor:       AlwaysStoppedAnimation<Color>(next.color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)
                .logrosVisitsToGo(stats.visitsToNextBadge),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// ─── Fila de stats rápidos ────────────────────────────────────────────────────

class _QuickStatsRow extends StatelessWidget {
  final UserStatsModel stats;
  const _QuickStatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final streak = stats.streakBadge;
    final topPct = stats.topPercent;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            emoji: '📅',
            value: '${stats.annualVisits}',
            label: 'Visitas este año',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            emoji: streak == StreakBadge.none ? '💤' : streak.emoji,
            value: '${stats.currentStreakWeeks}',
            label: 'semanas en racha',
            color: streak.color,
          ),
        ),
        if (topPct != null) ...[
          const SizedBox(width: 10),
          Expanded(
            child: _StatCard(
              emoji: '📊',
              value: 'Top ${topPct.toStringAsFixed(0)}%',
              label: 'en tu ciudad',
              color: const Color(0xFF00897B),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color  color;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize:   18,
              fontWeight: FontWeight.bold,
              color:      color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// ─── Tile de insignia (desbloqueada / bloqueada) ──────────────────────────────

class _BadgeTile extends StatelessWidget {
  final String emoji;
  final String label;
  final String subtitle;
  final String desc;
  final bool   unlocked;
  final Color  color;

  const _BadgeTile({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.desc,
    required this.unlocked,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? color.withAlpha(12) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked ? color.withAlpha(60) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // Emoji / lock
          Container(
            width:  52,
            height: 52,
            decoration: BoxDecoration(
              color:  unlocked ? color.withAlpha(22) : Colors.grey.shade100,
              shape:  BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: unlocked
                ? Text(emoji, style: const TextStyle(fontSize: 26))
                : Icon(Icons.lock_outline_rounded,
                    size: 24, color: Colors.grey.shade400),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize:   14,
                          fontWeight: FontWeight.w700,
                          color: unlocked ? color : Colors.grey.shade500,
                        ),
                      ),
                    ),
                    if (unlocked)
                      Icon(Icons.check_circle_rounded,
                          size: 18, color: color),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: unlocked ? color.withAlpha(180) : Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    height:  1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Título de sección ────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize:   16,
        fontWeight: FontWeight.bold,
        color:      AppColors.textDark,
      ),
    );
  }
}
