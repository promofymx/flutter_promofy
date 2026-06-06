import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/home/cubit/ads_display_cubit.dart';
import '../../features/home/cubit/ads_display_state.dart';
import '../../features/home/widgets/ad_splash_overlay.dart';
import '../../features/lugares/cubit/lugares_cubit.dart';
import '../../data/models/ad_display_model.dart';

// Mapeo entre índice de rama (GoRouter) e ítem del nav bar.
class _NavDef {
  final int      branchIndex;
  final String   label;
  final IconData icon;
  final IconData selectedIcon;

  const _NavDef({
    required this.branchIndex,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

/// Shell que envuelve las pestañas principales.
/// GoRouter's [StatefulNavigationShell] maneja el estado de cada rama.
class MainScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const MainScaffold({super.key, required this.navigationShell});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with WidgetsBindingObserver {
  /// Evita re-mostrar el splash dentro del mismo ciclo de presentación.
  bool _splashShown = false;

  /// Última vez que se mostró el splash, para aplicar un margen entre apariciones.
  DateTime? _lastSplashAt;

  /// Margen mínimo entre apariciones del splash al regresar a la app.
  /// Permite "varios por día" sin volverse molesto.
  static const Duration _splashCooldown = Duration(minutes: 10);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    final last = _lastSplashAt;
    final cooldownPassed =
        last == null || DateTime.now().difference(last) >= _splashCooldown;
    if (!cooldownPassed) return;
    _reloadAndShowSplash();
  }

  /// Recarga anuncios (dispara impresiones; el servidor deduplica por día) y
  /// vuelve a mostrar el splash al regresar a la app.
  Future<void> _reloadAndShowSplash() async {
    final cubit = context.read<AdsDisplayCubit>();
    await cubit.load();
    if (!mounted) return;
    _splashShown = false;
    _maybeShowSplash(context, cubit.state);
  }

  void _maybeShowSplash(BuildContext context, AdsDisplayState state) {
    if (_splashShown || state.splashAds.isEmpty) return;
    _splashShown = true;
    _lastSplashAt = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final AdDisplayModel ad    = state.splashAds.first;
      final AdsDisplayCubit cubit = context.read<AdsDisplayCubit>();
      showDialog<void>(
        context:            context,
        barrierDismissible: true,
        barrierColor:       Colors.black.withAlpha(160),
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:    const EdgeInsets.symmetric(
              horizontal: 28, vertical: 80),
          // Phase D: pasar callbacks de tracking al overlay.
          child: AdSplashOverlay(
            ad:           ad,
            onImpression: () => cubit.trackImpression(ad.id),
            onClick:      () => cubit.trackClick(ad.id),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdsDisplayCubit, AdsDisplayState>(
      listenWhen: (prev, next) => !prev.loaded && next.loaded,
      listener:   (context, state) => _maybeShowSplash(context, state),
      child: BlocBuilder<AuthBloc, AuthState>(
        buildWhen: (prev, curr) {
          final prevOwner = prev is AuthAuthenticated && prev.profile.isBusinessOwner;
          final currOwner = curr is AuthAuthenticated && curr.profile.isBusinessOwner;
          final prevAdmin = prev is AuthAuthenticated && prev.profile.isSuperadmin;
          final currAdmin = curr is AuthAuthenticated && curr.profile.isSuperadmin;
          final prevStaff = prev is AuthAuthenticated && prev.profile.isStaff;
          final currStaff = curr is AuthAuthenticated && curr.profile.isStaff;
          return prevOwner != currOwner || prevAdmin != currAdmin ||
              prevStaff != currStaff;
        },
        builder: (context, authState) {
          final isBusinessOwner =
              authState is AuthAuthenticated && authState.profile.isBusinessOwner;
          final isSuperadmin =
              authState is AuthAuthenticated && authState.profile.isSuperadmin;
          final isStaff =
              authState is AuthAuthenticated && authState.profile.isStaff;

          final navDefs = <_NavDef>[
            const _NavDef(
              branchIndex:  0,
              label:        'Inicio',
              icon:         Icons.home_outlined,
              selectedIcon: Icons.home,
            ),
            const _NavDef(
              branchIndex:  1,
              label:        'Lugares',
              icon:         Icons.map_outlined,
              selectedIcon: Icons.map,
            ),
            const _NavDef(
              branchIndex:  2,
              label:        'Perfil',
              icon:         Icons.person_outline,
              selectedIcon: Icons.person,
            ),
            if (isBusinessOwner || isStaff)
              const _NavDef(
                branchIndex:  3,
                label:        'Mi negocio',
                icon:         Icons.store_outlined,
                selectedIcon: Icons.store,
              ),
            const _NavDef(
              branchIndex:  4,
              label:        'Visitas',
              icon:         Icons.loyalty_outlined,
              selectedIcon: Icons.loyalty,
            ),
            if (isSuperadmin)
              const _NavDef(
                branchIndex:  5,
                label:        'Admin',
                icon:         Icons.admin_panel_settings_outlined,
                selectedIcon: Icons.admin_panel_settings,
              ),
          ];

          final currentBranch = widget.navigationShell.currentIndex;
          final visualIndex = () {
            final idx =
                navDefs.indexWhere((d) => d.branchIndex == currentBranch);
            return idx >= 0 ? idx : 0;
          }();

          return Scaffold(
            body: widget.navigationShell,
            bottomNavigationBar: NavigationBar(
              backgroundColor: Colors.white,
              indicatorColor:  AppColors.primary.withAlpha(25),
              selectedIndex:   visualIndex,
              labelBehavior:
                  NavigationDestinationLabelBehavior.alwaysShow,
              onDestinationSelected: (idx) {
                final def = navDefs[idx];
                // Refresca Lugares al entrar en esa pestaña
                if (def.branchIndex == 1 &&
                    def.branchIndex !=
                        widget.navigationShell.currentIndex) {
                  context.read<LugaresCubit>().refresh();
                }
                widget.navigationShell.goBranch(
                  def.branchIndex,
                  initialLocation: def.branchIndex ==
                      widget.navigationShell.currentIndex,
                );
              },
              destinations: navDefs
                  .map((d) => NavigationDestination(
                        icon: Icon(d.icon),
                        selectedIcon:
                            Icon(d.selectedIcon, color: AppColors.primary),
                        label: d.label,
                      ))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
