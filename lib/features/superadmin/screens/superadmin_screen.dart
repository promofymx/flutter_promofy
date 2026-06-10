import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'admin_analytics_screen.dart';
import '../../../data/models/ad_pricing_model.dart';
import '../../../data/models/addon_pricing_model.dart';
import '../../../data/models/admin_establishment_entry.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/characteristic_model.dart';
import '../../../data/models/membership_plan_model.dart';
import '../../../data/models/notification_log_model.dart';
import '../../../data/models/staff_member_model.dart';
import '../../../data/datasources/supabase/promotions_datasource.dart';
import '../../../data/repositories/membership_plans_repository.dart';
import '../../../data/repositories/staff_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../cubit/superadmin_cubit.dart';
import '../cubit/superadmin_state.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/datasources/supabase/business_datasource.dart';
import 'package:promofy/l10n/app_localizations.dart';

// ─── Pantalla raíz ────────────────────────────────────────────────────────────

class SuperadminScreen extends StatelessWidget {
  const SuperadminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SuperadminCubit(repo: MembershipPlansRepository())..load(),
      child: const _SuperadminView(),
    );
  }
}

class _SuperadminView extends StatelessWidget {
  const _SuperadminView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).adminPanelTitle,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          BlocBuilder<SuperadminCubit, SuperadminState>(
            builder: (context, state) => IconButton(
              icon:    const Icon(Icons.refresh_outlined),
              tooltip: AppLocalizations.of(context).adminReload,
              onPressed: state is SuperadminLoading
                  ? null
                  : () => context.read<SuperadminCubit>().load(),
            ),
          ),
        ],
      ),
      body: BlocBuilder<SuperadminCubit, SuperadminState>(
        builder: (context, state) {
          if (state is SuperadminInitial || state is SuperadminLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is SuperadminError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(AppLocalizations.of(context).adminLoadError,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(state.message,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<SuperadminCubit>().load(),
                      child: Text(AppLocalizations.of(context).adminRetry),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is SuperadminLoaded) {
            return _Dashboard(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Dashboard con tiles ──────────────────────────────────────────────────────

class _Dashboard extends StatelessWidget {
  final SuperadminLoaded state;
  const _Dashboard({required this.state});

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: context.read<SuperadminCubit>(),
        child: screen,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).adminSectionTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
        ),
        const SizedBox(height: 16),

        _DashTile(
          icon:     Icons.insights_outlined,
          color:    const Color(0xFFF26522),
          title:    'Analítica',
          subtitle: 'Demografía, tipos de negocio y descargas',
          onTap:    () => _push(context, const AdminAnalyticsScreen()),
        ),
        const SizedBox(height: 12),

        _DashTile(
          icon:     Icons.workspace_premium_outlined,
          color:    const Color(0xFF1976D2),
          title:    AppLocalizations.of(context).adminTilePlans,
          subtitle: AppLocalizations.of(context).adminTilePlansSubtitle(state.plans.length),
          onTap:    () => _push(context, const _PlansScreen()),
        ),
        const SizedBox(height: 12),

        _DashTile(
          icon:     Icons.people_outline,
          color:    const Color(0xFF00897B),
          title:    AppLocalizations.of(context).adminTileOwners,
          subtitle: AppLocalizations.of(context).adminTileOwnersSubtitle(state.users.length),
          onTap:    () => _push(context, const _OwnersScreen()),
        ),
        const SizedBox(height: 12),

        _DashTile(
          icon:     Icons.category_outlined,
          color:    const Color(0xFFEF6C00),
          title:    AppLocalizations.of(context).adminTileCategories,
          subtitle: AppLocalizations.of(context).adminTileCategoriesSubtitle(state.categories.length),
          onTap:    () => _push(context, const _CategoriesScreen()),
        ),
        const SizedBox(height: 12),

        _DashTile(
          icon:     Icons.checklist_outlined,
          color:    const Color(0xFF6A1B9A),
          title:    AppLocalizations.of(context).adminTileCharacteristics,
          subtitle: AppLocalizations.of(context).adminTileCharacteristicsSubtitle(state.characteristics.length),
          onTap:    () => _push(context, const _CharacteristicsScreen()),
        ),
        const SizedBox(height: 12),

        _DashTile(
          icon:     Icons.notifications_outlined,
          color:    const Color(0xFFC62828),
          title:    AppLocalizations.of(context).adminTileNotifications,
          subtitle: AppLocalizations.of(context).adminTileNotificationsSubtitle(
              state.totalDevices, state.notificationLogs.length),
          onTap:    () => _push(context, const _NotificationsScreen()),
        ),
        const SizedBox(height: 12),

        _DashTile(
          icon:     Icons.manage_accounts_outlined,
          color:    const Color(0xFF37474F),
          title:    AppLocalizations.of(context).adminTileAllUsers,
          subtitle: AppLocalizations.of(context).adminTileAllUsersSubtitle,
          onTap:    () => _push(context, const _AllUsersScreen()),
        ),
        const SizedBox(height: 12),

        _DashTile(
          icon:     Icons.campaign_outlined,
          color:    const Color(0xFF00838F),
          title:    AppLocalizations.of(context).adminTileAds,
          subtitle: AppLocalizations.of(context).adminTileAdsSubtitle,
          onTap:    () => _push(context, const _AdPricingScreen()),
        ),
        const SizedBox(height: 12),

        _DashTile(
          icon:     Icons.account_balance_wallet_outlined,
          color:    const Color(0xFF00838F),
          title:    AppLocalizations.of(context).adminTileCredits,
          subtitle: AppLocalizations.of(context).adminTileCreditsSubtitle,
          onTap:    () => _push(context, const _AdCreditsScreen()),
        ),
        const SizedBox(height: 12),

        _DashTile(
          icon:     Icons.upload_file_outlined,
          color:    const Color(0xFF2E7D32),
          title:    AppLocalizations.of(context).adminTileBulk,
          subtitle: AppLocalizations.of(context).adminTileBulkSubtitle,
          onTap:    () => _push(context, const _BulkPromoUploadScreen()),
        ),
      ],
    );
  }
}

class _DashTile extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final String   title;
  final String   subtitle;
  final VoidCallback onTap;

  const _DashTile({
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
        padding:    const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(14),
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
              width: 48, height: 48,
              decoration: BoxDecoration(
                color:  color.withAlpha(25),
                shape:  BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark)),
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

// ═══════════════════════════════════════════════════════════════════════════════
// Sub-pantalla: Todos los usuarios
// ═══════════════════════════════════════════════════════════════════════════════

class _AllUsersScreen extends StatefulWidget {
  const _AllUsersScreen();
  @override
  State<_AllUsersScreen> createState() => _AllUsersScreenState();
}

class _AllUsersScreenState extends State<_AllUsersScreen> {
  final _repo     = StaffRepository();
  bool   _loading = true;
  String _query   = '';
  String _roleFilter = 'all'; // 'all' | 'user' | 'staff' | 'business_owner' | 'admin'
  List<AdminAllUserEntry> _users = [];

  static const _roleFilterKeys = [
    'all',
    'user',
    'staff',
    'business_owner',
    'admin',
  ];

  String _roleFilterLabel(BuildContext context, String key) {
    final l = AppLocalizations.of(context);
    switch (key) {
      case 'user':           return l.adminRoleFilterUsers;
      case 'staff':          return l.adminRoleFilterStaff;
      case 'business_owner': return l.adminRoleFilterOwners;
      case 'admin':          return l.adminRoleFilterAdmin;
      default:               return l.adminRoleFilterAll;
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _repo.getAllUsers();
      if (mounted) setState(() { _users = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(AdminAllUserEntry u) async {
    final newActive = !u.isActive || u.isBanned; // si estaba bloqueado → activar
    try {
      await _repo.setUserActive(u.id, active: newActive);
      setState(() {
        _users = _users.map((e) => e.id == u.id
            ? e.copyWith(isActive: newActive, isBanned: !newActive ? true : false)
            : e).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).adminErrorWithMsg(e.toString())),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  List<AdminAllUserEntry> get _filtered {
    var list = _roleFilter == 'all'
        ? _users
        : _users.where((u) => u.role == _roleFilter).toList();
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((u) =>
          u.displayName.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:           Text(AppLocalizations.of(context).adminAllUsersTitle),
        backgroundColor: Colors.white,
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh_outlined),
              onPressed: _load,
            ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText:   AppLocalizations.of(context).adminSearchNameEmail,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _query = ''),
                      )
                    : null,
                filled:     true,
                fillColor:  Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
          ),
          // Filtro por rol
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _roleFilterKeys.map((rf) {
                final selected = _roleFilter == rf;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label:     Text(_roleFilterLabel(context, rf)),
                    selected:  selected,
                    onSelected: (_) => setState(() => _roleFilter = rf),
                    selectedColor:    AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context).adminUserCount(filtered.length),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
          ),
          // Lista
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Text(AppLocalizations.of(context).adminNoResults,
                            style: TextStyle(color: Colors.grey.shade500)),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _AllUserRow(
                          user:     filtered[i],
                          onToggle: () => _toggle(filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _AllUserRow extends StatelessWidget {
  final AdminAllUserEntry user;
  final VoidCallback      onToggle;
  const _AllUserRow({required this.user, required this.onToggle});

  static const _roleColors = {
    'business_owner': Color(0xFF00897B),
    'admin':          Color(0xFFC62828),
    'staff':          Color(0xFF1976D2),
    'user':           Color(0xFF757575),
  };

  @override
  Widget build(BuildContext context) {
    final blocked   = user.isBlocked;
    final roleColor = _roleColors[user.role] ?? const Color(0xFF757575);
    final initials  = user.displayName.isNotEmpty
        ? user.displayName.trim().split(' ')
              .take(2).map((w) => w[0].toUpperCase()).join()
        : '?';

    return Container(
      padding:    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:       blocked
            ? Border.all(color: Colors.red.shade200)
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4, offset: const Offset(0,1)),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius:          20,
            backgroundColor: (blocked ? Colors.grey : roleColor).withAlpha(25),
            child: Text(initials,
                style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.bold,
                  color:      blocked ? Colors.grey : roleColor,
                )),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(user.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize:   14,
                            fontWeight: FontWeight.w600,
                            color:      blocked ? Colors.grey.shade500 : AppColors.textDark,
                          )),
                    ),
                    const SizedBox(width: 6),
                    _RolePill(label: user.roleLabel, color: roleColor),
                  ],
                ),
                const SizedBox(height: 2),
                Text(user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                if (blocked)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(
                      children: [
                        Icon(Icons.block, size: 11, color: Colors.red.shade400),
                        const SizedBox(width: 4),
                        Text(AppLocalizations.of(context).adminAccountDeactivated,
                            style: TextStyle(fontSize: 11, color: Colors.red.shade400)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Toggle activar/desactivar
          GestureDetector(
            onTap: () => _confirmToggle(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color:        (blocked ? Colors.green : Colors.red).withAlpha(15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (blocked ? Colors.green : Colors.red).withAlpha(60),
                ),
              ),
              child: Text(
                blocked
                    ? AppLocalizations.of(context).adminActivate
                    : AppLocalizations.of(context).adminDeactivate,
                style: TextStyle(
                  fontSize:   12,
                  fontWeight: FontWeight.w600,
                  color:      blocked ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmToggle(BuildContext context) {
    final blocked = user.isBlocked;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(blocked
            ? AppLocalizations.of(context).adminActivateAccount
            : AppLocalizations.of(context).adminDeactivateAccount),
        content: Text(blocked
            ? AppLocalizations.of(context).adminActivateAccountConfirm(user.displayName)
            : AppLocalizations.of(context).adminDeactivateAccountConfirm(user.displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).adminCancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: blocked ? Colors.green : Colors.red,
            ),
            onPressed: () { Navigator.pop(context); onToggle(); },
            child: Text(blocked
                ? AppLocalizations.of(context).adminActivate
                : AppLocalizations.of(context).adminDeactivate,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  final String label;
  final Color  color;
  const _RolePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color:        color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withAlpha(60)),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Sub-pantalla: Planes de membresía
// ═══════════════════════════════════════════════════════════════════════════════

class _PlansScreen extends StatelessWidget {
  const _PlansScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).adminPlansTitle),
        backgroundColor: Colors.white,
      ),
      body: BlocBuilder<SuperadminCubit, SuperadminState>(
        builder: (context, state) {
          if (state is! SuperadminLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Planes de membresía ──────────────────────────────────────
              for (final plan in state.plans) ...[
                _PlanCard(
                  plan:   plan,
                  onEdit: () => _showEditPlanSheet(context, plan),
                ),
                const SizedBox(height: 10),
              ],

              // ── Add-ons ──────────────────────────────────────────────────
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color:  const Color(0xFF7B1FA2).withAlpha(25),
                      shape:  BoxShape.circle,
                    ),
                    child: const Icon(Icons.extension_outlined,
                        size: 16, color: Color(0xFF7B1FA2)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context).adminAddons,
                    style: const TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.bold,
                      color:      AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                AppLocalizations.of(context).adminAddonsDesc,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 10),

              if (state.addonPricing.isEmpty)
                Container(
                  padding:    const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:        Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border:       Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.cloud_off_outlined,
                          size: 32, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).adminAddonTableMissing,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context).adminAddonRunSql,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                for (final addon in state.addonPricing) ...[
                  _AddonCard(
                    addon:  addon,
                    onEdit: () => _showEditAddonSheet(context, addon),
                  ),
                  const SizedBox(height: 10),
                ],
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  void _showEditAddonSheet(BuildContext context, AddonPricingModel addon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<SuperadminCubit>(),
        child: _EditAddonSheet(addon: addon),
      ),
    );
  }

  void _showEditPlanSheet(BuildContext context, MembershipPlanModel plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<SuperadminCubit>(),
        child: _EditPlanSheet(plan: plan),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Sub-pantalla: Dueños de negocio
// ═══════════════════════════════════════════════════════════════════════════════

class _OwnersScreen extends StatefulWidget {
  const _OwnersScreen();

  @override
  State<_OwnersScreen> createState() => _OwnersScreenState();
}

class _OwnersScreenState extends State<_OwnersScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:           Text(AppLocalizations.of(context).adminOwnersTitle),
        backgroundColor: Colors.white,
      ),
      body: BlocBuilder<SuperadminCubit, SuperadminState>(
        builder: (context, state) {
          if (state is! SuperadminLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final q = _query.toLowerCase();
          final filtered = _query.isEmpty
              ? state.users
              : state.users.where((u) =>
                  u.displayName.toLowerCase().contains(q) ||
                  u.email.toLowerCase().contains(q)).toList();

          return Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: TextField(
                  onChanged:   (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText:    AppLocalizations.of(context).adminSearchNameEmail,
                    prefixIcon:  const Icon(Icons.search, size: 20),
                    suffixIcon:  _query.isNotEmpty
                        ? IconButton(
                            icon:      const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _query = ''),
                          )
                        : null,
                    filled:      true,
                    fillColor:   Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context).adminResultCount(filtered.length),
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(AppLocalizations.of(context).adminNoResults,
                            style: TextStyle(color: Colors.grey.shade500)),
                      )
                    : ListView.separated(
                        padding:    const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount:  filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) => _UserRow(
                          user:     filtered[i],
                          plans:    state.plans,
                          onAssign: (planId) => context
                              .read<SuperadminCubit>()
                              .assignPlan(filtered[i].id, planId),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Sub-pantalla: Categorías
// ═══════════════════════════════════════════════════════════════════════════════

class _CategoriesScreen extends StatelessWidget {
  const _CategoriesScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:           Text(AppLocalizations.of(context).adminCategoriesTitle),
        backgroundColor: Colors.white,
        actions: [
          BlocBuilder<SuperadminCubit, SuperadminState>(
            builder: (context, state) => IconButton(
              icon:    const Icon(Icons.add),
              tooltip: AppLocalizations.of(context).adminNewRootType,
              onPressed: state is SuperadminLoaded
                  ? () => _showCategorySheet(context, null, state.categories)
                  : null,
            ),
          ),
        ],
      ),
      body: BlocBuilder<SuperadminCubit, SuperadminState>(
        builder: (context, state) {
          if (state is! SuperadminLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.categories.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context).adminNoCategories,
                  style: TextStyle(color: Colors.grey.shade500)),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: _buildTree(context, state.categories),
          );
        },
      ),
    );
  }

  List<Widget> _buildTree(
      BuildContext context, List<CategoryModel> all) {
    final widgets = <Widget>[];
    final roots   = all.where((c) => c.parentId == null).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    for (final root in roots) {
      widgets.add(_buildNode(context, root, all, 0));
      widgets.add(const SizedBox(height: 6));
    }
    return widgets;
  }

  Widget _buildNode(BuildContext context, CategoryModel cat,
      List<CategoryModel> all, int level) {
    final children = all.where((c) => c.parentId == cat.id).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final canAdd = level < 2;
    final l = AppLocalizations.of(context);
    final levelLabel = [l.adminLevelType, l.adminLevelSubtype, l.adminLevelSubSubtype][level];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: level * 20.0),
          child: _CatalogRow(
            icon:     cat.icon ?? '📂',
            name:     cat.name,
            subtitle: levelLabel,
            extraAction: canAdd
                ? IconButton(
                    icon:    const Icon(Icons.subdirectory_arrow_right, size: 18),
                    color:   AppColors.primary,
                    tooltip: l.adminAddSubcategory,
                    onPressed: () => _showCategorySheet(
                        context, null, all, parentId: cat.id),
                  )
                : null,
            onEdit: () => _showCategorySheet(context, cat, all),
            onDelete: () => _confirmDelete(
              context,
              title: l.adminDeleteCategory,
              body:  children.isNotEmpty
                  ? l.adminDeleteCategoryWithChildren(cat.name, children.length)
                  : l.adminDeleteCategorySimple(cat.name),
              onConfirm: () =>
                  context.read<SuperadminCubit>().deleteCategory(cat.id),
            ),
          ),
        ),
        for (final child in children) ...[
          const SizedBox(height: 4),
          _buildNode(context, child, all, level + 1),
        ],
      ],
    );
  }

  void _showCategorySheet(
    BuildContext context,
    CategoryModel? cat,
    List<CategoryModel> allCategories, {
    String? parentId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<SuperadminCubit>(),
        child: _EditCategorySheet(
          category:        cat,
          allCategories:   allCategories,
          initialParentId: parentId ?? cat?.parentId,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context,
      {required String title,
      required String body,
      required VoidCallback onConfirm}) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title:   Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(body, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppLocalizations.of(ctx).adminCancel)),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            child: Text(AppLocalizations.of(ctx).adminDelete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Sub-pantalla: Características
// ═══════════════════════════════════════════════════════════════════════════════

class _CharacteristicsScreen extends StatelessWidget {
  const _CharacteristicsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:           Text(AppLocalizations.of(context).adminCharacteristicsTitle),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon:    const Icon(Icons.add),
            tooltip: AppLocalizations.of(context).adminNewCharacteristic,
            onPressed: () => _showSheet(context, null),
          ),
        ],
      ),
      body: BlocBuilder<SuperadminCubit, SuperadminState>(
        builder: (context, state) {
          if (state is! SuperadminLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.characteristics.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context).adminNoCharacteristics,
                  style: TextStyle(color: Colors.grey.shade500)),
            );
          }
          return ListView.separated(
            padding:          const EdgeInsets.all(16),
            itemCount:        state.characteristics.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder:      (_, i) {
              final ch = state.characteristics[i];
              return _CatalogRow(
                icon:     ch.icon ?? '✅',
                name:     ch.name,
                onEdit:   () => _showSheet(context, ch),
                onDelete: () => _confirmDelete(
                  context,
                  title: AppLocalizations.of(context).adminDeleteCharacteristic,
                  body:  AppLocalizations.of(context).adminDeleteCharacteristicConfirm(ch.name),
                  onConfirm: () =>
                      context.read<SuperadminCubit>().deleteCharacteristic(ch.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showSheet(BuildContext context, CharacteristicModel? ch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<SuperadminCubit>(),
        child: _EditCharacteristicSheet(characteristic: ch),
      ),
    );
  }

  void _confirmDelete(BuildContext context,
      {required String title,
      required String body,
      required VoidCallback onConfirm}) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title:   Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(body, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppLocalizations.of(ctx).adminCancel)),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            child: Text(AppLocalizations.of(ctx).adminDelete,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Widgets compartidos
// ═══════════════════════════════════════════════════════════════════════════════

// ─── Encabezado de sección ────────────────────────────────────────────────────

// ─── Tarjeta de plan ──────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final MembershipPlanModel plan;
  final VoidCallback        onEdit;

  const _PlanCard({required this.plan, required this.onEdit});

  static const _planColors = <String, Color>{
    '1 Local':   Color(0xFF1976D2),
    '2 Locales': Color(0xFF00897B),
    '3 Locales': Color(0xFFEF6C00),
    '5 Locales': Color(0xFF6A1B9A),
  };

  @override
  Widget build(BuildContext context) {
    final color = _planColors[plan.name] ?? AppColors.primary;
    return Container(
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
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: color.withAlpha(25), shape: BoxShape.circle),
            child: Icon(Icons.workspace_premium, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.name,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: color)),
                const SizedBox(height: 2),
                Text(
                  plan.priceMxn == 0
                      ? AppLocalizations.of(context).adminFree
                      : AppLocalizations.of(context).adminPricePerMonth(plan.priceMxn.toStringAsFixed(0)),
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    _MiniChip(
                        AppLocalizations.of(context).adminBusinessCount(plan.maxEstablishments)),
                    _MiniChip(
                        AppLocalizations.of(context).adminPromoCount(plan.maxPromotions)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon:      const Icon(Icons.edit_outlined, size: 20),
            color:     Colors.grey.shade500,
            tooltip:   AppLocalizations.of(context).adminEditPlan,
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  const _MiniChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:        AppColors.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11,
              color:    AppColors.primary,
              fontWeight: FontWeight.w500)),
    );
  }
}

// ─── Tarjeta de add-on ────────────────────────────────────────────────────────

class _AddonCard extends StatelessWidget {
  final AddonPricingModel addon;
  final VoidCallback      onEdit;

  const _AddonCard({required this.addon, required this.onEdit});

  static const _addonColor = Color(0xFF7B1FA2);

  static const _typeIcons = <String, IconData>{
    'extra_establishment': Icons.add_business_outlined,
    'extra_promotion':     Icons.local_offer_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final icon = _typeIcons[addon.type] ?? Icons.extension_outlined;
    final fmtPrice = addon.priceMxn == 0
        ? AppLocalizations.of(context).adminFreeNoCharge
        : AppLocalizations.of(context).adminPricePerMonth(addon.priceMxn.toStringAsFixed(0));

    return Container(
      padding:    const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: _addonColor.withAlpha(50)),
        boxShadow: [
          BoxShadow(
              color:      Colors.black.withAlpha(10),
              blurRadius: 6,
              offset:     const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Ícono
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
                color: _addonColor.withAlpha(20), shape: BoxShape.circle),
            child: Icon(icon, color: _addonColor, size: 22),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(addon.label,
                    style: const TextStyle(
                        fontSize:   15,
                        fontWeight: FontWeight.bold,
                        color:      _addonColor)),
                if (addon.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(addon.description,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color:        _addonColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(fmtPrice,
                      style: const TextStyle(
                          fontSize:   12,
                          color:      _addonColor,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // Botón editar
          IconButton(
            onPressed: onEdit,
            icon:      const Icon(Icons.edit_outlined, size: 20),
            color:     Colors.grey.shade500,
            tooltip:   AppLocalizations.of(context).adminEditPrice,
          ),
        ],
      ),
    );
  }
}

// ─── Bottom sheet: editar add-on ──────────────────────────────────────────────

class _EditAddonSheet extends StatefulWidget {
  final AddonPricingModel addon;
  const _EditAddonSheet({required this.addon});

  @override
  State<_EditAddonSheet> createState() => _EditAddonSheetState();
}

class _EditAddonSheetState extends State<_EditAddonSheet> {
  late final TextEditingController _priceCtrl;
  bool    _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController(
        text: widget.addon.priceMxn.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final price = double.tryParse(_priceCtrl.text.replaceAll(',', '.'));
    if (price == null || price < 0) {
      setState(() => _error = AppLocalizations.of(context).adminInvalidPriceMin);
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      await context.read<SuperadminCubit>().updateAddonPricing(
        id:       widget.addon.id,
        priceMxn: price,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() { _saving = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left:   24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize:      MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color:        Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          // Título
          Row(
            children: [
              const Icon(Icons.extension_outlined,
                  size: 20, color: Color(0xFF7B1FA2)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(AppLocalizations.of(context).adminEditLabel(widget.addon.label),
                    style: const TextStyle(
                        fontSize:   17,
                        fontWeight: FontWeight.bold,
                        color:      AppColors.textDark)),
              ),
            ],
          ),
          if (widget.addon.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(widget.addon.description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
          const SizedBox(height: 20),
          // Campo precio
          TextFormField(
            controller:   _priceCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            decoration: InputDecoration(
              labelText:      AppLocalizations.of(context).adminMonthlyPricePerUnit,
              hintText:       AppLocalizations.of(context).adminNoAdditionalCharge,
              prefixText:     '\$ ',
              border:         OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).adminAddonZeroHint,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          // Error
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              width:      double.infinity,
              padding:    const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:        Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border:       Border.all(color: Colors.red.shade200),
              ),
              child: Text(_error!,
                  style: TextStyle(fontSize: 12, color: Colors.red.shade700)),
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : Text(AppLocalizations.of(context).adminSavePrice,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom sheet: editar plan ────────────────────────────────────────────────

class _EditPlanSheet extends StatefulWidget {
  final MembershipPlanModel plan;
  const _EditPlanSheet({required this.plan});

  @override
  State<_EditPlanSheet> createState() => _EditPlanSheetState();
}

class _EditPlanSheetState extends State<_EditPlanSheet> {
  late final TextEditingController _priceCtrl;
  late final TextEditingController _estCtrl;
  late final TextEditingController _promoCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController(
        text: widget.plan.priceMxn.toStringAsFixed(0));
    _estCtrl   = TextEditingController(
        text: widget.plan.maxEstablishments.toString());
    _promoCtrl = TextEditingController(
        text: widget.plan.maxPromotions.toString());
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _estCtrl.dispose();
    _promoCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final price = double.tryParse(_priceCtrl.text) ?? widget.plan.priceMxn;
    final est   = int.tryParse(_estCtrl.text)      ?? widget.plan.maxEstablishments;
    final promo = int.tryParse(_promoCtrl.text)    ?? widget.plan.maxPromotions;

    setState(() => _saving = true);
    await context.read<SuperadminCubit>().updatePlan(
      widget.plan.copyWith(
        priceMxn:          price,
        maxEstablishments: est,
        maxPromotions:     promo,
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left:   24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color:        Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context).adminEditPlanLabel(widget.plan.name),
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: 20),
          _FormField(label: AppLocalizations.of(context).adminPriceMxnMonth, ctrl: _priceCtrl,
              inputType: TextInputType.number, hint: AppLocalizations.of(context).adminZeroForFree),
          const SizedBox(height: 14),
          _FormField(label: AppLocalizations.of(context).adminMaxEstablishments, ctrl: _estCtrl,
              inputType: TextInputType.number),
          const SizedBox(height: 14),
          _FormField(label: AppLocalizations.of(context).adminMaxActivePromos, ctrl: _promoCtrl,
              inputType: TextInputType.number),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : Text(AppLocalizations.of(context).adminSaveChanges,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fila de usuario dueño ────────────────────────────────────────────────────

class _UserRow extends StatelessWidget {
  final AdminUserEntry            user;
  final List<MembershipPlanModel> plans;
  final void Function(int)        onAssign;

  const _UserRow({
    required this.user,
    required this.plans,
    required this.onAssign,
  });

  void _showPlanPicker(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(user.displayName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: plans
              .map((plan) => RadioListTile<int>(
                    dense:      true,
                    title:      Text(plan.name),
                    subtitle:   Text(
                      AppLocalizations.of(context).adminPlanPickerSubtitle(
                          plan.priceMxn.toStringAsFixed(0),
                          plan.maxEstablishments,
                          plan.maxPromotions),
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600),
                    ),
                    value:      plan.id,
                    groupValue: user.planId,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      Navigator.of(dialogCtx).pop();
                      if (val != null && val != user.planId) onAssign(val);
                    },
                  ))
              .toList(),
        ),
        contentPadding: const EdgeInsets.only(top: 12, bottom: 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark),
                    maxLines:  1,
                    overflow:  TextOverflow.ellipsis),
                if (user.email.isNotEmpty)
                  Text(
                    user.email,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  AppLocalizations.of(context).adminBusinessCount(user.estCount),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap:        () => _showPlanPicker(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color:        AppColors.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(20),
                border:       Border.all(color: AppColors.primary.withAlpha(60)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(user.planName,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_drop_down,
                      size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fila genérica de catálogo ────────────────────────────────────────────────

class _CatalogRow extends StatelessWidget {
  final String       icon;
  final String       name;
  final String?      subtitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Widget?      extraAction;

  const _CatalogRow({
    required this.icon,
    required this.name,
    this.subtitle,
    required this.onEdit,
    required this.onDelete,
    this.extraAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          if (extraAction != null) extraAction!,
          IconButton(
            icon:      const Icon(Icons.edit_outlined, size: 18),
            color:     Colors.grey.shade500,
            tooltip:   AppLocalizations.of(context).adminEdit,
            onPressed: onEdit,
          ),
          IconButton(
            icon:      const Icon(Icons.delete_outline, size: 18),
            color:     Colors.red.shade300,
            tooltip:   AppLocalizations.of(context).adminDelete,
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ─── Campo de formulario reutilizable ─────────────────────────────────────────

class _FormField extends StatelessWidget {
  final String                label;
  final TextEditingController ctrl;
  final TextInputType         inputType;
  final String?               hint;

  const _FormField({
    required this.label,
    required this.ctrl,
    required this.inputType,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller:   ctrl,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText:      label,
        hintText:       hint,
        border:         OutlineInputBorder(
            borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        isDense: true,
      ),
    );
  }
}

// ─── Bottom sheet: crear / editar categoría ──────────────────────────────────

class _EditCategorySheet extends StatefulWidget {
  final CategoryModel?      category;
  final List<CategoryModel> allCategories;
  final String?             initialParentId;

  const _EditCategorySheet({
    this.category,
    required this.allCategories,
    this.initialParentId,
  });

  @override
  State<_EditCategorySheet> createState() => _EditCategorySheetState();
}

class _EditCategorySheetState extends State<_EditCategorySheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _iconCtrl;
  String? _selectedParentId;
  bool    _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl         = TextEditingController(text: widget.category?.name ?? '');
    _iconCtrl         = TextEditingController(text: widget.category?.icon ?? '');
    // Al editar, priorizar el parentId de la categoría existente;
    // solo usar initialParentId al crear desde el árbol (sugerencia de padre).
    _selectedParentId = widget.category?.parentId ?? widget.initialParentId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  List<CategoryModel> get _validParents {
    final selfId = widget.category?.id;
    return widget.allCategories.where((c) {
      // Solo aplica los filtros anti-ciclo cuando estamos editando
      // (selfId != null). Al crear una nueva categoría, selfId es null
      // y la condición c.parentId == selfId excluiría erróneamente
      // a todas las categorías raíz (parentId == null).
      if (selfId != null && c.id == selfId) return false;
      if (selfId != null && c.parentId == selfId) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  String _levelLabel(BuildContext context, CategoryModel cat) {
    final l = AppLocalizations.of(context);
    if (cat.parentId == null) return l.adminLevelType;
    final gp = widget.allCategories
        .firstWhere((c) => c.id == cat.parentId, orElse: () => cat);
    return gp.parentId == null ? l.adminLevelSubtype : l.adminLevelSubSubtype;
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = AppLocalizations.of(context).adminNameEmpty);
      return;
    }
    final icon = _iconCtrl.text.trim().isEmpty ? null : _iconCtrl.text.trim();

    setState(() { _saving = true; _error = null; });
    try {
      final isNew       = widget.category == null;
      final clearParent = !isNew &&
          _selectedParentId == null &&
          widget.category!.parentId != null;

      if (isNew) {
        await context.read<SuperadminCubit>().createCategory(
            name: name, icon: icon, parentId: _selectedParentId);
      } else {
        await context.read<SuperadminCubit>().updateCategory(
            id:          widget.category!.id,
            name:        name,
            icon:        icon,
            parentId:    _selectedParentId,
            clearParent: clearParent);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() { _saving = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew   = widget.category == null;
    final parents = _validParents;

    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color:        Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(isNew ? AppLocalizations.of(context).adminNewCategory : AppLocalizations.of(context).adminEditCategory,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: 20),
          _FormField(label: AppLocalizations.of(context).adminNameRequired, ctrl: _nameCtrl,
              inputType: TextInputType.text),
          const SizedBox(height: 12),
          _FormField(label: AppLocalizations.of(context).adminEmojiIcon, ctrl: _iconCtrl,
              inputType: TextInputType.text, hint: '🍕'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            value:       _selectedParentId,
            isExpanded:  true,
            decoration: InputDecoration(
              labelText:      AppLocalizations.of(context).adminBelongsToParent,
              border:         OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              isDense: true,
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(AppLocalizations.of(context).adminNoParentRoot,
                    style: const TextStyle(color: Colors.grey)),
              ),
              ...parents.map((cat) => DropdownMenuItem<String?>(
                    value: cat.id,
                    child: Text(
                      '${cat.icon ?? '📂'} ${cat.name}  ·  ${_levelLabel(context, cat)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
            ],
            onChanged: (val) => setState(() => _selectedParentId = val),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:        Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border:       Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                _error!,
                style: TextStyle(fontSize: 12, color: Colors.red.shade700),
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : Text(isNew ? AppLocalizations.of(context).adminCreateCategory : AppLocalizations.of(context).adminSaveChanges,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom sheet: crear / editar característica ─────────────────────────────

class _EditCharacteristicSheet extends StatefulWidget {
  final CharacteristicModel? characteristic;
  const _EditCharacteristicSheet({this.characteristic});

  @override
  State<_EditCharacteristicSheet> createState() =>
      _EditCharacteristicSheetState();
}

class _EditCharacteristicSheetState extends State<_EditCharacteristicSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _iconCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.characteristic?.name ?? '');
    _iconCtrl = TextEditingController(text: widget.characteristic?.icon ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final icon = _iconCtrl.text.trim().isEmpty ? null : _iconCtrl.text.trim();

    setState(() => _saving = true);
    try {
      if (widget.characteristic == null) {
        await context
            .read<SuperadminCubit>()
            .createCharacteristic(name: name, icon: icon);
      } else {
        await context.read<SuperadminCubit>().updateCharacteristic(
            id: widget.characteristic!.id, name: name, icon: icon);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.characteristic == null;
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color:        Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(isNew ? AppLocalizations.of(context).adminNewCharacteristic : AppLocalizations.of(context).adminEditCharacteristic,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: 20),
          _FormField(label: AppLocalizations.of(context).adminNameRequired, ctrl: _nameCtrl,
              inputType: TextInputType.text),
          const SizedBox(height: 12),
          _FormField(label: AppLocalizations.of(context).adminEmojiIcon, ctrl: _iconCtrl,
              inputType: TextInputType.text, hint: '🅿️'),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white))
                  : Text(isNew ? AppLocalizations.of(context).adminCreateCharacteristic : AppLocalizations.of(context).adminSaveChanges,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Sub-pantalla: Notificaciones push  (4 tabs)
// ═══════════════════════════════════════════════════════════════════════════════

class _NotificationsScreen extends StatefulWidget {
  const _NotificationsScreen();

  @override
  State<_NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<_NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:           Text(AppLocalizations.of(context).adminNotificationsTitle),
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller:        _tab,
          labelColor:        AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor:    AppColors.primary,
          labelStyle:        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          tabs: [
            Tab(icon: const Icon(Icons.send, size: 18),        text: AppLocalizations.of(context).adminTabSend),
            Tab(icon: const Icon(Icons.schedule, size: 18),    text: AppLocalizations.of(context).adminTabScheduled),
            Tab(icon: const Icon(Icons.history, size: 18),     text: AppLocalizations.of(context).adminTabHistory),
            Tab(icon: const Icon(Icons.bar_chart, size: 18),   text: AppLocalizations.of(context).adminTabMetrics),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _SendTab(),
          _ScheduledTab(),
          _HistoryTab(),
          _MetricsTab(),
        ],
      ),
    );
  }
}

// ── Tab 1: Enviar ─────────────────────────────────────────────────────────────

class _SendTab extends StatefulWidget {
  const _SendTab();
  @override
  State<_SendTab> createState() => _SendTabState();
}

class _SendTabState extends State<_SendTab> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl  = TextEditingController();

  // Filtros de segmentación
  bool   _segmented     = false;
  String? _gender;          // null | 'male' | 'female' | 'prefer_not_to_say'
  int?   _ageMin;
  int?   _ageMax;
  int?   _inactiveDays;     // null | 7 | 15 | 30 | 60 | 90
  String? _platform;        // null | 'android' | 'ios' | 'web'

  int?   _recipientPreview;
  bool   _counting    = false;
  bool   _sending     = false;
  bool   _scheduling  = false;
  String? _lastResult;
  bool    _lastSuccess = true;

  final _ageMinCtrl = TextEditingController();
  final _ageMaxCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _ageMinCtrl.dispose();
    _ageMaxCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _filters {
    if (!_segmented) return {};
    return {
      if (_gender != null)       'gender':        _gender,
      if (_ageMin != null)       'age_min':       _ageMin,
      if (_ageMax != null)       'age_max':       _ageMax,
      if (_inactiveDays != null) 'inactive_days': _inactiveDays,
      if (_platform != null)     'platform':      _platform,
    };
  }

  Future<void> _previewCount() async {
    setState(() { _counting = true; _recipientPreview = null; });
    try {
      final count = await context.read<SuperadminCubit>().countRecipients(_filters);
      if (mounted) setState(() { _counting = false; _recipientPreview = count; });
    } catch (_) {
      if (mounted) setState(() => _counting = false);
    }
  }

  Future<void> _send() async {
    final title = _titleCtrl.text.trim();
    final body  = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).adminCompleteTitleBody)));
      return;
    }
    setState(() { _sending = true; _lastResult = null; });
    try {
      final result = await context.read<SuperadminCubit>().sendBroadcast(
        title:   title,
        body:    body,
        sentBy:  '',
        filters: _filters,
      );
      _titleCtrl.clear(); _bodyCtrl.clear();
      setState(() {
        _sending     = false;
        _lastSuccess = true;
        _lastResult  = result.failed > 0
            ? AppLocalizations.of(context).adminSentResultWithFailed(result.sent, result.failed)
            : AppLocalizations.of(context).adminSentResult(result.sent);
      });
    } catch (e) {
      setState(() { _sending = false; _lastSuccess = false;
        _lastResult = AppLocalizations.of(context).adminSendErrorResult(e.toString()); });
    }
  }

  Future<void> _openScheduleDialog() async {
    final title = _titleCtrl.text.trim();
    final body  = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).adminCompleteTitleBodyBeforeSchedule)));
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<SuperadminCubit>(),
        child: _ScheduleDialog(
          title:   title,
          body:    body,
          filters: _filters,
          onScheduled: () {
            _titleCtrl.clear(); _bodyCtrl.clear();
            setState(() {
              _lastSuccess = true;
              _lastResult  = AppLocalizations.of(context).adminScheduledOk;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SuperadminCubit, SuperadminState>(
      builder: (context, state) {
        if (state is! SuperadminLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Stats rápidos ────────────────────────────────────────────────
            Row(
              children: [
                _StatChip(icon: Icons.phone_android, label: 'Android',
                    count: state.deviceStats['android'] ?? 0, color: const Color(0xFF00897B)),
                const SizedBox(width: 8),
                _StatChip(icon: Icons.phone_iphone,  label: 'iOS',
                    count: state.deviceStats['ios']     ?? 0, color: const Color(0xFF1976D2)),
                const SizedBox(width: 8),
                _StatChip(icon: Icons.web,            label: 'Web',
                    count: state.deviceStats['web']     ?? 0, color: const Color(0xFF6A1B9A)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 16),
              child: Text(AppLocalizations.of(context).adminTotalDevices(state.totalDevices),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ),

            // ── Mensaje ───────────────────────────────────────────────────────
            _Card(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label(AppLocalizations.of(context).adminTitleRequired),
                const SizedBox(height: 6),
                TextField(
                  controller:  _titleCtrl,
                  maxLength:   80,
                  decoration:  _inputDeco(AppLocalizations.of(context).adminTitleHint),
                ),
                const SizedBox(height: 10),
                _Label(AppLocalizations.of(context).adminMessageRequired),
                const SizedBox(height: 6),
                TextField(
                  controller:   _bodyCtrl,
                  maxLines:     3,
                  maxLength:    200,
                  decoration:   _inputDeco(AppLocalizations.of(context).adminBodyHint),
                  keyboardType: TextInputType.multiline,
                ),
              ],
            )),
            const SizedBox(height: 12),

            // ── Segmentación ─────────────────────────────────────────────────
            _Card(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.filter_list, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(child: _Label(AppLocalizations.of(context).adminSegmentRecipients)),
                    Switch.adaptive(
                      value:       _segmented,
                      activeColor: AppColors.primary,
                      onChanged:   (v) => setState(() {
                        _segmented        = v;
                        _recipientPreview = null;
                      }),
                    ),
                  ],
                ),
                if (_segmented) ...[
                  const Divider(height: 20),

                  // Género
                  _Label(AppLocalizations.of(context).adminGender),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String?>(
                    value:       _gender,
                    isExpanded:  true,
                    decoration:  _fieldDeco(AppLocalizations.of(context).adminAllGenders),
                    items: [
                      DropdownMenuItem(value: null,                child: Text(AppLocalizations.of(context).adminAll)),
                      DropdownMenuItem(value: 'male',             child: Text(AppLocalizations.of(context).adminMen)),
                      DropdownMenuItem(value: 'female',           child: Text(AppLocalizations.of(context).adminWomen)),
                      DropdownMenuItem(value: 'prefer_not_to_say',child: Text(AppLocalizations.of(context).adminPreferNotToSay)),
                    ],
                    onChanged: (v) => setState(() { _gender = v; _recipientPreview = null; }),
                  ),
                  const SizedBox(height: 12),

                  // Edad
                  _Label(AppLocalizations.of(context).adminAgeRange),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: TextField(
                        controller:  _ageMinCtrl,
                        keyboardType: TextInputType.number,
                        decoration:  _inputDeco(AppLocalizations.of(context).adminMin),
                        onChanged: (v) => setState(() {
                          _ageMin = int.tryParse(v);
                          _recipientPreview = null;
                        }),
                      )),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child:   Text('–', style: TextStyle(color: Colors.grey, fontSize: 18)),
                      ),
                      Expanded(child: TextField(
                        controller:  _ageMaxCtrl,
                        keyboardType: TextInputType.number,
                        decoration:  _inputDeco(AppLocalizations.of(context).adminMax),
                        onChanged: (v) => setState(() {
                          _ageMax = int.tryParse(v);
                          _recipientPreview = null;
                        }),
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Inactividad
                  _Label(AppLocalizations.of(context).adminInactiveUsersSince),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int?>(
                    value:       _inactiveDays,
                    isExpanded:  true,
                    decoration:  _fieldDeco(AppLocalizations.of(context).adminNoFilter),
                    items: [
                      DropdownMenuItem(value: null, child: Text(AppLocalizations.of(context).adminNoFilter)),
                      DropdownMenuItem(value: 7,    child: Text(AppLocalizations.of(context).adminDays7)),
                      DropdownMenuItem(value: 15,   child: Text(AppLocalizations.of(context).adminDays15)),
                      DropdownMenuItem(value: 30,   child: Text(AppLocalizations.of(context).adminDays30)),
                      DropdownMenuItem(value: 60,   child: Text(AppLocalizations.of(context).adminDays60)),
                      DropdownMenuItem(value: 90,   child: Text(AppLocalizations.of(context).adminDays90Plus)),
                    ],
                    onChanged: (v) => setState(() { _inactiveDays = v; _recipientPreview = null; }),
                  ),
                  const SizedBox(height: 12),

                  // Plataforma
                  _Label(AppLocalizations.of(context).adminPlatform),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String?>(
                    value:       _platform,
                    isExpanded:  true,
                    decoration:  _fieldDeco(AppLocalizations.of(context).adminAllFem),
                    items: [
                      DropdownMenuItem(value: null,      child: Text(AppLocalizations.of(context).adminAllFem)),
                      const DropdownMenuItem(value: 'android', child: Text('Android')),
                      const DropdownMenuItem(value: 'ios',     child: Text('iOS')),
                      const DropdownMenuItem(value: 'web',     child: Text('Web')),
                    ],
                    onChanged: (v) => setState(() { _platform = v; _recipientPreview = null; }),
                  ),
                  const SizedBox(height: 14),

                  // Preview de destinatarios
                  OutlinedButton.icon(
                    onPressed: _counting ? null : _previewCount,
                    icon:  _counting
                        ? const SizedBox(width: 14, height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.people_outline, size: 16),
                    label: Text(_counting
                        ? AppLocalizations.of(context).adminCalculating
                        : _recipientPreview != null
                            ? AppLocalizations.of(context).adminRecipientsApprox(_recipientPreview!)
                            : AppLocalizations.of(context).adminEstimateRecipients),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      minimumSize: const Size(double.infinity, 40),
                    ),
                  ),
                ],
              ],
            )),
            const SizedBox(height: 12),

            if (_lastResult != null)
              Container(
                padding:    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color:        _lastSuccess ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_lastResult!,
                    style: TextStyle(fontSize: 12,
                        color: _lastSuccess ? Colors.green.shade700 : Colors.red.shade700)),
              ),
            const SizedBox(height: 12),

            // ── Botones acción ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: (_sending || _scheduling) ? null : _openScheduleDialog,
                  icon:  const Icon(Icons.schedule, size: 18),
                  label: Text(AppLocalizations.of(context).adminSchedule, style: const TextStyle(fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton.icon(
                  onPressed: (_sending || _scheduling) ? null : _send,
                  icon: _sending
                      ? const SizedBox(width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send, size: 18),
                  label: Text(_sending ? AppLocalizations.of(context).adminSending : AppLocalizations.of(context).adminSendNow,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )),
              ],
            ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

// ── Tab 2: Programadas ────────────────────────────────────────────────────────

class _ScheduledTab extends StatelessWidget {
  const _ScheduledTab();

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy  HH:mm', 'es_MX');

    return BlocBuilder<SuperadminCubit, SuperadminState>(
      builder: (context, state) {
        if (state is! SuperadminLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = state.scheduledNotifications;
        return list.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 52, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(AppLocalizations.of(context).adminNoScheduled,
                        style: TextStyle(color: Colors.grey.shade500)),
                    const SizedBox(height: 6),
                    Text(AppLocalizations.of(context).adminNoScheduledHint,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                  ],
                ),
              )
            : ListView.separated(
                padding:          const EdgeInsets.all(16),
                itemCount:        list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final s = list[i];
                  return Container(
                    padding:    const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:        Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(
                          color: Colors.black.withAlpha(8), blurRadius: 4)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          _Pill(
                            label: s.recurrenceLabel,
                            color: s.isRecurring
                                ? Colors.purple
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          _Pill(label: s.statusLabel, color: Colors.grey.shade600),
                          const Spacer(),
                          if (s.isPending)
                            IconButton(
                              icon:    const Icon(Icons.cancel_outlined,
                                  size: 20, color: Colors.red),
                              tooltip: AppLocalizations.of(context).adminCancel,
                              onPressed: () => context
                                  .read<SuperadminCubit>()
                                  .cancelScheduled(s.id),
                            ),
                        ]),
                        const SizedBox(height: 6),
                        Text(s.title,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark)),
                        const SizedBox(height: 2),
                        Text(s.body,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            s.nextSendAt != null
                                ? AppLocalizations.of(context).adminNextSend(fmt.format(s.nextSendAt!))
                                : fmt.format(s.sendAt),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500),
                          ),
                          if (s.runCount > 0) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.check_circle_outline,
                                size: 13, color: Colors.green.shade600),
                            const SizedBox(width: 4),
                            Text(AppLocalizations.of(context).adminRunCount(s.runCount),
                                style: TextStyle(
                                    fontSize: 11, color: Colors.green.shade600)),
                          ],
                        ]),
                      ],
                    ),
                  );
                },
              );
      },
    );
  }
}

// ── Tab 3: Historial ──────────────────────────────────────────────────────────

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy  HH:mm', 'es_MX');

    return BlocBuilder<SuperadminCubit, SuperadminState>(
      builder: (context, state) {
        if (state is! SuperadminLoaded) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.notificationLogs.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context).adminNoSends,
                style: TextStyle(color: Colors.grey.shade500)),
          );
        }
        return ListView.separated(
          padding:          const EdgeInsets.all(16),
          itemCount:        state.notificationLogs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) =>
              _LogCard(log: state.notificationLogs[i], fmt: fmt),
        );
      },
    );
  }
}

// ── Tab 4: Métricas ───────────────────────────────────────────────────────────

class _MetricsTab extends StatelessWidget {
  const _MetricsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SuperadminCubit, SuperadminState>(
      builder: (context, state) {
        if (state is! SuperadminLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── KPIs ─────────────────────────────────────────────────────────
            Row(children: [
              _KpiCard(
                label:  AppLocalizations.of(context).adminTotalSent,
                value:  '${state.totalSentAll}',
                icon:   Icons.send,
                color:  AppColors.primary,
              ),
              const SizedBox(width: 10),
              _KpiCard(
                label:  AppLocalizations.of(context).adminAvgDelivery,
                value:  '${state.avgDeliveryRate.toStringAsFixed(1)}%',
                icon:   Icons.check_circle_outline,
                color:  Colors.green.shade700,
              ),
              const SizedBox(width: 10),
              _KpiCard(
                label:  AppLocalizations.of(context).adminAvgOpen,
                value:  '${state.avgOpenRate.toStringAsFixed(1)}%',
                icon:   Icons.touch_app_outlined,
                color:  Colors.orange.shade700,
              ),
            ]),
            const SizedBox(height: 20),

            // ── Gráfica de barras (últimos 30 días) ───────────────────────────
            if (state.dailyStats.isNotEmpty)
              _Card(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label(AppLocalizations.of(context).adminDailySends30),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 160,
                    child: _DailyBarChart(dailyStats: state.dailyStats),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Container(width: 12, height: 12,
                        decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(180),
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 4),
                    Text(AppLocalizations.of(context).adminLegendSent, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    const SizedBox(width: 12),
                    Container(width: 12, height: 12,
                        decoration: BoxDecoration(
                            color: Colors.orange.withAlpha(180),
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 4),
                    Text(AppLocalizations.of(context).adminLegendOpens, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ]),
                ],
              )),
            if (state.dailyStats.isEmpty)
              _Card(child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(AppLocalizations.of(context).adminNoSendData,
                      style: TextStyle(color: Colors.grey.shade500)),
                ),
              )),

            const SizedBox(height: 20),

            // ── Plataformas ───────────────────────────────────────────────────
            _Card(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label(AppLocalizations.of(context).adminDevicesByPlatform),
                const SizedBox(height: 12),
                Row(children: [
                  _StatChip(icon: Icons.phone_android, label: 'Android',
                      count: state.deviceStats['android'] ?? 0,
                      color: const Color(0xFF00897B)),
                  const SizedBox(width: 8),
                  _StatChip(icon: Icons.phone_iphone, label: 'iOS',
                      count: state.deviceStats['ios'] ?? 0,
                      color: const Color(0xFF1976D2)),
                  const SizedBox(width: 8),
                  _StatChip(icon: Icons.web, label: 'Web',
                      count: state.deviceStats['web'] ?? 0,
                      color: const Color(0xFF6A1B9A)),
                ]),
              ],
            )),
            const SizedBox(height: 20),

            // ── Tabla de últimas notificaciones con tasa ──────────────────────
            if (state.notificationLogs.isNotEmpty)
              _Card(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Label(AppLocalizations.of(context).adminLatestNotifications),
                  const SizedBox(height: 10),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.grey.shade200))),
                        children: [
                          _Th(AppLocalizations.of(context).adminColNotification),
                          _Th(AppLocalizations.of(context).adminColDelivery),
                          _Th(AppLocalizations.of(context).adminColOpen),
                        ],
                      ),
                      for (final log in state.notificationLogs.take(10))
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(log.title,
                                style: const TextStyle(fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              '${log.deliveryRate.toStringAsFixed(0)}%',
                              style: TextStyle(
                                  fontSize: 11,
                                  color:    log.deliveryRate >= 90
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              log.sentCount > 0
                                  ? '${log.openRate.toStringAsFixed(1)}%'
                                  : '—',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey.shade700),
                            ),
                          ),
                        ]),
                    ],
                  ),
                ],
              )),

            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

// ── Diálogo: programar notificación ──────────────────────────────────────────

class _ScheduleDialog extends StatefulWidget {
  final String               title;
  final String               body;
  final Map<String, dynamic> filters;
  final VoidCallback         onScheduled;

  const _ScheduleDialog({
    required this.title,
    required this.body,
    required this.filters,
    required this.onScheduled,
  });

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  DateTime? _sendAt;
  String?   _recurrence;  // null | 'daily' | 'weekly' | 'monthly'
  bool      _saving = false;

  static const _months = [
    '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  String _fmtDt(DateTime dt) =>
      '${dt.day} ${_months[dt.month]} ${dt.year}  '
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDateTime() async {
    final now  = DateTime.now();
    final date = await showDatePicker(
      context:     context,
      initialDate: _sendAt ?? now.add(const Duration(hours: 1)),
      firstDate:   now,
      lastDate:    now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context:     context,
      initialTime: _sendAt != null
          ? TimeOfDay.fromDateTime(_sendAt!)
          : TimeOfDay(hour: now.hour + 1, minute: 0),
    );
    if (time == null || !mounted) return;
    setState(() {
      _sendAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (_sendAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).adminPickDateTime)));
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<SuperadminCubit>().createScheduled(
        title:      widget.title,
        body:       widget.body,
        sendAt:     _sendAt!,
        recurrence: _recurrence,
        filters:    widget.filters,
      );
      if (mounted) {
        Navigator.of(context).pop();
        widget.onScheduled();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).adminErrorWithMsg(e.toString()))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).adminScheduleNotification,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview del mensaje
          Container(
            padding:    const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
                Text(widget.body,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Fecha y hora
          Text(AppLocalizations.of(context).adminSendDateTime,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickDateTime,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(
                    color: _sendAt != null
                        ? AppColors.primary
                        : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                Icon(Icons.calendar_today_outlined,
                    size: 16,
                    color: _sendAt != null
                        ? AppColors.primary
                        : Colors.grey.shade400),
                const SizedBox(width: 8),
                Text(
                  _sendAt != null ? _fmtDt(_sendAt!) : AppLocalizations.of(context).adminSelect,
                  style: TextStyle(
                      fontSize: 13,
                      color: _sendAt != null
                          ? AppColors.textDark
                          : Colors.grey.shade400),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 14),

          // Recurrencia
          Text(AppLocalizations.of(context).adminRepetition,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String?>(
            value:       _recurrence,
            isExpanded:  true,
            decoration:  _fieldDeco(AppLocalizations.of(context).adminOnceOnly),
            items: [
              DropdownMenuItem(value: null,      child: Text(AppLocalizations.of(context).adminOnceOnly)),
              DropdownMenuItem(value: 'daily',   child: Text(AppLocalizations.of(context).adminDaily)),
              DropdownMenuItem(value: 'weekly',  child: Text(AppLocalizations.of(context).adminWeekly)),
              DropdownMenuItem(value: 'monthly', child: Text(AppLocalizations.of(context).adminMonthly)),
            ],
            onChanged: (v) => setState(() => _recurrence = v),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).adminCancel),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(AppLocalizations.of(context).adminSchedule),
        ),
      ],
    );
  }
}

// ─── Gráfica de barras diarias ─────────────────────────────────────────────────

class _DailyBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> dailyStats;
  const _DailyBarChart({required this.dailyStats});

  @override
  Widget build(BuildContext context) {
    final maxVal = dailyStats.fold<double>(1, (m, e) {
      final s = ((e['sent_count'] as num?)?.toDouble() ?? 0);
      return s > m ? s : m;
    });

    final groups = dailyStats.asMap().entries.map((entry) {
      final i   = entry.key;
      final row = entry.value;
      final s   = ((row['sent_count'] as num?)?.toDouble() ?? 0);
      final o   = ((row['open_count'] as num?)?.toDouble() ?? 0);
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
              toY: s,
              color: AppColors.primary.withAlpha(180),
              width: 6, borderRadius: BorderRadius.circular(2)),
          BarChartRodData(
              toY: o,
              color: Colors.orange.withAlpha(180),
              width: 6, borderRadius: BorderRadius.circular(2)),
        ],
        barsSpace: 2,
      );
    }).toList();

    return BarChart(BarChartData(
      maxY:            maxVal * 1.2,
      barGroups:       groups,
      gridData:        FlGridData(
        drawVerticalLine: false,
        horizontalInterval: maxVal / 4,
        getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.grey.shade200, strokeWidth: 1),
      ),
      borderData:      FlBorderData(show: false),
      titlesData:      FlTitlesData(
        leftTitles:    AxisTitles(sideTitles: SideTitles(
            showTitles: true, reservedSize: 28,
            getTitlesWidget: (v, _) => Text(
                v.toInt().toString(),
                style: const TextStyle(fontSize: 9, color: Colors.grey)))),
        bottomTitles:  AxisTitles(sideTitles: SideTitles(
            showTitles: true, reservedSize: 20,
            interval: dailyStats.length > 14 ? 7 : 3,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i >= dailyStats.length) return const SizedBox();
              final raw = dailyStats[i]['day'];
              DateTime? d;
              if (raw is DateTime) d = raw;
              else if (raw is String) d = DateTime.tryParse(raw);
              if (d == null) return const SizedBox();
              return Text('${d.day}/${d.month}',
                  style: const TextStyle(fontSize: 9, color: Colors.grey));
            })),
        topTitles:     const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, _, rod, rodIndex) {
            return BarTooltipItem(
              rod.toY.toInt().toString(),
              TextStyle(
                color: rodIndex == 0 ? AppColors.primary : Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          },
        ),
      ),
    ));
  }
}

// ─── Widgets helper de métricas ───────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final String   label;
  final String   value;
  final IconData icon;
  final Color    color;
  const _KpiCard({required this.label, required this.value,
      required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4)],
        ),
        child: Column(children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

Widget _Th(String text) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 4),
  child:   Text(text,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600)),
);

class _Pill extends StatelessWidget {
  final String label;
  final Color  color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color:        color.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(color: color.withAlpha(60))),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Chip de estadística ──────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final int      count;
  final Color    color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color:        color.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
          border:       Border.all(color: color.withAlpha(50)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(count.toString(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label,
              style: TextStyle(fontSize: 11, color: color.withAlpha(200))),
        ]),
      ),
    );
  }
}

// ─── Tarjeta de historial ─────────────────────────────────────────────────────

class _LogCard extends StatelessWidget {
  final NotificationLogModel log;
  final DateFormat           fmt;
  const _LogCard({required this.log, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _Pill(label: log.targetLabel, color: AppColors.primary),
            const Spacer(),
            Text(fmt.format(log.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          ]),
          const SizedBox(height: 8),
          Text(log.title,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(log.body,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          // Métricas en línea
          Row(children: [
            _MiniStat(Icons.check_circle_outline, '${log.sentCount}',
                Colors.green.shade700, AppLocalizations.of(context).adminDelivered),
            if (log.failedCount > 0) ...[
              const SizedBox(width: 12),
              _MiniStat(Icons.error_outline, '${log.failedCount}',
                  Colors.orange.shade700, AppLocalizations.of(context).adminFailed),
            ],
            const SizedBox(width: 12),
            _MiniStat(Icons.touch_app_outlined, '${log.openRate.toStringAsFixed(1)}%',
                Colors.blue.shade700, AppLocalizations.of(context).adminOpenStat),
            const SizedBox(width: 12),
            _MiniStat(Icons.local_shipping_outlined,
                '${log.deliveryRate.toStringAsFixed(0)}%',
                Colors.green.shade700, AppLocalizations.of(context).adminDeliveryStat),
          ]),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String   value;
  final Color    color;
  final String   label;
  const _MiniStat(this.icon, this.value, this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 3),
      Text('$value $label',
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
    ]);
  }
}

// ─── Helpers de formulario reutilizados en esta pantalla ─────────────────────

// ─── Tarjeta contenedora ──────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:   double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}

// ─── Etiqueta de campo ────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
    );
  }
}

// ─── Decoraciones de input ────────────────────────────────────────────────────

InputDecoration _fieldDeco(String hint) => InputDecoration(
  hintText:       hint,
  border:         OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  isDense:        true,
);

InputDecoration _inputDeco(String hint) => InputDecoration(
  hintText:        hint,
  filled:          true,
  fillColor:       Colors.grey.shade50,
  contentPadding:  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  border:          OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:   BorderSide(color: Colors.grey.shade300)),
  enabledBorder:   OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:   BorderSide(color: Colors.grey.shade300)),
  focusedBorder:   OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:   const BorderSide(color: AppColors.primary)),
  counterStyle:    const TextStyle(fontSize: 11),
);

// ─── Publicidad — precios por formato ────────────────────────────────────────

class _AdPricingScreen extends StatelessWidget {
  const _AdPricingScreen();

  static const _formatIcons = <String, IconData>{
    'splash':        Icons.fullscreen_outlined,
    'featured_list': Icons.star_outline,
    'banner':        Icons.view_agenda_outlined,
    'push':          Icons.notifications_outlined,
    'flash':         Icons.bolt_outlined,
  };

  static const _formatColors = <String, Color>{
    'splash':        Color(0xFF6A1B9A),
    'featured_list': Color(0xFFF57F17),
    'banner':        Color(0xFF1565C0),
    'push':          Color(0xFFC62828),
    'flash':         Color(0xFF00695C),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.campaign_outlined, color: Color(0xFF00838F), size: 22),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).adminAdsPricesTitle,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: BlocBuilder<SuperadminCubit, SuperadminState>(
        builder: (context, state) {
          if (state is! SuperadminLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.adPricing.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(AppLocalizations.of(context).adminNoPriceData,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).adminRunAdsSql,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.read<SuperadminCubit>().load(),
                    icon: const Icon(Icons.refresh),
                    label: Text(AppLocalizations.of(context).adminRetry),
                  ),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Encabezado informativo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00838F).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF00838F).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(AppLocalizations.of(context).adminPricesByFormat,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00838F).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.people_outline,
                                  size: 14, color: Color(0xFF00838F)),
                              const SizedBox(width: 4),
                              Text(AppLocalizations.of(context).adminUsersCount(state.totalUserCount),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF00838F),
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(context).adminBillingUnitInfo,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Lista de formatos
              ...state.adPricing.map((pricing) {
                final icon  = _formatIcons[pricing.format]  ?? Icons.campaign_outlined;
                final color = _formatColors[pricing.format] ?? const Color(0xFF00838F);
                final fmt   = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Ícono
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: color, size: 22),
                          ),
                          const SizedBox(width: 14),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pricing.label,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(pricing.billingTypeLabel(state.totalUserCount),
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _PriceBadge(
                                      label: pricing.billingTypeLabel(state.totalUserCount),
                                      value: fmt.format(pricing.priceMxn),
                                      color: color,
                                    ),
                                    const SizedBox(width: 8),
                                    _PriceBadge(
                                      label: AppLocalizations.of(context).adminMinCampaign,
                                      value: fmt.format(pricing.minBudgetMxn),
                                      color: Colors.grey.shade600,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Editar
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            color: Colors.grey.shade600,
                            tooltip: AppLocalizations.of(context).adminEditPrice,
                            onPressed: () => _showEditSheet(context, pricing, state.totalUserCount),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  void _showEditSheet(BuildContext context, AdPricingModel pricing, int totalUserCount) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<SuperadminCubit>(),
        child: _EditAdPricingSheet(pricing: pricing, totalUserCount: totalUserCount),
      ),
    );
  }
}

// ── Badge de precio ────────────────────────────────────────────────────────────

class _PriceBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color  color;

  const _PriceBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── Hoja de edición de precio ─────────────────────────────────────────────────

class _EditAdPricingSheet extends StatefulWidget {
  final AdPricingModel pricing;
  final int totalUserCount;
  const _EditAdPricingSheet({required this.pricing, required this.totalUserCount});

  @override
  State<_EditAdPricingSheet> createState() => _EditAdPricingSheetState();
}

class _EditAdPricingSheetState extends State<_EditAdPricingSheet> {
  late final TextEditingController _priceCtrl;
  late final TextEditingController _minBudgetCtrl;
  bool    _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _priceCtrl     = TextEditingController(
        text: widget.pricing.priceMxn.toStringAsFixed(2));
    _minBudgetCtrl = TextEditingController(
        text: widget.pricing.minBudgetMxn.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _minBudgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final price     = double.tryParse(_priceCtrl.text.replaceAll(',', '.'));
    final minBudget = double.tryParse(_minBudgetCtrl.text.replaceAll(',', '.'));
    if (price == null || price < 0) {
      setState(() => _error = AppLocalizations.of(context).adminInvalidPrice);
      return;
    }
    if (minBudget == null || minBudget < 0) {
      setState(() => _error = AppLocalizations.of(context).adminInvalidMinBudget);
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      await context.read<SuperadminCubit>().updateAdPricing(
        id:           widget.pricing.id,
        priceMxn:     price,
        minBudgetMxn: minBudget,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() { _saving = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            children: [
              const Icon(Icons.edit_outlined, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(AppLocalizations.of(context).adminEditLabel(widget.pricing.label),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(widget.pricing.billingTypeLabel(widget.totalUserCount),
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 20),

          // Precio base
          TextField(
            controller: _priceCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDeco(
              widget.pricing.billingType == 'cpm'
                  ? AppLocalizations.of(context).adminPricePerThousand
                  : widget.pricing.billingType == 'per_send'
                      ? AppLocalizations.of(context).adminPricePerSend
                      : AppLocalizations.of(context).adminFixedRate,
            ).copyWith(prefixText: '\$ '),
          ),
          const SizedBox(height: 14),

          const SizedBox(height: 14),

          // Presupuesto mínimo
          TextField(
            controller: _minBudgetCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDeco(AppLocalizations.of(context).adminMinCampaignBudget)
                .copyWith(prefixText: '\$ '),
          ),

          // Error
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(_error!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
            ),
          ],
          const SizedBox(height: 20),

          // Botones
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      _saving ? null : () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context).adminCancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(AppLocalizations.of(context).adminSave),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Sub-pantalla: Créditos publicitarios
// ═══════════════════════════════════════════════════════════════════════════════

class _AdCreditsScreen extends StatefulWidget {
  const _AdCreditsScreen();
  @override
  State<_AdCreditsScreen> createState() => _AdCreditsScreenState();
}

class _AdCreditsScreenState extends State<_AdCreditsScreen> {
  bool   _loading = true;
  String _query   = '';
  List<AdminEstablishmentEntry> _all       = [];
  List<AdminEstablishmentEntry> _filtered  = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await context.read<SuperadminCubit>().loadEstablishmentsForCredits();
      if (mounted) {
        setState(() {
          _all      = list;
          _filtered = list;
          _loading  = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearch(String q) {
    setState(() {
      _query    = q;
      _filtered = q.isEmpty
          ? _all
          : _all.where((e) =>
              e.name.toLowerCase().contains(q.toLowerCase()) ||
              e.ownerName.toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  void _openAddCredit(AdminEstablishmentEntry est) {
    showModalBottomSheet<void>(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<SuperadminCubit>(),
        child: _AddCreditSheet(
          establishment: est,
          onAdded: (newBalance) {
            setState(() {
              final idx = _all.indexWhere((e) => e.id == est.id);
              if (idx >= 0) {
                final updated = AdminEstablishmentEntry(
                  id:            est.id,
                  name:          est.name,
                  photoUrl:      est.photoUrl,
                  ownerName:     est.ownerName,
                  creditBalance: newBalance,
                );
                _all[idx] = updated;
                _filtered = _query.isEmpty
                    ? List.from(_all)
                    : _all.where((e) =>
                        e.name.toLowerCase().contains(_query.toLowerCase()) ||
                        e.ownerName.toLowerCase().contains(_query.toLowerCase()))
                      .toList();
              }
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(AppLocalizations.of(context).adminCreditsTitle,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              onChanged:   _onSearch,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).adminSearchEstOwner,
                prefixIcon:    const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled:     true,
                fillColor:  Colors.white,
              ),
            ),
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_filtered.isEmpty)
            Expanded(
              child: Center(
                child: Text(AppLocalizations.of(context).adminNoResults,
                    style: TextStyle(color: Colors.grey.shade500)),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: _filtered.length,
                itemBuilder: (_, i) {
                  final est = _filtered[i];
                  final balance = est.creditBalance;
                  return Card(
                    margin:    const EdgeInsets.only(bottom: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(0xFF00838F).withAlpha(20),
                        child: est.photoUrl != null
                            ? null
                            : Text(
                                est.name.isNotEmpty
                                    ? est.name[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: Color(0xFF00838F),
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                      title: Text(est.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(est.ownerName,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500)),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(fmt.format(balance),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:   14,
                                color: balance > 0
                                    ? const Color(0xFF00838F)
                                    : Colors.grey.shade500,
                              )),
                          Text(AppLocalizations.of(context).adminBalance, style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade400)),
                        ],
                      ),
                      onTap: () => _openAddCredit(est),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── Bottom sheet: agregar crédito ─────────────────────────────────────────────

class _AddCreditSheet extends StatefulWidget {
  final AdminEstablishmentEntry  establishment;
  final void Function(double)    onAdded;   // callback con nuevo balance
  const _AddCreditSheet({required this.establishment, required this.onAdded});
  @override
  State<_AddCreditSheet> createState() => _AddCreditSheetState();
}

class _AddCreditSheetState extends State<_AddCreditSheet> {
  final _amountCtrl = TextEditingController();
  final _descCtrl   = TextEditingController(text: 'Recarga manual');
  bool   _saving    = false;
  String? _error;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      setState(() => _error = AppLocalizations.of(context).adminEnterValidAmount);
      return;
    }
    final desc = _descCtrl.text.trim();
    if (desc.isEmpty) {
      setState(() => _error = AppLocalizations.of(context).adminEnterDescription);
      return;
    }

    setState(() { _saving = true; _error = null; });
    try {
      final authState = context.read<AuthBloc>().state;
      final addedBy   = authState is AuthAuthenticated ? authState.user.id : '';

      await context.read<SuperadminCubit>().addCredit(
        establishmentId: widget.establishment.id,
        amountMxn:       amount,
        description:     desc,
        addedBy:         addedBy,
      );

      final newBalance = widget.establishment.creditBalance + amount;
      if (mounted) {
        widget.onAdded(newBalance);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            AppLocalizations.of(context).adminCreditAdded(
                NumberFormat.currency(locale: "es_MX", symbol: "\$").format(newBalance)),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF00838F),
        ));
      }
    } catch (e) {
      if (mounted) setState(() { _saving = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final fmt    = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    return Container(
      margin:  const EdgeInsets.all(12),
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottom),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize:       MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  size: 20, color: Color(0xFF00838F)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.establishment.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(widget.establishment.ownerName,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Saldo actual
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color:        const Color(0xFF00838F).withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    size: 16, color: Color(0xFF00838F)),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).adminCurrentBalance(fmt.format(widget.establishment.creditBalance)),
                  style: const TextStyle(
                      fontSize: 13,
                      color:    Color(0xFF00838F),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Monto
          TextField(
            controller:   _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText:  AppLocalizations.of(context).adminAmountToAdd,
              prefixText: '\$ ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),

          // Descripción
          TextField(
            controller:  _descCtrl,
            decoration: InputDecoration(
              labelText:  AppLocalizations.of(context).adminDescriptionReason,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:        Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border:       Border.all(color: Colors.red.shade200),
              ),
              child: Text(_error!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
            ),
          ],
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.add_card_outlined),
              label: Text(_saving ? AppLocalizations.of(context).adminSaving : AppLocalizations.of(context).adminAddCredit),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00838F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: Size.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── CSV templates ────────────────────────────────────────────────────────────

const _kCsvEsts =
    'nombre,descripcion,direccion,telefono,lat,lng\n'
    '"Mi Restaurante","Cocina tradicional mexicana","Av. Juárez 123 Col. Centro","477-000-0000",21.1234,-101.5678\n'
    '"Café del Centro","Café y postres artesanales","Callejón del Beso 12","477-111-2222",21.1180,-101.6833';

const _kCsvPromos =
    'nombre,descripcion,dias,hora_inicio,hora_fin\n'
    '"2x1 en bebidas","Lunes y martes todo el día","1,2","09:00","22:00"\n'
    '"Happy Hour","20% de descuento en toda la carta","1,2,3,4,5","17:00","21:00"\n'
    '"Desayuno especial","Combo desayuno a precio especial","1,2,3,4,5,6,7","08:00","12:00"';

// ═══════════════════════════════════════════════════════════════════════════════
// Sub-pantalla: Carga masiva superadmin (CSV · dos tabs)
// ═══════════════════════════════════════════════════════════════════════════════

class _BulkPromoUploadScreen extends StatefulWidget {
  const _BulkPromoUploadScreen();

  @override
  State<_BulkPromoUploadScreen> createState() => _BulkPromoUploadScreenState();
}

class _BulkPromoUploadScreenState extends State<_BulkPromoUploadScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:           Text(AppLocalizations.of(context).adminBulkTitle),
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabs,
          tabs: [
            Tab(icon: const Icon(Icons.store_outlined),      text: AppLocalizations.of(context).adminTabEstablishments),
            Tab(icon: const Icon(Icons.local_offer_outlined), text: AppLocalizations.of(context).adminTabPromotions),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _EstsTab(),
          _PromosTab(),
        ],
      ),
    );
  }
}

// ─── Tab 1: Establecimientos ──────────────────────────────────────────────────

class _EstsTab extends StatefulWidget {
  const _EstsTab();
  @override
  State<_EstsTab> createState() => _EstsTabState();
}

class _EstsTabState extends State<_EstsTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _bizDs = BusinessDatasource();

  AdminUserEntry? _selectedOwner;
  List<List<dynamic>> _rows    = [];
  List<String>        _headers = [];
  bool    _uploading = false;
  int     _created   = 0;
  String? _error;

  Future<void> _pickCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.first.bytes;
    if (bytes == null) return;

    final content = String.fromCharCodes(bytes);
    final all = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
        .convert(content.trim());

    if (all.isEmpty) {
      setState(() => _error = AppLocalizations.of(context).adminCsvEmpty);
      return;
    }
    setState(() {
      _headers = all.first.map((e) => e.toString()).toList();
      _rows    = all.skip(1)
          .where((r) => r.any((c) => c.toString().trim().isNotEmpty))
          .toList();
      _error   = null;
    });
  }

  Future<void> _create() async {
    if (_selectedOwner == null) {
      setState(() => _error = AppLocalizations.of(context).adminSelectOwner);
      return;
    }
    if (_rows.isEmpty) {
      setState(() => _error = AppLocalizations.of(context).adminUploadCsvRow);
      return;
    }

    setState(() { _uploading = true; _error = null; });
    int ok = 0;
    final errors = <String>[];
    final l = AppLocalizations.of(context);

    for (final row in _rows) {
      try {
        final nombre    = _cell(row, 0);
        final desc      = _cell(row, 1);
        final direccion = _cell(row, 2);
        final tel       = _cell(row, 3);
        final lat       = double.tryParse(_cell(row, 4)) ?? 0.0;
        final lng       = double.tryParse(_cell(row, 5)) ?? 0.0;

        if (nombre.isEmpty) {
          errors.add(l.adminRowEmptyName(ok + errors.length + 2));
          continue;
        }
        await _bizDs.createEstablishment(
          userId:      _selectedOwner!.id,
          name:        nombre,
          description: desc.isEmpty      ? null : desc,
          address:     direccion.isEmpty ? null : direccion,
          phone:       tel.isEmpty       ? null : tel,
          lat:         lat,
          lng:         lng,
        );
        ok++;
      } catch (e) {
        errors.add(l.adminRowError(
            ok + errors.length + 2, e.toString().split('\n').first));
      }
    }

    setState(() {
      _uploading = false;
      _created  += ok;
      _rows      = [];
      _headers   = [];
      if (errors.isNotEmpty) _error = errors.join('\n');
    });

    if (mounted && ok > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:         Text(AppLocalizations.of(context).adminEstCreated(ok)),
        backgroundColor: const Color(0xFF2E7D32),
        behavior:        SnackBarBehavior.floating,
      ));
    }
  }

  String _cell(List<dynamic> row, int i) =>
      i < row.length ? row[i].toString().trim() : '';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state  = context.watch<SuperadminCubit>().state;
    final owners = state is SuperadminLoaded ? state.users : <AdminUserEntry>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoBanner(
            AppLocalizations.of(context).adminBulkEstBanner(_created),
          ),
          const SizedBox(height: 16),

          // Plantilla
          OutlinedButton.icon(
            onPressed: () => Share.share(
              _kCsvEsts,
              subject: AppLocalizations.of(context).adminTemplateEstSubject,
            ),
            icon:  const Icon(Icons.download_outlined, size: 18),
            label: Text(AppLocalizations.of(context).adminDownloadCsvTemplate),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2E7D32),
              side: const BorderSide(color: Color(0xFF2E7D32)),
            ),
          ),
          const SizedBox(height: 16),

          // Selector dueño
          DropdownButtonFormField<AdminUserEntry>(
            value:      _selectedOwner,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).adminOwnerRequired,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
            hint: Text(AppLocalizations.of(context).adminSelectOwnerHint),
            items: owners.map((u) => DropdownMenuItem(
              value: u,
              child: Text(
                '${u.displayName}  ·  ${u.email}',
                overflow: TextOverflow.ellipsis,
              ),
            )).toList(),
            onChanged: (v) => setState(() => _selectedOwner = v),
          ),
          const SizedBox(height: 16),

          // Subir CSV
          OutlinedButton.icon(
            onPressed: _pickCsv,
            icon:  const Icon(Icons.upload_file_outlined, size: 18),
            label: Text(AppLocalizations.of(context).adminSelectCsvFile),
          ),

          if (_headers.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).adminPreviewRows(_rows.length),
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _CsvPreview(headers: _headers, rows: _rows),
          ],

          if (_error != null) ...[
            const SizedBox(height: 12),
            _ErrorBox(_error!),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_uploading || _rows.isEmpty) ? null : _create,
              icon: _uploading
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(_uploading
                  ? AppLocalizations.of(context).adminCreatingEsts
                  : AppLocalizations.of(context).adminCreateEstsBtn(_rows.length)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab 2: Promociones ───────────────────────────────────────────────────────

class _PromosTab extends StatefulWidget {
  const _PromosTab();
  @override
  State<_PromosTab> createState() => _PromosTabState();
}

class _PromosTabState extends State<_PromosTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _promoDs = PromotionsDatasource();

  List<AdminEstablishmentEntry> _ests        = [];
  AdminEstablishmentEntry?      _selectedEst;
  bool _loadingEsts = true;
  List<List<dynamic>> _rows    = [];
  List<String>        _headers = [];
  bool    _uploading = false;
  int     _created   = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEsts();
  }

  Future<void> _loadEsts() async {
    try {
      final list = await context
          .read<SuperadminCubit>()
          .loadEstablishmentsForCredits();
      if (mounted) setState(() { _ests = list; _loadingEsts = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingEsts = false);
    }
  }

  Future<void> _pickCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.first.bytes;
    if (bytes == null) return;

    final content = String.fromCharCodes(bytes);
    final all = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
        .convert(content.trim());

    if (all.isEmpty) {
      setState(() => _error = AppLocalizations.of(context).adminCsvEmpty);
      return;
    }
    setState(() {
      _headers = all.first.map((e) => e.toString()).toList();
      _rows    = all.skip(1)
          .where((r) => r.any((c) => c.toString().trim().isNotEmpty))
          .toList();
      _error   = null;
    });
  }

  List<int> _parseDays(String raw) => raw
      .split(',')
      .map((s) => int.tryParse(s.trim()))
      .whereType<int>()
      .where((d) => d >= 1 && d <= 7)
      .toList();

  /// '17:00' → '17:00:00'  |  '17:00:00' → unchanged
  String _parseTime(String raw) {
    final t = raw.trim();
    return t.length == 5 ? '$t:00' : t;
  }

  String _cell(List<dynamic> row, int i) =>
      i < row.length ? row[i].toString().trim() : '';

  Future<void> _create() async {
    if (_selectedEst == null) {
      setState(() => _error = AppLocalizations.of(context).adminSelectEst);
      return;
    }
    if (_rows.isEmpty) {
      setState(() => _error = AppLocalizations.of(context).adminUploadCsvRow);
      return;
    }

    setState(() { _uploading = true; _error = null; });
    int ok = 0;
    final errors = <String>[];
    final l = AppLocalizations.of(context);

    for (final row in _rows) {
      try {
        final nombre = _cell(row, 0);
        final desc   = _cell(row, 1);
        final dias   = _parseDays(_cell(row, 2));
        final inicio = _parseTime(_cell(row, 3));
        final fin    = _parseTime(_cell(row, 4));

        if (nombre.isEmpty) {
          errors.add(l.adminRowEmptyName(ok + errors.length + 2));
          continue;
        }
        if (dias.isEmpty) {
          errors.add(l.adminRowInvalidDays(ok + errors.length + 2));
          continue;
        }

        await _promoDs.createPromotion(
          establishmentId: _selectedEst!.id,
          name:            nombre,
          description:     desc,
          type:            'normal',
          activeDays:      dias,
          startTime:       inicio,
          endTime:         fin,
          isAdultOnly:     false,
          isAdminCreated:  true,  // ← no cuenta contra el plan
        );
        ok++;
      } catch (e) {
        errors.add(l.adminRowError(
            ok + errors.length + 2, e.toString().split('\n').first));
      }
    }

    setState(() {
      _uploading = false;
      _created  += ok;
      _rows      = [];
      _headers   = [];
      if (errors.isNotEmpty) _error = errors.join('\n');
    });

    if (mounted && ok > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:         Text(AppLocalizations.of(context).adminPromosCreated(ok)),
        backgroundColor: const Color(0xFF2E7D32),
        behavior:        SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loadingEsts) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoBanner(
            AppLocalizations.of(context).adminBulkPromoBanner(_created),
          ),
          const SizedBox(height: 16),

          // Plantilla
          OutlinedButton.icon(
            onPressed: () => Share.share(
              _kCsvPromos,
              subject: AppLocalizations.of(context).adminTemplatePromoSubject,
            ),
            icon:  const Icon(Icons.download_outlined, size: 18),
            label: Text(AppLocalizations.of(context).adminDownloadCsvTemplate),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2E7D32),
              side: const BorderSide(color: Color(0xFF2E7D32)),
            ),
          ),
          const SizedBox(height: 16),

          // Selector establecimiento
          DropdownButtonFormField<AdminEstablishmentEntry>(
            value:      _selectedEst,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).adminEstRequired,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
            hint: Text(AppLocalizations.of(context).adminSelectBusinessHint),
            items: _ests.map((e) => DropdownMenuItem(
              value: e,
              child: Text(e.name, overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: (v) => setState(() => _selectedEst = v),
          ),
          const SizedBox(height: 16),

          // Subir CSV
          OutlinedButton.icon(
            onPressed: _pickCsv,
            icon:  const Icon(Icons.upload_file_outlined, size: 18),
            label: Text(AppLocalizations.of(context).adminSelectCsvFile),
          ),

          if (_headers.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).adminPreviewRows(_rows.length),
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _CsvPreview(headers: _headers, rows: _rows),
          ],

          if (_error != null) ...[
            const SizedBox(height: 12),
            _ErrorBox(_error!),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_uploading || _rows.isEmpty) ? null : _create,
              icon: _uploading
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(_uploading
                  ? AppLocalizations.of(context).adminCreatingPromos
                  : AppLocalizations.of(context).adminCreatePromosBtn(_rows.length)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Color(0xFF1B5E20)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String text;
  const _ErrorBox(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:        Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: Colors.red.shade700),
      ),
    );
  }
}

class _CsvPreview extends StatelessWidget {
  final List<String>        headers;
  final List<List<dynamic>> rows;
  const _CsvPreview({required this.headers, required this.rows});

  @override
  Widget build(BuildContext context) {
    final preview = rows.take(5).toList();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight:  32,
        dataRowMinHeight:  28,
        dataRowMaxHeight:  40,
        columnSpacing:     16,
        headingTextStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark),
        dataTextStyle: const TextStyle(
            fontSize: 11,
            color: AppColors.textDark),
        columns: headers
            .map((h) => DataColumn(label: Text(h)))
            .toList(),
        rows: preview
            .map((row) => DataRow(
                  cells: List.generate(
                    headers.length,
                    (i) => DataCell(Text(
                      i < row.length ? row[i].toString() : '',
                      overflow: TextOverflow.ellipsis,
                    )),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
