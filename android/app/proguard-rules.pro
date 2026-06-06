# ───────────────────────────────────────────────────────────────
# Promofy — reglas ProGuard/R8 para build release con minify+shrink
# ───────────────────────────────────────────────────────────────

# Flutter engine y plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Play Core (componentes diferidos de Flutter) — evita que R8 los elimine
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Firebase (Core + Messaging / push)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play Services + Google Sign-In
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ML Kit barcode (mobile_scanner — escaneo de QR)
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Atributos necesarios para reflexión / stack traces legibles
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable
