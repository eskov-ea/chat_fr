package com.cashalot.MCFEF


import android.content.ComponentName
import android.content.Intent
import android.widget.Toast
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import io.flutter.Log

class MyFirebaseMessaging: FirebaseMessagingService() {

    override fun onNewToken(token: String) {
        Log.d("FirebaseMessaging refresh token", "Refreshed token: $token")
    }

    override fun onMessageReceived(message: RemoteMessage) {

//        Toast.makeText(this, "[Push] RECEIVED Firebase", Toast.LENGTH_SHORT).show()
        Log.d("MyFirebaseMessaging", "${message.messageId} ; ${message.notification}")

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