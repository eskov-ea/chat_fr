package com.example.MCFEF

import android.annotation.SuppressLint
import android.app.*
import android.content.Context
import android.content.Context.NOTIFICATION_SERVICE
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.widget.Toast
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import androidx.core.content.ContextCompat.getSystemService
import androidx.work.Worker
import androidx.work.WorkerParameters


class SipForegroundService(context: Context, workerParams: WorkerParameters) : Worker(context, workerParams) {

    val context = context
    val CHANNEL_NAME = "incoming_call_notification_channel"
    val CHANNEL_ID = "341893"
//    override fun onBind(p0: Intent?): IBinder? {
//        return null
//    }

//    @SuppressLint("MissingPermission")
//    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
//        val notification: Notification = buildNotification()
//        startService(intent)
//        startForeground(1, notification)
//        sendBroadcast(Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS))
//        return START_NOT_STICKY
//    }

    private fun buildNotification(): Notification {
        val fullScreenIntent = Intent(context, IncomingCallActivity::class.java)
        val fullScreenPendingIntent: PendingIntent = PendingIntent.getActivity(context, 0, fullScreenIntent, PendingIntent.FLAG_UPDATE_CURRENT)
        val notificationManager: NotificationManager = context.getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        val notificationBuilder = NotificationCompat.Builder(context, CHANNEL_NAME)
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
            notificationManager.createNotificationChannel(NotificationChannel(CHANNEL_ID, CHANNEL_NAME, NotificationManager.IMPORTANCE_HIGH))
            notificationBuilder.setChannelId(CHANNEL_ID)
        }
        return notificationBuilder.build()
    }

    override fun doWork(): Result {
        Toast.makeText(context, "doWork", Toast.LENGTH_LONG).show()
        val notification: Notification = buildNotification()
        NotificationManagerCompat.from(context).notify(12345, notification)

        return Result.success ();
    }

}