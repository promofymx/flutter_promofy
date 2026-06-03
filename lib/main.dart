import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'app.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';

/// Handler de mensajes en background — debe ser función de nivel superior.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // El sistema ya muestra la notificación; aquí solo lógica extra si se necesita.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa datos de localización para DateFormat con español México
  await initializeDateFormatting('es_MX', null);

  // Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inicialización explícita de webview_flutter (solo en móvil)
  if (!kIsWeb) {
    if (Platform.isAndroid) {
      WebViewPlatform.instance = AndroidWebViewPlatform();
    } else if (Platform.isIOS) {
      WebViewPlatform.instance = WebKitWebViewPlatform();
    }
  }

  await Supabase.initialize(
    url: 'https://hfmvelirrcawsxaudhfl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmbXZlbGlycmNhd3N4YXVkaGZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk5MDcwNzksImV4cCI6MjA5NTQ4MzA3OX0.sQjtFkGbk_2l6K9j2Mjm2CQGfG8VdyoAcPB9uDVs6vc',
  );

  // Inicializar servicio de notificaciones (permisos + listeners foreground)
  await NotificationService.instance.init();

  runApp(const PromofyApp());
}

final supabase = Supabase.instance.client;