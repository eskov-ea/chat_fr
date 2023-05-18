package com.example.MCFEF.wakeup_features

import android.app.*
import android.content.Context
import android.content.Context.NOTIFICATION_SERVICE
import android.content.Intent
import android.os.Build
import android.widget.Toast
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.work.Worker
import androidx.work.WorkerParameters
import com.example.MCFEF.IncomingCallActivity


class SipWorkManager constructor (val context: Context, workerParams: WorkerParameters) : Worker(context, workerParams) {

    val CHANNEL_NAME = "incoming_call_notification_channel"
    val CHANNEL_ID = "341893"


    private fun buildNotification(): Notification {
        Toast.makeText(context, "Try to show headsup", Toast.LENGTH_LONG).show()

        val importance = NotificationManager.IMPORTANCE_HIGH
        val channel = NotificationChannel("CHANNEL_ID", "CHANNEL_NAME", importance).apply {
            description = "descriptionText"
        }

        val fullScreenIntent = Intent(context, IncomingCallActivity::class.java)
        val fullScreenPendingIntent: PendingIntent = PendingIntent.getActivity(context, 0, fullScreenIntent, PendingIntent.FLAG_UPDATE_CURRENT)
        val notificationManager: NotificationManager = context.getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannel(channel)
        val notificationBuilder = NotificationCompat.Builder(context, "CHANNEL_NAME")
                .setContentTitle("Incoming call")
                .setContentText("116")
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setCategory(NotificationCompat.CATEGORY_CALL) // Use a full-screen intent only for the highest-priority alerts where you
                // have an associated activity that you would like to launch after the user
                // interacts with the notification. Also, if your app targets Android 10
                // or higher, you need to request the USE_FULL_SCREEN_INTENT permission in
                // order for the platform to invoke this notification.
                .setFullScreenIntent(fullScreenPendingIntent, true)
        notificationBuilder.setAutoCancel(true)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            notificationManager.createNotificationChannel(NotificationChannel("CHANNEL_ID", "CHANNEL_NAME", NotificationManager.IMPORTANCE_HIGH))
            notificationBuilder.setChannelId("CHANNEL_ID")
        }
        return notificationBuilder.build()
    }

    override fun doWork(): Result {
        try {
            Toast.makeText(context, "doWork", Toast.LENGTH_LONG).show()
            val notification: Notification = buildNotification()
            NotificationManagerCompat.from(context).notify(12345, notification)
        } catch (err: Error) {
            Toast.makeText(context, "Error happened:  $err", Toast.LENGTH_LONG).show()
        }

        return Result.success ();
    }

}