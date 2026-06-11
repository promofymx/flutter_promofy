import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/membership_plan_model.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/repositories/staff_repository.dart';
import '../../../features/auth/bloc/auth_bloc.dart';
import '../../../features/auth/bloc/auth_event.dart';
import '../../../features/auth/bloc/auth_state.dart';
import '../../../features/business/cubit/business_cubit.dart';
import '../../../features/business/cubit/business_state.dart';
import '../../../features/home/bloc/home_bloc.dart';
import '../../../features/plans/screens/plans_screen.dart';
import '../../../main.dart';
import 'package:promofy/l10n/app_localizations.dart';
import '../cubit/achievements_cubit.dart';
import '../cubit/achievements_state.dart';
import '../../../data/models/user_stats_model.dart';
import 'settings_screen.dart';
import '../../onboarding/widgets/welcome_carousel.dart';
import 'logros_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── Logros / gamificación ─────────────────────────────────────────────────
  AchievementsCubit? _achievementsCubit;

  void _initAchievements(String userId) {
    if (_achievementsCubit != null) return;
    _achievementsCubit = AchievementsCubit(userId: userId);
    _achievementsCubit!.load();
  }

  @override
  void dispose() {
    _achievementsCubit?.close();
    super.dispose();
  }

  // ── Abrir sheet "¿Tienes un negocio?" ────────────────────────────────────

  void _showBusinessRegistrationSheet() {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    if (authState is! AuthAuthenticated) return;

    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => _BusinessRegistrationSheet(
        userId: authState.user.id,
        // Se llama con el callback que debe ejecutarse DESPUÉS del pago
        onNavigateToPlans: (Future<void> Function() onPaymentSuccess) {
          Navigator.of(context).pop(); // cierra el sheet
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PlansScreen(onPaymentSuccess: onPaymentSuccess),
            ),
          );
        },
        onRefreshAuth: () =>
            authBloc.add(AuthProfileRefreshRequested()),
      ),
    );
  }

  // ── Abrir diálogo "Unirse a un equipo" ───────────────────────────────────

  void _showJoinTeamDialog() {
    final authBloc = context.read<AuthBloc>();
    showDialog<void>(
      context: context,
      builder: (_) => _JoinTeamDialog(
        onSuccess: () => authBloc.add(AuthProfileRefreshRequested()),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          // Invitado (o aún cargando): mostramos CTA de iniciar sesión.
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Text(AppLocalizations.of(context).profileTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_circle_outlined,
                        size: 72, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context).loginSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/login'),
                        child: Text(
                            AppLocalizations.of(context).loginSignInButton),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final profile = state.profile;
        final email   = state.user.email ?? '';
        final userId  = state.user.id;

        _initAchievements(userId);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(AppLocalizations.of(context).profileTitle,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header con badge real
                BlocBuilder<AchievementsCubit, AchievementsState>(
                  bloc: _achievementsCubit,
                  builder: (_, achState) {
                    final badge = achState is AchievementsLoaded
                        ? achState.stats.currentBadge
                        : null;
                    return _ProfileHeader(
                        profile: profile, email: email, badgeTier: badge);
                  },
                ),
                const SizedBox(height: 16),

                // ── Logros / estadísticas ─────────────────────────────────
                BlocBuilder<AchievementsCubit, AchievementsState>(
                  bloc: _achievementsCubit,
                  builder: (context, achState) {
                    if (achState is AchievementsLoaded) {
                      return _AchievementsCard(
                        stats: achState.stats,
                        onVerTodos: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LogrosScreen(userId: userId),
                          ),
                        ),
                      );
                    }
                    if (achState is AchievementsLoading ||
                        achState is AchievementsInitial) {
                      return const _AchievementsCardSkeleton();
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 16),

                _AccountCard(profile: profile),
                const SizedBox(height: 16),

                // ── Mis favoritos ─────────────────────────────────────────
                _FavoritesCard(
                  onTap: () => context.push('/favorites'),
                ),
                const SizedBox(height: 16),

                // ── Configuración (abre pantalla dedicada) ────────────────
                _SettingsEntryCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: context.read<AuthBloc>()),
                          BlocProvider.value(value: context.read<HomeBloc>()),
                        ],
                        child: SettingsScreen(profile: profile, userId: userId),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Card membresía de negocio (dueño o superadmin) ────────
                if (profile.isBusinessOwner || profile.isSuperadmin) ...[
                  _BusinessOwnerCard(profile: profile),
                  const SizedBox(height: 16),
                  _ReferralCard(profile: profile),
                  const SizedBox(height: 16),
                ],

                // ── Card de empleado (staff) ───────────────────────────────
                if (profile.isStaff) ...[
                  const _StaffWorkplacesCard(),
                  const SizedBox(height: 16),
                ],

                // ── Banners de registro/unión — solo si no es dueño ni staff ─
                if (!profile.isBusinessOwner &&
                    !profile.isSuperadmin &&
                    !profile.isStaff) ...[
                  _RegisterBusinessBanner(
                    onRegister: _showBusinessRegistrationSheet,
                  ),
                  const SizedBox(height: 12),

                  // ── Card "¿Trabajas en un negocio?" ─────────────────────
                  _JoinTeamCard(onJoin: _showJoinTeamDialog),
                  const SizedBox(height: 16),
                ],

                OutlinedButton.icon(
                  onPressed: () => showWelcomeCarousel(context),
                  icon:  const Icon(Icons.help_outline, color: AppColors.primary),
                  label: Text(AppLocalizations.of(context).tourReplay,
                      style: const TextStyle(color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () =>
                      context.read<AuthBloc>().add(AuthSignOutRequested()),
                  icon:  const Icon(Icons.logout, color: Colors.red),
                  label: Text(AppLocalizations.of(context).profileSignOut,
                      style: const TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final ProfileModel profile;
  final String       email;
  final BadgeTier?   badgeTier;
  const _ProfileHeader({required this.profile, required this.email, this.badgeTier});

  String get _initials {
    final name  = profile.fullName ?? '';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar circular con iniciales
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName ?? AppLocalizations.of(context).profileNoName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                // Badges: nivel + dueño de negocio (si aplica)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _LevelBadge(profile: profile, badgeTier: badgeTier),
                    if (profile.isBusinessOwner)
                      _Chip(
                        icon:  Icons.store_outlined,
                        label: AppLocalizations.of(context).profileBusinessOwnerChip,
                        color: AppColors.primary,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Badge de nivel del consumidor ───────────────────────────────────────────

class _LevelBadge extends StatelessWidget {
  final ProfileModel profile;
  final BadgeTier?   badgeTier;
  const _LevelBadge({required this.profile, this.badgeTier});

  // Nivel visual: negocio/staff por rol, consumidor por insignia de visitas.
  _LevelData _levelOf(BuildContext context) {
    if (profile.isBusinessOwner) {
      return _LevelData(
        label:  AppLocalizations.of(context).profileLevelBusinessActive,
        icon:   Icons.verified_outlined,
        color:  const Color(0xFF00897B),
      );
    }
    if (profile.isStaff) {
      return _LevelData(
        label:  AppLocalizations.of(context).profileLevelStaff,
        icon:   Icons.badge_outlined,
        color:  const Color(0xFF3949AB),
      );
    }
    final badge = badgeTier ?? BadgeTier.none;
    return _LevelData(
      label: badge.label,
      icon:  badge == BadgeTier.none
          ? Icons.explore_outlined
          : Icons.military_tech_outlined,
      color: badge.color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lv = _levelOf(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        lv.color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: lv.color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(lv.icon, size: 13, color: lv.color),
          const SizedBox(width: 4),
          Text(
            lv.label,
            style: TextStyle(
              fontSize: 11,
              color: lv.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelData {
  final String   label;
  final IconData icon;
  final Color    color;
  const _LevelData({required this.label, required this.icon, required this.color});
}

// ─── Chip genérico ────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Datos de la cuenta ───────────────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  final ProfileModel profile;
  const _AccountCard({required this.profile});

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatGender(BuildContext context, String? g) {
    final l10n = AppLocalizations.of(context);
    switch (g) {
      case 'male':   return l10n.profileGenderMale;
      case 'female': return l10n.profileGenderFemale;
      case 'other':  return l10n.profileGenderOther;
      default:       return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _Card(
      title: l10n.profileAccountInfoTitle,
      children: [
        _Row(label: l10n.profileFieldName,      value: profile.fullName ?? '—'),
        _Row(label: l10n.profileFieldBirthDate, value: _formatDate(profile.birthDate)),
        _Row(label: l10n.profileFieldGender,    value: _formatGender(context, profile.gender)),
      ],
    );
  }
}

// ─── Card del dueño de negocio ────────────────────────────────────────────────

class _BusinessOwnerCard extends StatelessWidget {
  final ProfileModel profile;
  const _BusinessOwnerCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessCubit, BusinessState>(
      builder: (context, bizState) {
        final plan = _extractPlan(bizState);

        return _Card(
          title: AppLocalizations.of(context).profileBusinessMembershipTitle,
          children: [
            _PlanRow(plan: plan, expiresAt: profile.planExpiresAt),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.go('/business'),
              icon:  const Icon(Icons.store_outlined),
              label: Text(AppLocalizations.of(context).profileGoToMyBusiness),
              style: OutlinedButton.styleFrom(
                minimumSize:     const Size(double.infinity, 48),
                side:            const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PlansScreen()),
              ),
              icon:  const Icon(Icons.workspace_premium_rounded, size: 16),
              label: Text(AppLocalizations.of(context).profileViewPlansAndPayments,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        );
      },
    );
  }

  MembershipPlanModel? _extractPlan(BusinessState s) {
    if (s is BusinessLoaded)          return s.plan;
    if (s is BusinessNoEstablishment) return s.plan;
    return null;
  }
}

// ─── Fila del plan ────────────────────────────────────────────────────────────

class _PlanRow extends StatelessWidget {
  final MembershipPlanModel? plan;
  final DateTime?            expiresAt;
  const _PlanRow({required this.plan, required this.expiresAt});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final planName = plan?.name ?? l10n.profileBasicPlan;

    // Estado del vencimiento
    final String expiryLabel;
    final Color  expiryColor;

    if (expiresAt == null) {
      expiryLabel = l10n.profileNoExpiry;
      expiryColor = Colors.grey.shade500;
    } else {
      final now      = DateTime.now();
      final diff     = expiresAt!.difference(now).inDays;
      final dateStr  = '${expiresAt!.day.toString().padLeft(2, '0')}/'
                       '${expiresAt!.month.toString().padLeft(2, '0')}/'
                       '${expiresAt!.year}';
      if (expiresAt!.isBefore(now)) {
        expiryLabel = l10n.profileExpired(dateStr);
        expiryColor = Colors.red.shade600;
      } else if (diff <= 7) {
        expiryLabel = l10n.profileExpiresOn(dateStr);
        expiryColor = Colors.orange.shade700;
      } else {
        expiryLabel = l10n.profileExpiresOn(dateStr);
        expiryColor = Colors.grey.shade500;
      }
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.workspace_premium_outlined,
              color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(planName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textDark)),
              const SizedBox(height: 2),
              Text(expiryLabel,
                  style: TextStyle(fontSize: 12, color: expiryColor)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Banner "¿Tienes un negocio?" ────────────────────────────────────────────

class _RegisterBusinessBanner extends StatelessWidget {
  final VoidCallback onRegister;
  const _RegisterBusinessBanner({required this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.store_outlined,
                color: Colors.red, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).profileHaveBusinessTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).profileHaveBusinessSubtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              // Sobreescribe el minimumSize del tema (double.infinity, 52)
              // porque este botón vive dentro de un Row.
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(AppLocalizations.of(context).profileRegisterIt,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Sheet: registro de negocio ───────────────────────────────────────

class _BusinessRegistrationSheet extends StatefulWidget {
  final String                                  userId;
  /// Se llama pasando el callback que PlansScreen ejecutará post-pago.
  final void Function(Future<void> Function())  onNavigateToPlans;
  final VoidCallback                            onRefreshAuth;

  const _BusinessRegistrationSheet({
    required this.userId,
    required this.onNavigateToPlans,
    required this.onRefreshAuth,
  });

  @override
  State<_BusinessRegistrationSheet> createState() =>
      _BusinessRegistrationSheetState();
}

class _BusinessRegistrationSheetState
    extends State<_BusinessRegistrationSheet> {
  // 'initial' | 'loaded' | 'code' | 'no_code'
  String  _step      = 'initial';
  bool    _isLoading = false;
  String? _error;

  // ── Tengo código ──────────────────────────────────────────────────────────
  final _codeCtrl = TextEditingController();
  String? _validatedCode;
  String? _validatedEstName;

  // ── No tengo código (búsqueda por dirección) ──────────────────────────────
  final _nameCtrl    = TextEditingController();
  final _addressCtrl = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool    _hasSearched       = false;
  String? _selectedEstId;
  String? _selectedEstName;
  String? _selectedEstAddress;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // ── Acciones ──────────────────────────────────────────────────────────────

  /// "Es nuevo" → PlansScreen.
  /// Post-pago: activa el rol de dueño y refresca el perfil.
  void _goNewBusiness() {
    final userId = widget.userId;
    widget.onNavigateToPlans(() async {
      try {
        await supabase.rpc('activate_new_business',
            params: {'p_user_id': userId});
      } catch (_) { /* silencioso — el webhook puede haberlo hecho ya */ }
      widget.onRefreshAuth();
    });
  }

  /// Valida el código sin canjearlo; si es válido muestra confirmación.
  Future<void> _validateCode() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = AppLocalizations.of(context).profileEnterInvitationCode);
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() { _isLoading = true; _error = null; });
    try {
      final result = await supabase.rpc(
        'validate_invitation_code',
        params: {'p_code': code},
      ) as Map<String, dynamic>;

      if (!mounted) return;
      if (result['valid'] == true) {
        setState(() {
          _validatedCode   = code;
          _validatedEstName = result['establishment_name'] as String?;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error     = result['error'] as String? ?? l10n.profileInvalidCode;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _error = l10n.profileConnectionError; _isLoading = false; });
    }
  }

  /// Después de validar el código → PlansScreen.
  /// Post-pago: canjear el código (vincula establecimiento + activa rol).
  void _goWithCode() {
    final code = _validatedCode!;
    widget.onNavigateToPlans(() async {
      await supabase.rpc(
        'redeem_business_invitation',
        params: {'p_code': code},
      );
      widget.onRefreshAuth();
    });
  }

  /// Busca establecimientos sin dueño por nombre + dirección.
  Future<void> _searchEstablishments() async {
    final name    = _nameCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final l10n    = AppLocalizations.of(context);
    if (name.isEmpty) {
      setState(() => _error = l10n.profileEnterBusinessName);
      return;
    }
    setState(() { _isLoading = true; _error = null; _hasSearched = false; });
    try {
      final rows = await supabase.rpc(
        'match_establishments_by_address',
        params: {
          'p_name':    name,
          'p_address': address,
          'p_user_id': widget.userId,
        },
      ) as List;

      if (!mounted) return;
      setState(() {
        _searchResults = rows
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _hasSearched = true;
        _isLoading   = false;
      });
    } catch (_) {
      if (mounted) setState(() { _error = l10n.profileSearchError; _isLoading = false; });
    }
  }

  /// Después de seleccionar establecimiento → PlansScreen.
  /// Post-pago: reclama el establecimiento (vincula owner_id + activa rol).
  void _goWithEstablishment() {
    final estId  = _selectedEstId!;
    final userId = widget.userId;
    widget.onNavigateToPlans(() async {
      try {
        final result = await supabase.rpc(
          'claim_establishment',
          params: {'p_user_id': userId, 'p_establishment_id': estId},
        ) as Map<String, dynamic>;
        // Si falla (ya tiene otro dueño) lo ignoramos silenciosamente;
        // el usuario igual queda como business_owner por el plan pagado.
        if (result['success'] != true) {
          debugPrint('claim_establishment: ${result['error']}');
        }
      } catch (_) { /* silencioso */ }
      widget.onRefreshAuth();
    });
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  String _titleOf(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (_step) {
      case 'loaded':   return l10n.profileSheetTitleLoaded;
      case 'code':     return l10n.profileSheetTitleCode;
      case 'no_code':  return l10n.profileSheetTitleNoCode;
      default:         return l10n.profileSheetTitleInitial;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              _titleOf(context),
              style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            // ── Paso inicial ──────────────────────────────────────────────
            if (_step == 'initial') ...[
              _SheetOption(
                icon:     Icons.fiber_new_outlined,
                title:    AppLocalizations.of(context).profileOptionNewTitle,
                subtitle: AppLocalizations.of(context).profileOptionNewSubtitle,
                onTap:    _goNewBusiness,
              ),
              const SizedBox(height: 10),
              _SheetOption(
                icon:     Icons.store_outlined,
                title:    AppLocalizations.of(context).profileOptionLoadedTitle,
                subtitle: AppLocalizations.of(context).profileOptionLoadedSubtitle,
                onTap:    () => setState(() => _step = 'loaded'),
              ),
            ],

            // ── Ya está cargado ───────────────────────────────────────────
            if (_step == 'loaded') ...[
              _SheetOption(
                icon:     Icons.vpn_key_outlined,
                title:    AppLocalizations.of(context).profileOptionHaveCodeTitle,
                subtitle: AppLocalizations.of(context).profileOptionHaveCodeSubtitle,
                onTap:    () => setState(() { _step = 'code'; _error = null; }),
              ),
              const SizedBox(height: 10),
              _SheetOption(
                icon:     Icons.search_rounded,
                title:    AppLocalizations.of(context).profileOptionNoCodeTitle,
                subtitle: AppLocalizations.of(context).profileOptionNoCodeSubtitle,
                onTap:    () => setState(() { _step = 'no_code'; _error = null; }),
              ),
              const SizedBox(height: 10),
              _BackButton(onTap: () => setState(() => _step = 'initial')),
            ],

            // ── Tengo código ──────────────────────────────────────────────
            if (_step == 'code') ...[
              if (_validatedCode == null) ...[
                TextField(
                  controller:         _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  onSubmitted:        (_) => _validateCode(),
                  decoration: InputDecoration(
                    hintText:   AppLocalizations.of(context).profileInvitationCodeHint,
                    errorText:  _error,
                    prefixIcon: const Icon(Icons.confirmation_number_outlined),
                    suffixIcon: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5)),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _validateCode,
                    child: Text(AppLocalizations.of(context).profileVerifyCode,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ] else ...[
                // ✓ Código válido
                _SuccessCard(
                  icon:     Icons.check_circle_outline_rounded,
                  title:    AppLocalizations.of(context).profileValidCode,
                  subtitle: _validatedEstName ?? AppLocalizations.of(context).profileEstablishmentFound,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _goWithCode,
                    icon:  const Icon(Icons.workspace_premium_rounded, size: 18),
                    label: Text(AppLocalizations.of(context).profileChooseMyPlan,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _BackButton(onTap: () => setState(() {
                _step = 'loaded'; _error = null;
                _validatedCode = null; _validatedEstName = null;
                _codeCtrl.clear();
              })),
            ],

            // ── No tengo código ───────────────────────────────────────────
            if (_step == 'no_code') ...[
              if (_selectedEstId == null) ...[
                TextField(
                  controller:         _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText:   AppLocalizations.of(context).profileBusinessNameHint,
                    prefixIcon: const Icon(Icons.store_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller:         _addressCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText:   AppLocalizations.of(context).profileAddressHint,
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: TextStyle(color: Colors.red.shade600, fontSize: 12)),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _searchEstablishments,
                    icon: _isLoading
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.search_rounded, size: 18),
                    label: Text(AppLocalizations.of(context).profileSearchMyBusiness,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                // Resultados de búsqueda
                if (_hasSearched) ...[
                  const SizedBox(height: 16),
                  if (_searchResults.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 40, color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context).profileNoMatches,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppLocalizations.of(context).profileSelectYourBusiness,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: AppColors.textDark)),
                        const SizedBox(height: 8),
                        ..._searchResults.map((est) => _EstResultTile(
                          name:    est['name'] as String? ?? '',
                          address: est['address'] as String? ?? '',
                          onTap:   () => setState(() {
                            _selectedEstId      = (est['id'] as Object?)?.toString();
                            _selectedEstName    = est['name'] as String?;
                            _selectedEstAddress = est['address'] as String?;
                          }),
                        )),
                      ],
                    ),
                ],
              ] else ...[
                // ✓ Establecimiento seleccionado
                _SuccessCard(
                  icon:     Icons.store_rounded,
                  title:    _selectedEstName ?? AppLocalizations.of(context).profileYourBusiness,
                  subtitle: _selectedEstAddress ?? '',
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context).profileAddressMatchQuestion,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _goWithEstablishment,
                    icon:  const Icon(Icons.workspace_premium_rounded, size: 18),
                    label: Text(AppLocalizations.of(context).profileYesItsMineChoosePlan,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() {
                      _selectedEstId = null; _selectedEstName = null;
                      _selectedEstAddress = null;
                    }),
                    child: Text(AppLocalizations.of(context).profileNotThisBusiness,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              _BackButton(onTap: () => setState(() {
                _step = 'loaded'; _error = null;
                _searchResults = []; _hasSearched = false;
                _selectedEstId = null; _selectedEstName = null;
                _nameCtrl.clear(); _addressCtrl.clear();
              })),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Tarjeta de éxito (código válido / negocio seleccionado) ─────────────────

class _SuccessCard extends StatelessWidget {
  final IconData icon;
  final String   title;
  final String   subtitle;
  const _SuccessCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade600, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: Colors.green.shade800)),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.green.shade700)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tile de resultado de búsqueda ───────────────────────────────────────────

class _EstResultTile extends StatelessWidget {
  final String       name;
  final String       address;
  final VoidCallback onTap;
  const _EstResultTile({required this.name, required this.address, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin:   const EdgeInsets.only(bottom: 8),
        padding:  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:        Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border:       Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20), shape: BoxShape.circle,
              ),
              child: const Icon(Icons.store_outlined,
                  size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: AppColors.textDark)),
                  if (address.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(address,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
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

// ─── Botón volver ─────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text('← ${AppLocalizations.of(context).profileBack}',
          style: const TextStyle(color: AppColors.primary)),
    );
  }
}

// ─── Card Mis favoritos ───────────────────────────────────────────────────────

class _FavoritesCard extends StatelessWidget {
  final VoidCallback onTap;
  const _FavoritesCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded,
                  color: Colors.pinkAccent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).profileFavoritesTitle,
                    style: const TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context).profileFavoritesSubtitle,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
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

// ─── Opción de sheet ──────────────────────────────────────────────────────────

class _SheetOption extends StatelessWidget {
  final IconData     icon;
  final String       title;
  final String       subtitle;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:        onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color:        Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:  AppColors.primary.withAlpha(20),
                shape:  BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize:   14,
                          fontWeight: FontWeight.w600,
                          color:      AppColors.textDark)),
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

// ─── Widgets reutilizables ────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String       title;
  final List<Widget> children;
  const _Card({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// --- Card de entrada a Configuraci�n ------------------------------------------

class _SettingsEntryCard extends StatelessWidget {
  final VoidCallback onTap;
  const _SettingsEntryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), shape: BoxShape.circle),
              child: const Icon(Icons.settings_outlined, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).profileSettingsTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(AppLocalizations.of(context).profileSettingsSubtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

// ─── Filas y contenedores ─────────────────────────────────────────────────────

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark)),
        ],
      ),
    );
  }
}

// ─── Card: mis lugares de trabajo (staff) ────────────────────────────────────

class _StaffWorkplacesCard extends StatefulWidget {
  const _StaffWorkplacesCard();

  @override
  State<_StaffWorkplacesCard> createState() => _StaffWorkplacesCardState();
}

class _StaffWorkplacesCardState extends State<_StaffWorkplacesCard> {
  final _repo = StaffRepository();
  bool _loading = true;
  List<Map<String, dynamic>> _memberships = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await _repo.getMyStaffMemberships();
      if (mounted) setState(() { _memberships = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _roleLabel(BuildContext context, String? role) {
    final l10n = AppLocalizations.of(context);
    switch (role) {
      case 'manager': return l10n.profileRoleManager;
      case 'cashier': return l10n.profileRoleCashierWaiter;
      default:        return l10n.profileRoleCustom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: AppLocalizations.of(context).profileWorkplacesTitle,
      children: [
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          )
        else if (_memberships.isEmpty)
          Text(
            AppLocalizations.of(context).profileNoWorkplaces,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          )
        else
          ..._memberships.map((m) {
            final est     = m['establishments'] as Map<String, dynamic>?;
            final name    = est?['name'] as String? ?? '—';
            final role    = _roleLabel(context, m['role'] as String?);
            final perms   = (m['permissions'] as Map<String, dynamic>?) ?? {};
            final canScan    = perms['scan_qr']       == true;
            final canStats   = perms['view_stats']    == true;
            final canManage  = perms['manage_promos'] == true;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:        const Color(0xFF3949AB).withAlpha(8),
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: const Color(0xFF3949AB).withAlpha(40)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:  const Color(0xFF3949AB).withAlpha(20),
                      shape:  BoxShape.circle,
                    ),
                    child: const Icon(Icons.store_outlined,
                        size: 18, color: Color(0xFF3949AB)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600,
                                color: AppColors.textDark)),
                        const SizedBox(height: 2),
                        Text(AppLocalizations.of(context).profileRoleLabel(role),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        if (canScan || canStats || canManage) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4, runSpacing: 4,
                            children: [
                              if (canScan)   _StaffPermChip(AppLocalizations.of(context).profilePermLoyaltyQr),
                              if (canStats)  _StaffPermChip(AppLocalizations.of(context).profilePermStats),
                              if (canManage) _StaffPermChip(AppLocalizations.of(context).profilePermPromos),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _StaffPermChip extends StatelessWidget {
  final String label;
  const _StaffPermChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color:        const Color(0xFF3949AB).withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: const Color(0xFF3949AB).withAlpha(60)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize:   10,
          color:      Color(0xFF3949AB),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Card "¿Trabajas en un negocio?" ─────────────────────────────────────────

class _JoinTeamCard extends StatelessWidget {
  final VoidCallback onJoin;
  const _JoinTeamCard({required this.onJoin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF3949AB).withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.group_add_outlined,
                color: Color(0xFF3949AB), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).profileWorkAtBusinessTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).profileWorkAtBusinessSubtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onJoin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3949AB),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 44),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(AppLocalizations.of(context).profileJoin,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ─── Tarjeta de referidos ─────────────────────────────────────────────────────

class _ReferralCard extends StatefulWidget {
  final ProfileModel profile;
  const _ReferralCard({required this.profile});

  @override
  State<_ReferralCard> createState() => _ReferralCardState();
}

class _ReferralCardState extends State<_ReferralCard> {
  bool _copied = false;
  final _redeemController = TextEditingController();
  bool _redeeming = false;

  @override
  void dispose() {
    _redeemController.dispose();
    super.dispose();
  }

  Future<void> _redeemCode() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final code = _redeemController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _redeeming = true);
    try {
      final res = await supabase.rpc('redeem_referral', params: {'p_code': code});
      final map = (res as Map?) ?? {};
      final ok = map['ok'] == true;
      final reason = map['reason']?.toString() ?? 'error';

      final String message;
      switch (reason) {
        case 'ok':        message = l10n.profileReferralOk;        break;
        case 'already':   message = l10n.profileReferralAlready;   break;
        case 'not_found': message = l10n.profileReferralNotFound;  break;
        case 'self':      message = l10n.profileReferralSelf;      break;
        default:          message = l10n.profileReferralGenericError;
      }
      if (!mounted) return;
      if (ok) _redeemController.clear();
      messenger.showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.profileReferralGenericError),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _redeeming = false);
    }
  }

  String get _shareUrl {
    final code = widget.profile.referralCode ?? '';
    return 'https://promofy.fun/r/$code';
  }

  Future<void> _copyLink() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: _shareUrl));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.profileLinkCopied),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareLink() async {
    final l10n = AppLocalizations.of(context);
    await Share.share(l10n.profileReferralShareText(_shareUrl),
        subject: l10n.profileReferralShareSubject);
  }

  @override
  Widget build(BuildContext context) {
    final code    = widget.profile.referralCode;
    final credits = widget.profile.adCreditsMxn;

    return _Card(
      title: '🎁 ${AppLocalizations.of(context).profileReferralTitle}',
      children: [
        // Descripción
        Text(
          AppLocalizations.of(context).profileReferralDescription,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
        ),
        const SizedBox(height: 14),

        // Créditos acumulados
        if (credits > 0) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.wallet_outlined, size: 18, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).profileCreditsEarned,
                    style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                  ),
                ),
                Text(
                  '\$${credits.toStringAsFixed(0)} MXN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Link
        if (code != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _shareUrl,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'monospace',
                      color: AppColors.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Chip del código
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    code,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Botones
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyLink,
                  icon: Icon(
                    _copied ? Icons.check_rounded : Icons.copy_outlined,
                    size: 16,
                    color: _copied ? Colors.green : AppColors.primary,
                  ),
                  label: Text(
                    _copied
                        ? AppLocalizations.of(context).profileCopied
                        : AppLocalizations.of(context).profileCopyLink,
                    style: TextStyle(
                      color: _copied ? Colors.green : AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    side: BorderSide(
                      color: _copied ? Colors.green : AppColors.primary,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareLink,
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: Text(
                    AppLocalizations.of(context).profileShare,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          // No tiene código aún (migración pendiente)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              AppLocalizations.of(context).profileReferralLinkSoon,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ),
        ],

        // ── ¿Te invitaron? Canjear código de invitación ──────────────────
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 14),
        Text(
          AppLocalizations.of(context).profileReferralHaveCodeTitle,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _redeemController,
                textCapitalization: TextCapitalization.characters,
                enabled: !_redeeming,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).profileReferralCodeHint,
                  prefixIcon: const Icon(Icons.card_giftcard_outlined, size: 20),
                  isDense: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onSubmitted: (_) => _redeeming ? null : _redeemCode(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _redeeming ? null : _redeemCode,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _redeeming
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(AppLocalizations.of(context).profileReferralApply,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Diálogo de aceptación de invitación de staff ─────────────────────────────

// ─── Card de logros / gamificación ───────────────────────────────────────────

class _AchievementsCard extends StatelessWidget {
  final UserStatsModel stats;
  final VoidCallback   onVerTodos;
  const _AchievementsCard({required this.stats, required this.onVerTodos});

  @override
  Widget build(BuildContext context) {
    final badge  = stats.currentBadge;
    final streak = stats.streakBadge;
    final topPct = stats.topPercent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado ──────────────────────────────────────────────────
          Row(
            children: [
              Text(
                AppLocalizations.of(context).profileAchievementsTitle,
                style: const TextStyle(
                  fontSize:   15,
                  fontWeight: FontWeight.bold,
                  color:      AppColors.textDark,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onVerTodos,
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context).profileSeeAll,
                      style: TextStyle(
                        fontSize:   13,
                        color:      AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        size: 18, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Badge actual + progress ──────────────────────────────────────
          Row(
            children: [
              // Emoji grande
              Container(
                width:  56,
                height: 56,
                decoration: BoxDecoration(
                  color:  badge.color.withAlpha(20),
                  shape:  BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(badge.emoji,
                    style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badge.label,
                      style: TextStyle(
                        fontSize:   15,
                        fontWeight: FontWeight.w700,
                        color:      badge.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (stats.nextBadge != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value:           stats.badgeProgress,
                          minHeight:       7,
                          backgroundColor: stats.nextBadge!.color.withAlpha(25),
                          valueColor:      AlwaysStoppedAnimation<Color>(
                              stats.nextBadge!.color),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context).profileVisitsToNextBadge(
                            stats.annualVisits,
                            stats.visitsToNextBadge,
                            stats.nextBadge!.label),
                        style: TextStyle(
                            fontSize: 11,
                            color:    Colors.grey.shade500),
                      ),
                    ] else ...[
                      Text(
                        AppLocalizations.of(context).profileVisitsMaxLevel(stats.annualVisits),
                        style: TextStyle(
                            fontSize: 12,
                            color:    badge.color),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // ── Stats row (racha / top%) ─────────────────────────────────────
          if (stats.currentStreakWeeks > 0 || topPct != null) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                if (stats.currentStreakWeeks > 0) ...[
                  Text(streak.emoji,
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).profileStreakWeeks(stats.currentStreakWeeks),
                      style: TextStyle(
                        fontSize:   13,
                        fontWeight: FontWeight.w600,
                        color:      streak.color,
                      ),
                    ),
                  ),
                ],
                if (topPct != null) ...[
                  const Text('📊',
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context).profileTopInCity(topPct.toStringAsFixed(0)),
                    style: const TextStyle(
                      fontSize:   13,
                      fontWeight: FontWeight.w600,
                      color:      Color(0xFF00897B),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Skeleton mientras carga ────────────────────────────────────────────────────

class _AchievementsCardSkeleton extends StatelessWidget {
  const _AchievementsCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: Colors.grey.shade100, shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    )),
                const SizedBox(height: 8),
                Container(height: 8, decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                Container(height: 10, width: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Diálogo de aceptación de invitación de staff ─────────────────────────────

class _JoinTeamDialog extends StatefulWidget {
  final VoidCallback onSuccess;
  const _JoinTeamDialog({required this.onSuccess});

  @override
  State<_JoinTeamDialog> createState() => _JoinTeamDialogState();
}

class _JoinTeamDialogState extends State<_JoinTeamDialog> {
  final _codeCtrl = TextEditingController();
  bool    _isLoading        = false;
  String? _error;
  bool    _accepted         = false;
  String? _establishmentName;
  String? _roleLabel;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  String _mapRole(BuildContext context, String? role) {
    final l10n = AppLocalizations.of(context);
    switch (role) {
      case 'manager': return l10n.profileRoleManager;
      case 'cashier': return l10n.profileRoleCashier;
      default:        return l10n.profileRoleCustom;
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.length < 6) {
      setState(() => _error = l10n.profileCodeSixChars);
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final result = await StaffRepository().acceptInvitation(code);
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() {
          _accepted          = true;
          _establishmentName = result['establishment_name'] as String?;
          _roleLabel         = _mapRole(context, result['role'] as String?);
          _isLoading         = false;
        });
      } else {
        setState(() {
          _error     = result['error'] as String? ?? l10n.profileCodeInvalidOrExpired;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() { _error = l10n.profileConnectionErrorRetry; _isLoading = false; });
      }
    }
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        _accepted
            ? AppLocalizations.of(context).profileWelcomeToTeam
            : AppLocalizations.of(context).profileJoinATeam,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
            color: AppColors.textDark),
      ),
      content: _accepted ? _buildSuccess(context) : _buildInput(context),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: _accepted
          ? [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onSuccess();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 46),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(AppLocalizations.of(context).profileContinue,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ]
          : [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 46),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(AppLocalizations.of(context).profileCancel),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 46),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white),
                            )
                          : Text(AppLocalizations.of(context).profileJoinMe,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
    );
  }

  Widget _buildInput(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).profileEnterSixCharCode,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),
        TextField(
          controller:         _codeCtrl,
          textCapitalization: TextCapitalization.characters,
          maxLength:          6,
          onSubmitted:        (_) => _submit(),
          style: const TextStyle(
            fontSize:      22,
            fontWeight:    FontWeight.w700,
            letterSpacing: 8,
          ),
          textAlign:    TextAlign.center,
          decoration: InputDecoration(
            hintText:  'ABC123',
            hintStyle: TextStyle(
              color:         Colors.grey.shade400,
              fontWeight:    FontWeight.normal,
              letterSpacing: 6,
              fontSize:      20,
            ),
            errorText:   _error,
            counterText: '',
            filled:      true,
            fillColor:   Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:        Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border:       Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: Colors.green.shade600, size: 44),
              const SizedBox(height: 10),
              if (_establishmentName != null) ...[
                Text(
                  _establishmentName!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:   16,
                    fontWeight: FontWeight.w700,
                    color:      Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              if (_roleLabel != null)
                Text(
                  AppLocalizations.of(context).profileRoleLabel(_roleLabel!),
                  style: TextStyle(
                      fontSize: 13, color: Colors.green.shade700),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          AppLocalizations.of(context).profileWillUpdateOnContinue,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
