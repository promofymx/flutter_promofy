import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'core/cubit/locale_cubit.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'l10n/app_localizations.dart';
import 'data/repositories/auth_repository.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';

class PromofyApp extends StatefulWidget {
  const PromofyApp({super.key});

  @override
  State<PromofyApp> createState() => _PromofyAppState();
}

class _PromofyAppState extends State<PromofyApp> {
  late final AuthBloc    _authBloc;
  late final LocaleCubit _localeCubit;
  late final GoRouter    _router;
  StreamSubscription<Uri>? _deepLinkSub;

  @override
  void initState() {
    super.initState();
    // Control de idioma (carga la preferencia guardada; null = automático)
    _localeCubit = LocaleCubit()..load();
    // Crea el BLoC una sola vez y verifica la sesión al arrancar
    _authBloc = AuthBloc(authRepository: AuthRepository())
      ..add(AuthStarted());
    // Crea el router pasándole el BLoC para que pueda redirigir
    _router = AppRouter.createRouter(_authBloc);
    // Registrar el router en el servicio de notificaciones para deep links
    NotificationService.instance.setRouter(_router);
    // Escuchar deep links cuando la app ya está abierta
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _deepLinkSub = AppLinks().uriLinkStream.listen((uri) async {
      // Si el fragmento contiene un access_token de Supabase (ej. recuperación
      // de contraseña), intercambiamos el token antes de navegar.
      // promofy:///auth/reset-password#access_token=...&type=recovery
      final fragment = uri.fragment;
      if (fragment.contains('access_token') || fragment.contains('type=recovery')) {
        try {
          await Supabase.instance.client.auth.getSessionFromUrl(uri);
        } catch (_) {}
      }
      // promofy:///payment/success → path = /payment/success
      final path = uri.path.isNotEmpty ? uri.path : '/home';
      _router.go(path);
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    _authBloc.close(); // libera recursos cuando la app se cierra
    _localeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider.value(value: _localeCubit),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Guardar token FCM al autenticarse
            NotificationService.instance.saveToken(state.user.id);
          } else if (state is AuthUnauthenticated) {
            // No podemos eliminar el token sin el userId — se limpia en signOut
          }
        },
        child: BlocBuilder<LocaleCubit, Locale?>(
          builder: (context, locale) => MaterialApp.router(
            title: 'Promofy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: _router,
            // Idioma: null = automático (idioma del dispositivo); si no coincide
            // con uno soportado, cae a español.
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            localeResolutionCallback: (deviceLocale, supported) {
              if (locale != null) return locale;
              if (deviceLocale != null) {
                for (final l in supported) {
                  if (l.languageCode == deviceLocale.languageCode) return l;
                }
              }
              return const Locale('es');
            },
          ),
        ),
      ),
    );
  }
}