import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controla el idioma de la app.
///
/// Estado `null` = "automático" (usa el idioma del dispositivo).
/// Un [Locale] concreto = idioma elegido manualmente por el usuario.
/// La elección se persiste en SharedPreferences.
class LocaleCubit extends Cubit<Locale?> {
  static const _key = 'app_locale';

  LocaleCubit() : super(null);

  /// Carga el idioma guardado (si lo hay) al iniciar la app.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_key);
      if (code != null && code.isNotEmpty) {
        emit(Locale(code));
      }
    } catch (_) {/* sin preferencia → automático */}
  }

  /// Cambia el idioma. Pasa `null` para volver a "automático".
  Future<void> setLocale(Locale? locale) async {
    emit(locale);
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.remove(_key);
      } else {
        await prefs.setString(_key, locale.languageCode);
      }
    } catch (_) {/* no bloquear la UI si falla el guardado */}
  }
}
