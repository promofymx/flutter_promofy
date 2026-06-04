import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/repositories/categories_repository.dart';
import '../../data/repositories/promotions_repository.dart';
import '../../data/repositories/business_repository.dart';
import '../../data/repositories/establishments_repository.dart';
import '../../data/repositories/loyalty_repository.dart';
import '../../data/repositories/stats_repository.dart';
import '../../data/models/promotion_model.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/location_permission.dart';
import '../../features/favorites/cubit/favorites_cubit.dart';
import '../../features/favorites/screens/favorites_screen.dart';
import '../../features/home/bloc/home_bloc.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/promo_detail_screen.dart';
import '../../features/lugares/cubit/lugares_cubit.dart';
import '../../features/lugares/screens/lugares_screen.dart';
import '../../features/restaurant/cubit/restaurant_detail_cubit.dart';
import '../../features/restaurant/screens/restaurant_detail_screen.dart';
import '../../features/business/cubit/business_cubit.dart';
import '../../features/business/screens/business_tab_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/superadmin/screens/superadmin_screen.dart';
import '../../features/stamps/cubit/stamps_cubit.dart';
import '../../features/stamps/screens/stamps_screen.dart';
import '../../features/business/cubit/stats_cubit.dart';
import '../../features/home/cubit/ads_display_cubit.dart';
import '../../data/repositories/ads_repository.dart';
import '../../features/payment/screens/payment_result_screen.dart';
import '../../features/auth/screens/reset_password_screen.dart';
import '../../features/profile/screens/logros_screen.dart';
import '../widgets/main_scaffold.dart';

class AppRouter {
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: _GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final location  = state.matchedLocation;

        if (authState is AuthInitial) {
          return location == '/splash' ? null : '/splash';
        }
        if (authState is AuthLoading) return null;

        if (authState is AuthUnauthenticated) {
          return location == '/login' ? null : '/login';
        }
        if (authState is AuthNeedsOnboarding) {
          return location == '/onboarding' ? null : '/onboarding';
        }
        if (authState is AuthNeedsLocationPermission) {
          return location == '/location-permission'
              ? null
              : '/location-permission';
        }
        if (authState is AuthAuthenticated) {
          const authOnlyPaths = [
            '/splash', '/login', '/onboarding', '/location-permission'
          ];
          // Las rutas de resultado de pago se permiten siempre que el usuario esté autenticado
          const paymentPaths = [
            '/payment/success', '/payment/failure', '/payment/pending',
            '/subscription/callback', '/auth/reset-password',
          ];
          if (paymentPaths.contains(location)) return null;
          if (authOnlyPaths.contains(location)) return '/home';
          if (location == '/superadmin' && !authState.profile.isSuperadmin) {
            return '/home';
          }
        }
        return null;
      },
      routes: [
        // ── Rutas sin bottom nav ────────────────────────────────────────────
        GoRoute(
          path: '/splash',
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/location-permission',
          builder: (_, __) => const LocationPermissionScreen(),
        ),

        // ── Resultados de pago (deep links desde promofy.fun) ──────────────
        GoRoute(
          path: '/payment/success',
          builder: (_, __) => const PaymentResultScreen(
              result: PaymentResult.success),
        ),
        GoRoute(
          path: '/payment/failure',
          builder: (_, __) => const PaymentResultScreen(
              result: PaymentResult.failure),
        ),
        GoRoute(
          path: '/payment/pending',
          builder: (_, __) => const PaymentResultScreen(
              result: PaymentResult.pending),
        ),
        GoRoute(
          path: '/subscription/callback',
          builder: (_, __) => const PaymentResultScreen(
              result: PaymentResult.subscriptionCallback),
        ),
        GoRoute(
          path: '/auth/reset-password',
          builder: (_, __) => const ResetPasswordScreen(),
        ),

        // ── Detalle de restaurante (pantalla completa, sin bottom nav) ──────
        GoRoute(
          path: '/restaurant/:id',
          builder: (context, state) {
            final establishmentId   = state.pathParameters['id']!;
            final establishmentName = (state.extra as String?) ?? 'Restaurante';
            final userId = authBloc.state is AuthAuthenticated
                ? (authBloc.state as AuthAuthenticated).user.id
                : null;
            return BlocProvider(
              create: (_) => RestaurantDetailCubit(
                establishmentId:          establishmentId,
                establishmentsRepository: EstablishmentsRepository(),
                promotionsRepository:     PromotionsRepository(),
                userId:                   userId,
              )..load(),
              child: RestaurantDetailScreen(
                  establishmentName: establishmentName),
            );
          },
        ),

        // ── Detalle de promo (pantalla completa, sin bottom nav) ────────────
        GoRoute(
          path: '/promo/:id',
          builder: (context, state) {
            final promo  = state.extra as PromotionModel?;
            if (promo == null) {
              // Fallback seguro si se navega sin modelo (deep link externo)
              return const SplashScreen();
            }
            final userId = authBloc.state is AuthAuthenticated
                ? (authBloc.state as AuthAuthenticated).user.id
                : null;
            return PromoDetailScreen(promo: promo, userId: userId);
          },
        ),

        // ── Mis Logros (pantalla completa, sin bottom nav) ─────────────────
        GoRoute(
          path: '/logros',
          builder: (context, state) {
            final userId = authBloc.state is AuthAuthenticated
                ? (authBloc.state as AuthAuthenticated).user.id
                : (state.extra as String? ?? '');
            return LogrosScreen(userId: userId);
          },
        ),

        // ── Favoritos (pantalla completa, sin bottom nav) ───────────────────
        // Se navega con context.push('/favorites') desde Perfil.
        GoRoute(
          path: '/favorites',
          builder: (context, state) {
            final userId = authBloc.state is AuthAuthenticated
                ? (authBloc.state as AuthAuthenticated).user.id
                : null;
            return BlocProvider(
              create: (_) => FavoritesCubit(
                repository:               PromotionsRepository(),
                establishmentsRepository: EstablishmentsRepository(),
                userId:                   userId ?? '',
              ),
              child: const FavoritesScreen(),
            );
          },
        ),

        // ── Shell con bottom nav ────────────────────────────────────────────
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            final authState      = authBloc.state;
            final userId         = authState is AuthAuthenticated
                ? authState.user.id
                : null;
            final initialRadius  = authState is AuthAuthenticated
                ? authState.profile.searchRadiusKm
                : 25;
            return MultiBlocProvider(
              providers: [
                // HomeBloc — accesible desde todas las pestañas
                BlocProvider(
                  create: (_) => HomeBloc(
                    promotionsRepository: PromotionsRepository(),
                    categoriesRepository: CategoriesRepository(),
                    userId:           userId,
                    initialRadiusKm:  initialRadius,
                  ),
                ),
                // LugaresCubit — pantalla "Lugares" (rama 1)
                BlocProvider(
                  create: (_) => LugaresCubit(
                    repository: EstablishmentsRepository(),
                    userId:     userId,
                  ),
                ),
                // BusinessCubit — panel de negocio
                BlocProvider(
                  create: (_) => BusinessCubit(
                    repository: BusinessRepository(),
                    userId:     userId ?? '',
                  ),
                ),
                // StampsCubit — mis sellos
                BlocProvider(
                  create: (_) => StampsCubit(
                    repository: LoyaltyRepository(),
                    userId:     userId ?? '',
                  ),
                ),
                // StatsCubit — estadísticas del negocio
                BlocProvider(
                  create: (_) => StatsCubit(
                    repository: StatsRepository(),
                    ownerId:    userId ?? '',
                  ),
                ),
                // AdsDisplayCubit — anuncios visibles al usuario (Phase C)
                // La ubicación se obtiene de forma asíncrona para activar
                // el factor distancia (40 %) del ranking de anuncios.
                BlocProvider(
                  create: (_) {
                    final cubit = AdsDisplayCubit(repository: AdsRepository());
                    unawaited(_loadAdsWithLocation(cubit));
                    return cubit;
                  },
                ),
              ],
              child: MainScaffold(navigationShell: navigationShell),
            );
          },
          branches: [
            // Rama 0 — Inicio
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (_, __) => const HomeScreen(),
                ),
              ],
            ),

            // Rama 1 — Lugares
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/lugares',
                  builder: (_, __) => const LugaresScreen(),
                ),
              ],
            ),

            // Rama 2 — Perfil
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (_, __) => const ProfileScreen(),
                ),
              ],
            ),

            // Rama 3 — Mi negocio
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/business',
                  builder: (_, __) => const BusinessTabScreen(),
                ),
              ],
            ),

            // Rama 4 — Mis Sellos
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/stamps',
                  builder: (_, __) => const StampsScreen(),
                ),
              ],
            ),

            // Rama 5 — Superadmin
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/superadmin',
                  builder: (_, __) => const SuperadminScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Carga de anuncios con ubicación (fire-and-forget) ───────────────────────
//
// Intenta obtener la última posición conocida (instantáneo desde caché del OS)
// o la posición actual con timeout de 4 s. Llama cubit.load() una sola vez.
// Si el permiso está denegado o hay error, carga sin coordenadas → factor
// distancia neutro (50/100) en el ranking de relevancia.
Future<void> _loadAdsWithLocation(AdsDisplayCubit cubit) async {
  double? lat, lng;
  try {
    final permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        lat = last.latitude;
        lng = last.longitude;
      } else {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit:        const Duration(seconds: 4),
        );
        lat = pos.latitude;
        lng = pos.longitude;
      }
    }
  } catch (_) {
    // Sin ubicación — el factor distancia será neutro (50)
  }
  if (!cubit.isClosed) cubit.load(lat: lat, lng: lng);
}

// ─── Stream helper para refrescar el router con cambios de auth ───────────────

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription =
        stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
