import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/filter_model.dart';
import '../../data/models/promotion_model.dart';
import '../../main.dart';

/// Servicio singleton que gestiona permisos, token FCM y
/// recepción de mensajes en primer plano.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;

  /// Evita registrar el listener de onTokenRefresh más de una vez.
  bool _refreshListenerSet = false;

  GoRouter? _router;
  void setRouter(GoRouter router) => _router = router;

  /// Filtro pendiente generado por un tap en notificación de tipo 'birthday'.
  /// HomeScreen lo consume en initState (post-frame callback) y lo limpia.
  HomeFilters? pendingFilter;
  void clearPendingFilter() => pendingFilter = null;

  // ── Inicialización (llamar una vez en main) ───────────────────────────────

  Future<void> init() async {
    // Pedir permisos (en iOS/web muestra el diálogo del sistema)
    await _messaging.requestPermission(
      alert:       true,
      badge:       true,
      sound:       true,
      provisional: false,
    );

    // En Android 13+ también se necesita el permiso POST_NOTIFICATIONS;
    // firebase_messaging lo gestiona automáticamente con requestPermission().

    // Mostrar notificaciones en foreground en iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Escuchar mensajes mientras la app está abierta
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Escuchar tap en notificación cuando la app estaba en background
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);

    // Revisar si la app fue abierta desde una notificación (estaba cerrada)
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _onNotificationTap(initial);
  }

  // ── Guardar token en Supabase ─────────────────────────────────────────────

  Future<void> saveToken(String userId) async {
    final platform = kIsWeb
        ? 'web'
        : Platform.isIOS
            ? 'ios'
            : 'android';

    // Registrar SIEMPRE el listener ANTES de cualquier espera. En iOS el token
    // FCM puede tardar >8s en estar listo (depende del token de APNs); si solo
    // confiáramos en el getToken() inmediato, al rendirse por timeout el token
    // se perdería para siempre. Con el listener registrado de antemano, en
    // cuanto el token llegue (aunque sea tarde) se guarda igual.
    if (!_refreshListenerSet) {
      _refreshListenerSet = true;
      _messaging.onTokenRefresh.listen((newToken) {
        _upsertToken(userId, newToken, platform);
      });
    }

    try {
      // En iOS, getToken() requiere que el token de APNs ya esté disponible.
      // Esperamos hasta ~20s (antes eran 8 y se rendía demasiado pronto).
      if (!kIsWeb && Platform.isIOS) {
        var apns  = await _messaging.getAPNSToken();
        var tries = 0;
        while (apns == null && tries < 20) {
          await Future<void>.delayed(const Duration(seconds: 1));
          apns = await _messaging.getAPNSToken();
          tries++;
        }
        if (apns == null) {
          debugPrint('⚠️ APNs aún no listo tras 20s; se guardará vía onTokenRefresh cuando llegue.');
          return; // el listener de arriba lo capturará
        }
      }

      final token = kIsWeb
          ? await _messaging.getToken(
              vapidKey: 'YOUR_VAPID_KEY', // reemplazar en Phase web
            )
          : await _messaging.getToken();
      if (token != null) await _upsertToken(userId, token, platform);
    } catch (e) {
      debugPrint('⚠️ NotificationService.saveToken error: $e');
    }
  }

  /// Guarda/actualiza el token del dispositivo en Supabase (idempotente).
  Future<void> _upsertToken(String userId, String token, String platform) async {
    try {
      await supabase.from('device_tokens').upsert(
        {
          'user_id':    userId,
          'token':      token,
          'platform':   platform,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'token',
      );
    } catch (e) {
      debugPrint('⚠️ NotificationService._upsertToken error: $e');
    }
  }

  /// Elimina el token del dispositivo actual al cerrar sesión.
  Future<void> removeToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await supabase
          .from('device_tokens')
          .delete()
          .eq('user_id', userId)
          .eq('token', token);
    } catch (e) {
      debugPrint('⚠️ NotificationService.removeToken error: $e');
    }
  }

  // ── Handlers internos ─────────────────────────────────────────────────────

  void _onForegroundMessage(RemoteMessage message) {
    debugPrint('🔔 Notificación foreground: ${message.notification?.title}');
    // Aquí puedes mostrar un SnackBar/Dialog si quieres comportamiento custom.
    // Por defecto en Android en background el sistema ya la muestra;
    // en foreground firebase_messaging no la muestra sola —
    // setForegroundNotificationPresentationOptions lo hace en iOS.
  }

  Future<void> _onNotificationTap(RemoteMessage message) async {
    debugPrint('👆 Tap en notificación: ${message.data}');

    // Registrar apertura si el payload incluye notification_log_id
    final logId  = message.data['notification_log_id'] as String?;
    final userId = supabase.auth.currentUser?.id;
    if (logId != null && logId.isNotEmpty && userId != null) {
      try {
        await supabase.from('notification_opens').upsert(
          {
            'notification_log_id': logId,
            'user_id':             userId,
          },
          onConflict: 'notification_log_id,user_id',
        );
      } catch (e) {
        debugPrint('⚠️ NotificationService.recordOpen error: $e');
      }
    }

    // Deep link: cargar promo y navegar
    final type              = message.data['type']               as String?;
    final promoId           = message.data['promo_id']           as String?;
    final establishmentId   = message.data['establishment_id']   as String?;
    final establishmentName = message.data['establishment_name'] as String? ?? '';

    if (_router == null) return;

    // Notificaciones de cumpleaños: ir al home con filtro de cumpleaños activo
    if (type == 'birthday') {
      pendingFilter = const HomeFilters(birthdayOnly: true);
      _router!.go('/home');
      return;
    }

    if (promoId != null) {
      try {
        final data = await supabase
            .from('promotions')
            .select('id, name, description, type, active_days, start_time, end_time, flash_starts_at, flash_ends_at, photo_url, is_adult_only, category_id, is_featured, establishment_id, created_at')
            .eq('id', promoId)
            .single();

        final promo = PromotionModel.fromTable(
          Map<String, dynamic>.from(data as Map),
          establishmentName: establishmentName,
        );
        _router!.push('/promo/$promoId', extra: promo);
      } catch (e) {
        debugPrint('⚠️ NotificationService deep link error: $e');
        // Fallback al restaurante
        if (establishmentId != null) {
          _router!.push('/restaurant/$establishmentId', extra: establishmentName);
        }
      }
    } else if (establishmentId != null) {
      _router!.push('/restaurant/$establishmentId', extra: establishmentName);
    }
  }
}
