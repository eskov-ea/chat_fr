package com.example.MCFEF.wakeup_features

import android.content.Context
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.content.ContextCompat
import com.example.MCFEF.R

class CustomNotification(private val packageName : String, val context: Context) {

    fun notifyMember() {
        this.showNotification()
    }

    private fun createNotificationBuilder(): NotificationCompat.Builder {
        // Layouts for the custom notification

        val notificationLayout = RemoteViews(packageName, R.layout.notification_collapsed)
        val notificationLayoutExpanded = RemoteViews(packageName, R.layout.notification_expanded)

        // Apply the layouts to the notification builder
        return NotificationCompat.Builder(context, "custom_channel")
                .setSmallIcon(R.drawable.ic_decline)
                .setColor(ContextCompat.getColor(context, R.color.accept))
                .setStyle(NotificationCompat.DecoratedCustomViewStyle())
                .setCustomContentView(notificationLayout)
                .setCustomBigContentView(notificationLayoutExpanded)
    }

    private fun showNotification() {
        val notification = createNotificationBuilder()

        // Show the notification with notificationId.
        val uniqueNotificationId = 45648
        with(NotificationManagerCompat.from(context)) {
            notify(uniqueNotificationId, notification.build())
        }
    }
}