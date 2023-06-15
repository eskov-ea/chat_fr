package com.example.MCFEF.calls_manager

import android.app.*
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.view.View
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.example.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_ACTION_COLOR
import com.example.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_HANDLE
import com.example.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_ID
import com.example.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_IS_SHOW_CALLBACK
import com.example.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_NAME_CALLER
import com.example.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_TEXT_CALLBACK
import com.example.MCFEF.R
import com.hiennv.flutter_callkit_incoming.CallkitIncomingActivity

import android.app.KeyguardManager as KeyguardManager1

class CallsNotificationManager(private val context: Context) {

    companion object {
        const val EXTRA_TIME_START_CALL = "EXTRA_TIME_START_CALL"
    }

    private lateinit var notificationBuilder: NotificationCompat.Builder
    private var notificationViews: RemoteViews? = null
    private var notificationHeadsUpViews: RemoteViews? = null
    private var notificationId: Int = 96962


    fun showIncomingNotification(data: Bundle) {
        data.putLong(EXTRA_TIME_START_CALL, System.currentTimeMillis())

        notificationId = data.getString(EXTRA_CALLKIT_ID, "mcfef_calls").hashCode()
        createNotificationChanel()

        notificationBuilder = NotificationCompat.Builder(context, "MCFEF_INCOMING_CALL")
        notificationBuilder.setAutoCancel(false)
        notificationBuilder.setChannelId("MCFEF_INCOMING_CALL")
        notificationBuilder.setDefaults(NotificationCompat.DEFAULT_VIBRATE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            notificationBuilder.setCategory(NotificationCompat.CATEGORY_CALL)
            notificationBuilder.priority = NotificationCompat.PRIORITY_MAX
        }
        notificationBuilder.setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
        notificationBuilder.setOngoing(true)
        notificationBuilder.setWhen(0)
        notificationBuilder.setTimeoutAfter(data.getLong(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_DURATION, 0L))
        notificationBuilder.setOnlyAlertOnce(true)
        notificationBuilder.setSound(null)
        notificationBuilder.setFullScreenIntent(
                getActivityPendingIntent(notificationId, data), true
        )
        notificationBuilder.setContentIntent(getActivityPendingIntent(notificationId, data))
        notificationBuilder.setDeleteIntent(getTimeOutPendingIntent(notificationId, data))
        val typeCall = data.getInt(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TYPE, -1)
        var smallIcon = context.applicationInfo.icon
        if (typeCall > 0) {
            smallIcon = R.drawable.ic_video
        } else {
            if (smallIcon >= 0) {
                smallIcon = R.drawable.ic_accept
            }
        }
        notificationBuilder.setSmallIcon(smallIcon)
        val actionColor = data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_ACTION_COLOR, "#4CAF50")
        try {
            notificationBuilder.color = Color.parseColor(actionColor)
        } catch (error: Exception) {
        }
        notificationBuilder.setChannelId("MCFEF_INCOMING_CALL")
        notificationBuilder.priority = NotificationCompat.PRIORITY_MAX
        val isCustomNotification = data.getBoolean(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_IS_CUSTOM_NOTIFICATION, false)
        if (isCustomNotification) {
            notificationViews =
                    RemoteViews(context.packageName, R.layout.layout_custom_notification)
            notificationHeadsUpViews = RemoteViews(context.packageName, R.layout.layout_custom_notification_heads_up)
            notificationViews?.setTextViewText(
                    R.id.tvNameCaller,
                    data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_NAME_CALLER, "")
            )
            notificationHeadsUpViews?.setTextViewText(
                    R.id.tvNameCaller,
                    data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_NAME_CALLER, "")
            )
            notificationViews?.setTextViewText(
                    R.id.tvNumber,
                    data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_HANDLE, "")
            )
            notificationHeadsUpViews?.setTextViewText(
                    R.id.tvNumber,
                    data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_HANDLE, "")
            )
            notificationViews?.setOnClickPendingIntent(
                    R.id.llDecline,
                    getDeclinePendingIntent(notificationId, data)
            )
            notificationHeadsUpViews?.setOnClickPendingIntent(
                    R.id.llDecline,
                    getDeclinePendingIntent(notificationId, data)
            )
            val textDecline = data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_DECLINE, "")
            notificationViews?.setTextViewText(
                    R.id.tvDecline,
                    if (TextUtils.isEmpty(textDecline)) context.getString(R.string.text_decline) else textDecline
            )
            notificationHeadsUpViews?.setTextViewText(
                    R.id.tvDecline,
                    if (TextUtils.isEmpty(textDecline)) context.getString(R.string.text_decline) else textDecline
            )
            notificationViews?.setOnClickPendingIntent(
                    R.id.llAccept,
                    getAcceptPendingIntent(notificationId, data)
            )
            notificationHeadsUpViews?.setOnClickPendingIntent(
                    R.id.llAccept,
                    getAcceptPendingIntent(notificationId, data)
            )
            val textAccept = data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_ACCEPT, "")
            notificationViews?.setTextViewText(
                    R.id.tvAccept,
                    if (TextUtils.isEmpty(textAccept)) context.getString(R.string.text_accept) else textAccept
            )
            notificationHeadsUpViews?.setTextViewText(
                    R.id.tvAccept,
                    if (TextUtils.isEmpty(textAccept)) context.getString(R.string.text_accept) else textAccept
            )

            notificationBuilder.setStyle(NotificationCompat.DecoratedCustomViewStyle())
            notificationBuilder.setCustomContentView(notificationHeadsUpViews)
            notificationBuilder.setCustomBigContentView(notificationViews)
            notificationBuilder.setCustomHeadsUpContentView(notificationHeadsUpViews)
        } else {
            notificationBuilder.setContentTitle(data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_NAME_CALLER, ""))
            notificationBuilder.setContentText(data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_HANDLE, ""))
            val textDecline = data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_DECLINE, "")
            val declineAction: NotificationCompat.Action = NotificationCompat.Action.Builder(
                    R.drawable.ic_decline,
                    if (TextUtils.isEmpty(textDecline)) context.getString(R.string.text_decline) else textDecline,
                    getDeclinePendingIntent(notificationId, data)
            ).build()
            notificationBuilder.addAction(declineAction)
            val textAccept = data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_ACCEPT, "")
            val acceptAction: NotificationCompat.Action = NotificationCompat.Action.Builder(
                    R.drawable.ic_accept,
                    if (TextUtils.isEmpty(textDecline)) context.getString(R.string.text_accept) else textAccept,
                    getAcceptPendingIntent(notificationId, data)
            ).build()
            notificationBuilder.addAction(acceptAction)
        }
        val notification = notificationBuilder.build()
        notification.flags = Notification.FLAG_INSISTENT
        notification.flags = Notification.VISIBILITY_PUBLIC
        getNotificationManager().notify(notificationId, notification)
    }

    fun showMissCallNotification(data: Bundle) {
        notificationId = data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_ID, "MCFEF_MISS_CALL").hashCode() + 1
        createNotificationChanel()
        val missedCallSound: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        val typeCall = data.getInt(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TYPE, -1)
        var smallIcon = context.applicationInfo.icon
        if (typeCall > 0) {
            smallIcon = R.drawable.ic_video_missed
        } else {
            if (smallIcon >= 0) {
                smallIcon = R.drawable.ic_call_missed
            }
        }

        notificationBuilder = NotificationCompat.Builder(context, "MCFEF_MISS_CALL")
        notificationBuilder.setChannelId("MCFEF_MISS_CALL")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                notificationBuilder.setCategory(Notification.CATEGORY_MISSED_CALL)
            }
        }
        val textMissedCall = data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_MISSED_CALL, "")
        notificationBuilder.setSubText(if (TextUtils.isEmpty(textMissedCall)) context.getString(R.string.text_missed_call) else textMissedCall)
        notificationBuilder.setSmallIcon(smallIcon)
        val isCustomNotification = data.getBoolean(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_IS_CUSTOM_NOTIFICATION, false)
        if (isCustomNotification) {
            notificationViews =
                    RemoteViews(context.packageName, R.layout.layout_custom_miss_notification)
            notificationViews?.setTextViewText(
                    R.id.tvNameCaller,
                    data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_NAME_CALLER, "")
            )
            notificationViews?.setTextViewText(
                    R.id.tvNumber,
                    data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_HANDLE, "")
            )
            notificationViews?.setOnClickPendingIntent(
                    R.id.llCallback,
                    getCallbackPendingIntent(notificationId, data)
            )
            val isShowCallback = data.getBoolean(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_IS_SHOW_CALLBACK, true)
            notificationViews?.setViewVisibility(R.id.llCallback, if (isShowCallback) View.VISIBLE else View.GONE)
            val textCallback = data.getString(EXTRA_CALLKIT_TEXT_CALLBACK, "")
            notificationViews?.setTextViewText(R.id.tvCallback, if (TextUtils.isEmpty(textCallback)) context.getString(R.string.text_call_back) else textCallback)

            notificationBuilder.setStyle(NotificationCompat.DecoratedCustomViewStyle())
            notificationBuilder.setCustomContentView(notificationViews)
            notificationBuilder.setCustomBigContentView(notificationViews)
        } else {
            notificationBuilder.setContentTitle(data.getString(EXTRA_CALLKIT_NAME_CALLER, ""))
            notificationBuilder.setContentText(data.getString(EXTRA_CALLKIT_HANDLE, ""))

            val isShowCallback = data.getBoolean(EXTRA_CALLKIT_IS_SHOW_CALLBACK, true)
            if (isShowCallback) {
                val textCallback = data.getString(EXTRA_CALLKIT_TEXT_CALLBACK, "")
                val callbackAction: NotificationCompat.Action = NotificationCompat.Action.Builder(
                        R.drawable.ic_accept,
                        if (TextUtils.isEmpty(textCallback)) context.getString(R.string.text_call_back) else textCallback,
                        getCallbackPendingIntent(notificationId, data)
                ).build()
                notificationBuilder.addAction(callbackAction)
            }
        }
        notificationBuilder.priority = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            NotificationManager.IMPORTANCE_HIGH
        } else {
            Notification.PRIORITY_HIGH
        }
        notificationBuilder.setSound(missedCallSound)
        notificationBuilder.setContentIntent(getAppPendingIntent(notificationId, data))
        val actionColor = data.getString(EXTRA_CALLKIT_ACTION_COLOR, "#4CAF50")
        try {
            notificationBuilder.color = Color.parseColor(actionColor)
        } catch (error: Exception) {
        }

        val notification = notificationBuilder.build()
        getNotificationManager().notify(notificationId, notification)
        Handler(Looper.getMainLooper()).postDelayed({
            try {
                getNotificationManager().notify(notificationId, notification)
            } catch (error: Exception) {
            }
        }, 1000)
    }


    private fun getNotificationManager(): NotificationManagerCompat {
        return NotificationManagerCompat.from(context)
    }
    private fun createNotificationChanel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            var channelCall = getNotificationManager().getNotificationChannel("MCFEF_INCOMING_CALL")
            if (channelCall != null){
                channelCall.setSound(null, null)
            } else {
                channelCall = NotificationChannel(
                        "MCFEF_INCOMING_CALL",
                        "Incoming Call",
                        NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Channel to show incoming calls"
                    vibrationPattern =
                            longArrayOf(0, 1000, 500, 1000, 500)
                    lightColor = Color.RED
                    enableLights(true)
                    enableVibration(true)
                    setSound(null, null)
                }
            }
            channelCall.lockscreenVisibility = Notification.VISIBILITY_PUBLIC

            channelCall.importance = NotificationManager.IMPORTANCE_HIGH

            getNotificationManager().createNotificationChannel(channelCall)

            val channelMissedCall = NotificationChannel(
                    "MCFEF_MISS_CALL",
                    "Missed Call",
                    NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = ""
                vibrationPattern = longArrayOf(0, 1000)
                lightColor = Color.RED
                enableLights(true)
                enableVibration(true)
            }
            channelMissedCall.importance = NotificationManager.IMPORTANCE_DEFAULT
            getNotificationManager().createNotificationChannel(channelMissedCall)
        }
    }
    fun clearIncomingNotification(data: Bundle) {
        context.sendBroadcast(IncomingCallActivity.getIntentEnded())
        notificationId = data.getString(EXTRA_CALLKIT_ID, "mcfef_calls").hashCode()
        getNotificationManager().cancel(notificationId)
    }

    private fun getAppPendingIntent(id: Int, data: Bundle): PendingIntent {
        val intent: Intent? = context.packageManager.getLaunchIntentForPackage(context.packageName)
        intent?.putExtra(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_INCOMING_DATA, data)
        return PendingIntent.getActivity(context, id, intent, getFlagPendingIntent())
    }
    private fun getDeclinePendingIntent(id: Int, data: Bundle): PendingIntent {
        val declineIntent = CallsManagerBroadcastReceiver.getIntentDecline(context, data)
        return PendingIntent.getBroadcast(
                context,
                id,
                declineIntent,
                getFlagPendingIntent()
        )
    }
    private fun getAcceptPendingIntent(id: Int, data: Bundle): PendingIntent {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.cloneFilter()
        intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (intent != null) {
            val intentTransparent = TransparentActivity.getIntentAccept(context, data)
            return PendingIntent.getActivities(
                    context,
                    id,
                    arrayOf(intent, intentTransparent),
//                    intent,
                    getFlagPendingIntent()
            )
        } else {
            val acceptIntent = CallsManagerBroadcastReceiver.getIntentAccept(context, data)
            return PendingIntent.getBroadcast(
                    context,
                    id,
                    acceptIntent,
                    getFlagPendingIntent()
            )
        }
    }

    private fun getCallbackPendingIntent(id: Int, data: Bundle): PendingIntent {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.cloneFilter()
        intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (intent != null) {
            val intentTransparent = com.example.MCFEF.calls_manager.TransparentActivity.getIntentCallback(context, data)
            return PendingIntent.getActivities(
                    context,
                    id,
                    arrayOf(intent, intentTransparent),
                    getFlagPendingIntent()
            )
        } else {
            val acceptIntent = CallsManagerBroadcastReceiver.getIntentCallback(context, data)
            return PendingIntent.getBroadcast(
                    context,
                    id,
                    acceptIntent,
                    getFlagPendingIntent()
            )
        }
    }

    private fun getActivityPendingIntent(id: Int, data: Bundle): PendingIntent {
        val km = context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager1
//        val intent = CallkitIncomingActivity.getIntent(data)
        val intent = IncomingCallActivity.getIntent(data)
        return PendingIntent.getActivity(context, id, intent, getFlagPendingIntent())
    }

    private fun getTimeOutPendingIntent(id: Int, data: Bundle): PendingIntent {
        val timeOutIntent = CallsManagerBroadcastReceiver.getIntentTimeout(context, data)
        return PendingIntent.getBroadcast(
                context,
                id,
                timeOutIntent,
                getFlagPendingIntent()
        )
    }

    private fun getFlagPendingIntent(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
    }

}