package mx.promofy.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createHighImportanceChannel()
    }

    /**
     * Crea un canal de notificación de importancia ALTA para que los push de
     * Promofy se muestren como banner (heads-up) con sonido y vibración, en vez
     * de entrar silenciosos al canal de respaldo de Firebase.
     * El AndroidManifest lo declara como canal por defecto de FCM.
     */
    private fun createHighImportanceChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "promofy_high",
                "Promociones y avisos",
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = "Promos, lealtad y avisos de Promofy"
                enableVibration(true)
                enableLights(true)
            }
            val manager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }
}
