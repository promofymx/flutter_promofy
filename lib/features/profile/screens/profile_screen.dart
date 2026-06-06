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
import '../cubit/achievements_cubit.dart';
import '../cubit/achievements_state.dart';
import '../../../data/models/user_stats_model.dart';
import 'settings_screen.dart';
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
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
            title: const Text('Mi perfil',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
                  onPressed: () =>
                      context.read<AuthBloc>().add(AuthSignOutRequested()),
                  icon:  const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Cerrar sesión',
                      style: TextStyle(color: Colors.red)),
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
                  profile.fullName ?? 'Sin nombre',
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
                        label: 'Dueño de negocio',
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
  _LevelData get _level {
    if (profile.isBusinessOwner) {
      return const _LevelData(
        label:  'Negocio activo',
        icon:   Icons.verified_outlined,
        color:  Color(0xFF00897B),
      );
    }
    if (profile.isStaff) {
      return const _LevelData(
        label:  'Empleado',
        icon:   Icons.badge_outlined,
        color:  Color(0xFF3949AB),
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
    final lv = _level;
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

  String _formatGender(String? g) {
    switch (g) {
      case 'male':   return 'Hombre';
      case 'female': return 'Mujer';
      case 'other':  return 'Otro';
      default:       return '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Información de la cuenta',
      children: [
        _Row(label: 'Nombre',             value: profile.fullName ?? '—'),
        _Row(label: 'Fecha de nacimiento',value: _formatDate(profile.birthDate)),
        _Row(label: 'Género',             value: _formatGender(profile.gender)),
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
          title: 'Membresía de negocio',
          children: [
            _PlanRow(plan: plan, expiresAt: profile.planExpiresAt),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.go('/business'),
              icon:  const Icon(Icons.store_outlined),
              label: const Text('Ir a Mi negocio'),
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
              label: const Text('Ver planes y pagos',
                  style: TextStyle(fontWeight: FontWeight.w600)),
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
    final planName = plan?.name ?? 'Plan básico';

    // Estado del vencimiento
    final String expiryLabel;
    final Color  expiryColor;

    if (expiresAt == null) {
      expiryLabel = 'Sin vencimiento';
      expiryColor = Colors.grey.shade500;
    } else {
      final now      = DateTime.now();
      final diff     = expiresAt!.difference(now).inDays;
      final dateStr  = '${expiresAt!.day.toString().padLeft(2, '0')}/'
                       '${expiresAt!.month.toString().padLeft(2, '0')}/'
                       '${expiresAt!.year}';
      if (expiresAt!.isBefore(now)) {
        expiryLabel = 'Vencido ($dateStr)';
        expiryColor = Colors.red.shade600;
      } else if (diff <= 7) {
        expiryLabel = 'Vence el $dateStr';
        expiryColor = Colors.orange.shade700;
      } else {
        expiryLabel = 'Vence el $dateStr';
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
                const Text(
                  '¿Tienes un negocio?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Regístralo y llega a más clientes',
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
            child: const Text('Regístralo',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
      setState(() => _error = 'Ingresa tu código de invitación.');
      return;
    }
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
          _error     = result['error'] as String? ?? 'Código inválido.';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _error = 'Error de conexión.'; _isLoading = false; });
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
    if (name.isEmpty) {
      setState(() => _error = 'Ingresa el nombre de tu negocio.');
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
      if (mounted) setState(() { _error = 'Error al buscar. Intenta de nuevo.'; _isLoading = false; });
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

  String get _title {
    switch (_step) {
      case 'loaded':   return 'Ya está en Promofy';
      case 'code':     return 'Ingresa tu código';
      case 'no_code':  return 'Encuentra tu negocio';
      default:         return 'Registra tu negocio';
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
              _title,
              style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            // ── Paso inicial ──────────────────────────────────────────────
            if (_step == 'initial') ...[
              _SheetOption(
                icon:     Icons.fiber_new_outlined,
                title:    'Es nuevo',
                subtitle: 'Quiero registrar mi negocio en Promofy',
                onTap:    _goNewBusiness,
              ),
              const SizedBox(height: 10),
              _SheetOption(
                icon:     Icons.store_outlined,
                title:    'Ya está cargado',
                subtitle: 'Mi negocio ya existe en Promofy',
                onTap:    () => setState(() => _step = 'loaded'),
              ),
            ],

            // ── Ya está cargado ───────────────────────────────────────────
            if (_step == 'loaded') ...[
              _SheetOption(
                icon:     Icons.vpn_key_outlined,
                title:    'Tengo código',
                subtitle: 'Ingresar mi código de invitación',
                onTap:    () => setState(() { _step = 'code'; _error = null; }),
              ),
              const SizedBox(height: 10),
              _SheetOption(
                icon:     Icons.search_rounded,
                title:    'No tengo código',
                subtitle: 'Buscar mi negocio por nombre y dirección',
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
                    hintText:   'CÓDIGO DE INVITACIÓN',
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
                    child: const Text('Verificar código',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ] else ...[
                // ✓ Código válido
                _SuccessCard(
                  icon:     Icons.check_circle_outline_rounded,
                  title:    '¡Código válido!',
                  subtitle: _validatedEstName ?? 'Establecimiento encontrado',
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _goWithCode,
                    icon:  const Icon(Icons.workspace_premium_rounded, size: 18),
                    label: const Text('Elegir mi plan',
                        style: TextStyle(fontWeight: FontWeight.w600)),
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
                  decoration: const InputDecoration(
                    hintText:   'Nombre de tu negocio',
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller:         _addressCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText:   'Dirección (calle, número, colonia…)',
                    prefixIcon: Icon(Icons.location_on_outlined),
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
                    label: const Text('Buscar mi negocio',
                        style: TextStyle(fontWeight: FontWeight.w600)),
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
                            'No encontramos coincidencias.\nRevisa el nombre o la dirección.',
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
                        Text('Selecciona tu negocio:',
                            style: TextStyle(
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
                  title:    _selectedEstName ?? 'Tu negocio',
                  subtitle: _selectedEstAddress ?? '',
                ),
                const SizedBox(height: 6),
                Text(
                  'Verificamos que la dirección coincide. ¿Es tu negocio?',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _goWithEstablishment,
                    icon:  const Icon(Icons.workspace_premium_rounded, size: 18),
                    label: const Text('Sí, es mío — Elegir plan',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() {
                      _selectedEstId = null; _selectedEstName = null;
                      _selectedEstAddress = null;
                    }),
                    child: Text('No es este negocio',
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
      child: const Text('← Volver', style: TextStyle(color: AppColors.primary)),
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
                  const Text(
                    'Mis favoritos',
                    style: TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w700,
                      color:      AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Promos y negocios que guardaste',
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
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Configuración', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  SizedBox(height: 2),
                  Text('Nombre, radio, gustos, contraseña y cuenta', style: TextStyle(fontSize: 12, color: Colors.grey)),
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

  String _roleLabel(String? role) {
    switch (role) {
      case 'manager': return 'Gerente';
      case 'cashier': return 'Cajero / Mesero';
      default:        return 'Personalizado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Mis lugares de trabajo',
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
            'No se encontraron establecimientos asociados.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          )
        else
          ..._memberships.map((m) {
            final est     = m['establishments'] as Map<String, dynamic>?;
            final name    = est?['name'] as String? ?? '—';
            final role    = _roleLabel(m['role'] as String?);
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
                        Text('Rol: $role',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        if (canScan || canStats || canManage) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4, runSpacing: 4,
                            children: [
                              if (canScan)   _StaffPermChip('QR lealtad'),
                              if (canStats)  _StaffPermChip('Estadísticas'),
                              if (canManage) _StaffPermChip('Promos'),
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
                const Text(
                  '¿Trabajas en un negocio?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ingresa tu código de invitación',
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
            child: const Text('Unirse',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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

  String get _shareUrl {
    final code = widget.profile.referralCode ?? '';
    return 'https://promofy.fun/r/$code';
  }

  String get _shareText =>
      '¡Únete a Promofy y atrae más clientes a tu negocio!\n'
      'Crea tu cuenta con mi link y ambos ganamos:\n$_shareUrl';

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: _shareUrl));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Link copiado al portapapeles!'),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareLink() async {
    await Share.share(_shareText, subject: 'Únete a Promofy');
  }

  @override
  Widget build(BuildContext context) {
    final code    = widget.profile.referralCode;
    final credits = widget.profile.adCreditsMxn;

    return _Card(
      title: '🎁 Programa de referidos',
      children: [
        // Descripción
        Text(
          'Invita a otros negocios con tu link. Cuando activen una membresía de pago, recibes \$300 MXN en créditos de publicidad.',
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
                    'Créditos ganados',
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
                    _copied ? 'Copiado' : 'Copiar link',
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
                  label: const Text(
                    'Compartir',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
              'Tu link de referido estará disponible en breve.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ),
        ],
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
              const Text(
                'Mis Logros',
                style: TextStyle(
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
                      'Ver todos',
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
                        '${stats.annualVisits} visitas · faltan '
                        '${stats.visitsToNextBadge} para ${stats.nextBadge!.label}',
                        style: TextStyle(
                            fontSize: 11,
                            color:    Colors.grey.shade500),
                      ),
                    ] else ...[
                      Text(
                        '${stats.annualVisits} visitas este año — ¡nivel máximo!',
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
                      '${stats.currentStreakWeeks} sem. en racha',
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
                    'Top ${topPct.toStringAsFixed(0)}% en tu ciudad',
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

  String _mapRole(String? role) {
    switch (role) {
      case 'manager': return 'Gerente';
      case 'cashier': return 'Cajero';
      default:        return 'Personalizado';
    }
  }

  Future<void> _submit() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.length < 6) {
      setState(() => _error = 'El código debe tener 6 caracteres.');
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
          _roleLabel         = _mapRole(result['role'] as String?);
          _isLoading         = false;
        });
      } else {
        setState(() {
          _error     = result['error'] as String? ?? 'Código inválido o expirado.';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() { _error = 'Error de conexión. Intenta de nuevo.'; _isLoading = false; });
      }
    }
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        _accepted ? '¡Bienvenido al equipo!' : 'Unirse a un equipo',
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold,
            color: AppColors.textDark),
      ),
      content: _accepted ? _buildSuccess() : _buildInput(),
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
                child: const Text('Continuar',
                    style: TextStyle(fontWeight: FontWeight.w600)),
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
                      child: const Text('Cancelar'),
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
                          : const Text('Unirme',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
    );
  }

  Widget _buildInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingresa el código de 6 caracteres que te compartió el administrador.',
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

  Widget _buildSuccess() {
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
                  'Rol: $_roleLabel',
                  style: TextStyle(
                      fontSize: 13, color: Colors.green.shade700),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Tu perfil se actualizará al continuar.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
