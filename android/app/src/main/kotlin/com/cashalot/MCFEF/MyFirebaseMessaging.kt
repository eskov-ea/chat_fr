package com.cashalot.MCFEF


import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ResolveInfo
import android.os.Build
import android.widget.Toast
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import io.flutter.Log

class MyFirebaseMessaging: FirebaseMessagingService() {

    override fun onNewToken(token: String) {
        Log.d("FirebaseMessaging refresh token", "Refreshed token: $token")
    }

    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)
        Log.v("MyFirebaseMessaging. We got PUSH", "${message.messageId} ; ${message.notification}")

        if (!message.data.isEmpty()) {
            val intent = Intent()
            intent.action = "org.linphone.core.action.PUSH_RECEIVED"

            val pm = packageManager
            val matches: List<ResolveInfo> = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.queryIntentActivities(intent, PackageManager.ResolveInfoFlags.of(PackageManager.MATCH_ALL.toLong()))
            } else {
                pm.queryBroadcastReceivers(intent, 0)
            }

            for (resolveInfo in matches) {
                val packageName = resolveInfo.activityInfo.applicationInfo.packageName
                if (packageName == getPackageName()) {
                    val explicit = Intent(intent)
                    val cn = ComponentName(packageName, resolveInfo.activityInfo.name)
                    explicit.component = cn
                    sendBroadcast(explicit)
                    break
                }
            }
        }

    }
}