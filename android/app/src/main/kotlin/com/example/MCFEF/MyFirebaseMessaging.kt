package com.example.MCFEF


import android.content.ComponentName
import android.content.Intent
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import io.flutter.Log

class MyFirebaseMessaging: FirebaseMessagingService() {

    override fun onNewToken(token: String) {
        Log.d("FirebaseMessaging refresh token", "Refreshed token: $token")
    }

    override fun onMessageReceived(message: RemoteMessage) {

        Log.d("MyFirebaseMessaging", "[Push] RECEIVED")

        if (!message.data.isEmpty()) {
            val intent = Intent()
            intent.action = "org.linphone.core.action.PUSH_RECEIVED"

            val pm = packageManager
            val matches = pm.queryBroadcastReceivers(intent, 0)

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