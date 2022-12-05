package com.example.MCFEF


import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.ContentValues.TAG
import android.content.Context
import android.graphics.Color
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import android.util.Log
import android.widget.Toast
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage


class MyFirebaseMessagingService: FirebaseMessagingService(){

    override fun onNewToken(token: String) {
        Log.d("FirebaseMessaging refresh token", "Refreshed token: $token")

    }

//    override fun onMessageReceived(message: RemoteMessage) {
//        Log.w("MY_NOTIFICATION", "RECEIVED")
//        // TODO: Handle FCM messages here.
//        Log.d(TAG, "From: ${message.from}")
//
//        // Check if message contains a data payload.
////        Log.d(TAG, "Message data payload: ${message.data}")
////        Log.d(TAG, "Message notification payload: ${message.notification?.title} / ${message.notification?.body}")
//        if (message.data.isNotEmpty()) {
//
//            Log.d(TAG, "Message data payload: ${message.data}")
//            if ( MainActivity.core != null) {
//
//                var builder = NotificationCompat.Builder(this, "default_notification_channel_id")
//                        .setSmallIcon(R.drawable.bg_button_accept)
//                        .setContentTitle("Notification from script")
//                        .setContentText("I create a notification")
//                        .setPriority(NotificationCompat.PRIORITY_DEFAULT)
//                with(NotificationManagerCompat.from(this)) {
//                    // notificationId is a unique int for each notification that you must define
//                    notify(112211, builder.build())
//                }
//                PushBroadcastReceiver()
//                // For long-running tasks (10 seconds or more) use WorkManager.
////                Log.d(TAG, "Message data payload ")
//            } else {
//                // Handle message within 10 seconds
//            }
//        }
//
//        if (message.notification?.channelId == "CALLKIT_NOTIFICATION_CHANNEL") {
//
//        }
//    }


    private fun createNotificationChannel() {
        io.flutter.Log.w("MY_NOTIFICATION", "CREATING A NOTIFICATION CHANNEL")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "New message notification channel"
            val descriptionText = "This channel responsible for operate push notification of new message received"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val mChannel = NotificationChannel("default_notification_channel_id", name, importance)
            mChannel.description = descriptionText
            mChannel.lightColor = Color.GREEN
            mChannel.enableLights(true)
            val audioAttributes = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build()
            mChannel.setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION), audioAttributes)

            val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(mChannel)
        }
    }


}