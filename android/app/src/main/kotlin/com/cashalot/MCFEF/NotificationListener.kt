package com.cashalot.MCFEF


import android.content.Intent
import android.os.IBinder
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import io.flutter.Log


class NotificationListener: NotificationListenerService() {

    val TAG: String = "NOTIFICATION_LISTENER"

    override fun onCreate() {
        super.onCreate()

    }

    override fun onBind(intent: Intent?): IBinder? {
        return super.onBind(intent)
    }

    override fun onNotificationPosted(newNotification: StatusBarNotification) {
        Log.i(
            TAG,
            "-------- onNotificationPosted(): " + "ID :" + newNotification.id + "\t" + newNotification.notification.tickerText + "\t" + newNotification.packageName
        )
    }

    override fun onNotificationRemoved(removedNotification: StatusBarNotification) {
        Log.i(
            TAG,
            "-------- onNotificationRemoved() :" + "ID :" + removedNotification.id + "\t" + removedNotification.notification.tickerText + "\t" + removedNotification.packageName
        )
    }

    fun fetchCurrentNotifications() {
        Log.v(TAG, "===== Notification List START ====")

        val activeNotnCount = this.activeNotifications.size

        if (activeNotnCount > 0) {
            for (count in 0..activeNotnCount) {
                val sbn = this.activeNotifications[count]
                Log.v(TAG, "#" + count.toString() + " Package: " + sbn.packageName + "\n")
            }
        } else {
            Log.v(TAG, "No active Notn found")
        }

        Log.v(TAG, "===== Notification List END====")
    }

    fun getMyActiveNotifications() {

        val result = super.getActiveNotifications()
        Log.v("NOTIFICATION_LISTENER", "")

        Log.v("NOTIFICATION_LISTENER", "$result")
    }
}