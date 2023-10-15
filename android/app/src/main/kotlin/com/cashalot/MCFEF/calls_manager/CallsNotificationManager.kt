package com.cashalot.MCFEF.calls_manager

import android.Manifest
import android.app.*
import android.content.Context
import android.content.DialogInterface
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.text.TextUtils
import android.view.View
import android.widget.RemoteViews
import androidx.appcompat.app.AlertDialog
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.cashalot.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_ACTION_COLOR
import com.cashalot.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_HANDLE
import com.cashalot.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_ID
import com.cashalot.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_IS_SHOW_CALLBACK
import com.cashalot.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_NAME_CALLER
import com.cashalot.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_TEXT_CALLBACK
import com.cashalot.MCFEF.R
import com.cashalot.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_IS_CUSTOM_NOTIFICATION
import com.cashalot.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_IS_CUSTOM_SMALL_EX_NOTIFICATION
import com.cashalot.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_TEXT_ACCEPT
import com.cashalot.MCFEF.calls_manager.CallsManagerBroadcastReceiver.Companion.EXTRA_CALLKIT_TEXT_DECLINE
import io.flutter.Log

class CallsNotificationManager(private val context: Context) {

    companion object {
        const val EXTRA_TIME_START_CALL = "EXTRA_TIME_START_CALL"
        const val PERMISSION_NOTIFICATION_REQUEST_CODE = 6969
        private const val NOTIFICATION_CHANNEL_ID_INCOMING = "MCFEF_INCOMING_CALL_CHANNEL_ID"
        private const val NOTIFICATION_CHANNEL_ID_MISSED = "mcfef_missed_channel_id"
    }

    private lateinit var notificationBuilder: NotificationCompat.Builder
    private var notificationViews: RemoteViews? = null
    private var notificationHeadsUpViews: RemoteViews? = null
    private var notificationSmallViews: RemoteViews? = null
    private var notificationId: Int = 96962
    private var dataNotificationPermission: Map<String, Any> = HashMap()


    fun showIncomingNotification(data: Bundle) {
        data.putLong(EXTRA_TIME_START_CALL, System.currentTimeMillis())

        notificationId = data.getString(EXTRA_CALLKIT_ID, NOTIFICATION_CHANNEL_ID_INCOMING).hashCode()
        createNotificationChanel()

        notificationBuilder = NotificationCompat.Builder(context, NOTIFICATION_CHANNEL_ID_INCOMING)
        notificationBuilder.setAutoCancel(false)
        notificationBuilder.setChannelId(NOTIFICATION_CHANNEL_ID_INCOMING)
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
        val actionColor = data.getString(EXTRA_CALLKIT_ACTION_COLOR, "#4CAF50")
        try {
            notificationBuilder.color = Color.parseColor(actionColor)
        } catch (error: Exception) {
            error.printStackTrace()
        }
        notificationBuilder.setChannelId(NOTIFICATION_CHANNEL_ID_INCOMING)
        notificationBuilder.priority = NotificationCompat.PRIORITY_MAX
        val isCustomNotification = data.getBoolean(EXTRA_CALLKIT_IS_CUSTOM_NOTIFICATION, false)
        val isCustomSmallExNotification =
                data.getBoolean(EXTRA_CALLKIT_IS_CUSTOM_SMALL_EX_NOTIFICATION, false)

        Log.i("MY_NOTIFICATION", "SHOW INCOMING NOTIFICATION WITH DATA:  ${data}")
        if (isCustomNotification) {
            notificationViews =
                    RemoteViews(context.packageName, R.layout.layout_custom_notification)
            initNotificationViews(notificationViews!!, data)

            if ((Build.MANUFACTURER.equals(
                            "Samsung",
                            ignoreCase = true
                    ) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) || isCustomSmallExNotification
            ) {
                notificationSmallViews =
                        RemoteViews(context.packageName, R.layout.layout_custom_small_ex_notification)
                initNotificationViews(notificationSmallViews!!, data)
            } else {
                notificationSmallViews =
                        RemoteViews(context.packageName, R.layout.layout_custom_small_notification)
                initNotificationViews(notificationSmallViews!!, data)
            }

            notificationBuilder.setStyle(NotificationCompat.DecoratedCustomViewStyle())
            notificationBuilder.setCustomContentView(notificationSmallViews)
            notificationBuilder.setCustomBigContentView(notificationViews)
            notificationBuilder.setCustomHeadsUpContentView(notificationSmallViews)
        } else {
            notificationBuilder.setContentTitle(
                    data.getString(
                            EXTRA_CALLKIT_NAME_CALLER,
                            ""
                    )
            )
            notificationBuilder.setContentText(data.getString(EXTRA_CALLKIT_HANDLE, ""))
            val textDecline = data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_DECLINE, "Decline")
            val declineAction: NotificationCompat.Action = NotificationCompat.Action.Builder(
                    R.drawable.ic_decline,
                    if (TextUtils.isEmpty(textDecline)) context.getString(com.hiennv.flutter_callkit_incoming.R.string.text_decline) else textDecline,
                    getDeclinePendingIntent(notificationId, data)
            ).build()
            notificationBuilder.addAction(declineAction)
            val textAccept = data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_ACCEPT, "Accept")
            val acceptAction: NotificationCompat.Action = NotificationCompat.Action.Builder(
                    R.drawable.ic_accept,
                    if (TextUtils.isEmpty(textDecline)) context.getString(com.hiennv.flutter_callkit_incoming.R.string.text_accept) else textAccept,
                    getAcceptPendingIntent(notificationId, data)
            ).build()
            notificationBuilder.addAction(acceptAction)
        }

        val notification = notificationBuilder.build()
        notification.flags = Notification.FLAG_INSISTENT
        notification.flags = Notification.VISIBILITY_PUBLIC
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            notification.flags = Notification.FOREGROUND_SERVICE_IMMEDIATE
        }
        if (ActivityCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
            Log.i("MY_NOTIFICATION", "NOT PERMISSION")
            return
        }
        Log.i("MY_NOTIFICATION", "SHOW INCOMING NOTIFICATION WITH DATA:  ${notification}")
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


    private fun initNotificationViews(remoteViews: RemoteViews, data: Bundle) {
        remoteViews.setTextViewText(
                R.id.tvNameCaller,
                data.getString(EXTRA_CALLKIT_NAME_CALLER, "Unknown")
        )
        remoteViews.setTextViewText(
                R.id.tvNumber,
                data.getString(EXTRA_CALLKIT_HANDLE, "")
        )
        remoteViews.setOnClickPendingIntent(
                R.id.llDecline,
                getDeclinePendingIntent(notificationId, data)
        )
        val textDecline = data.getString(EXTRA_CALLKIT_TEXT_DECLINE, "")
        remoteViews.setTextViewText(
                R.id.tvDecline,
                if (TextUtils.isEmpty(textDecline)) context.getString(com.hiennv.flutter_callkit_incoming.R.string.text_decline) else textDecline
        )
        remoteViews.setOnClickPendingIntent(
                R.id.llAccept,
                getAcceptPendingIntent(notificationId, data)
        )
        val textAccept = data.getString(EXTRA_CALLKIT_TEXT_ACCEPT, "")
        remoteViews.setTextViewText(
                R.id.tvAccept,
                if (TextUtils.isEmpty(textAccept)) context.getString(com.hiennv.flutter_callkit_incoming.R.string.text_accept) else textAccept
        )
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
                    NOTIFICATION_CHANNEL_ID_INCOMING,
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
        notificationId = data.getString(EXTRA_CALLKIT_ID, NOTIFICATION_CHANNEL_ID_INCOMING).hashCode()
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

        val intentTransparent = CallsManagerBroadcastReceiver.getIntentAccept(context, data)
        TransparentActivity.getIntent(context, CallsManagerBroadcastReceiver.ACTION_CALL_ACCEPT, data)
        return PendingIntent.getActivity(context, id, intentTransparent, getFlagPendingIntent())

//        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.cloneFilter()
//        intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
//        if (intent != null) {
//            val intentTransparent = TransparentActivity.getIntentAccept(context, data)
//            return PendingIntent.getActivities(
//                    context,
//                    id,
//                    arrayOf(intent, intentTransparent),
////                    intent,
//                    getFlagPendingIntent()
//            )
//        } else {
//            val acceptIntent = CallsManagerBroadcastReceiver.getIntentAccept(context, data)
//            return PendingIntent.getBroadcast(
//                    context,
//                    id,
//                    acceptIntent,
//                    getFlagPendingIntent()
//            )
//        }
    }

    private fun getCallbackPendingIntent(id: Int, data: Bundle): PendingIntent {
        val intentTransparent = TransparentActivity.getIntent(
            context,
            CallsManagerBroadcastReceiver.ACTION_CALL_CALLBACK,
            data
        )
        return PendingIntent.getActivity(context, id, intentTransparent, getFlagPendingIntent())
    }

    private fun getActivityPendingIntent(id: Int, data: Bundle): PendingIntent {
        val intent = AppUtils.getAppIntent(context, data= data)
//        val intent = IncomingCallActivity.getIntent(data)
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

    fun requestNotificationPermission(activity: Activity?, map: Map<String, Any>) {
        this.dataNotificationPermission = map
        if (Build.VERSION.SDK_INT > 32) {
            activity?.let {
                ActivityCompat.requestPermissions(it,
                        arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                        PERMISSION_NOTIFICATION_REQUEST_CODE)
            }
        }
    }

    fun onRequestPermissionsResult(activity: Activity?, requestCode: Int, grantResults: IntArray) {
        when (requestCode) {
            PERMISSION_NOTIFICATION_REQUEST_CODE -> {
                if (grantResults.isNotEmpty() &&
                        grantResults[0] === PackageManager.PERMISSION_GRANTED) {
                    // allow
                } else {
                    //deny
                    activity?.let {
                        if (ActivityCompat.shouldShowRequestPermissionRationale(it, Manifest.permission.POST_NOTIFICATIONS)) {
                            //showDialogPermissionRationale()
                            if (this.dataNotificationPermission["rationaleMessagePermission"] != null) {
                                showDialogMessage(it, this.dataNotificationPermission["rationaleMessagePermission"] as String) { dialog, _ ->
                                    dialog?.dismiss()
                                    requestNotificationPermission(activity, this.dataNotificationPermission)
                                }
                            } else {
                                requestNotificationPermission(activity, this.dataNotificationPermission)
                            }
                        } else {
                            //Open Setting
                            if (this.dataNotificationPermission["postNotificationMessageRequired"] != null) {
                                showDialogMessage(it, this.dataNotificationPermission["postNotificationMessageRequired"] as String) { dialog, _ ->
                                    dialog?.dismiss()
                                    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                            Uri.fromParts("package", it.packageName, null))
                                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                    it.startActivity(intent)
                                }
                            } else {
                                showDialogMessage(it, it.resources.getString(com.hiennv.flutter_callkit_incoming.R.string.text_post_notification_message_required)) { dialog, _ ->
                                    dialog?.dismiss()
                                    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                            Uri.fromParts("package", it.packageName, null))
                                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                    it.startActivity(intent)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private fun showDialogMessage(activity: Activity?, message: String, okListener: DialogInterface.OnClickListener) {
        activity?.let {
            AlertDialog.Builder(it, R.style.DialogTheme)
                    .setMessage(message)
                    .setPositiveButton(android.R.string.ok, okListener)
                    .setNegativeButton(android.R.string.cancel, null)
                    .create()
                    .show()
        }
    }

}







//if (isCustomNotification) {
//    notificationViews =
//            RemoteViews(context.packageName, R.layout.layout_custom_notification)
//    notificationHeadsUpViews = RemoteViews(context.packageName, R.layout.layout_custom_notification_heads_up)
//    notificationViews?.setTextViewText(
//            R.id.tvNameCaller,
//            data.getString(EXTRA_CALLKIT_NAME_CALLER, "")
//    )
//    notificationHeadsUpViews?.setTextViewText(
//            R.id.tvNameCaller,
//            data.getString(EXTRA_CALLKIT_NAME_CALLER, "")
//    )
//    notificationViews?.setTextViewText(
//            R.id.tvNumber,
//            data.getString(EXTRA_CALLKIT_HANDLE, "")
//    )
//    notificationHeadsUpViews?.setTextViewText(
//            R.id.tvNumber,
//            data.getString(EXTRA_CALLKIT_HANDLE, "")
//    )
//    notificationViews?.setOnClickPendingIntent(
//            R.id.llDecline,
//            getDeclinePendingIntent(notificationId, data)
//    )
//    notificationHeadsUpViews?.setOnClickPendingIntent(
//            R.id.llDecline,
//            getDeclinePendingIntent(notificationId, data)
//    )
//    val textDecline = data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_DECLINE, "")
//    notificationViews?.setTextViewText(
//            R.id.tvDecline,
//            if (TextUtils.isEmpty(textDecline)) context.getString(R.string.text_decline) else textDecline
//    )
//    notificationHeadsUpViews?.setTextViewText(
//            R.id.tvDecline,
//            if (TextUtils.isEmpty(textDecline)) context.getString(R.string.text_decline) else textDecline
//    )
//    notificationViews?.setOnClickPendingIntent(
//            R.id.llAccept,
//            getAcceptPendingIntent(notificationId, data)
//    )
//    notificationHeadsUpViews?.setOnClickPendingIntent(
//            R.id.llAccept,
//            getAcceptPendingIntent(notificationId, data)
//    )
//    val textAccept = data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_ACCEPT, "")
//    notificationViews?.setTextViewText(
//            R.id.tvAccept,
//            if (TextUtils.isEmpty(textAccept)) context.getString(R.string.text_accept) else textAccept
//    )
//    notificationHeadsUpViews?.setTextViewText(
//            R.id.tvAccept,
//            if (TextUtils.isEmpty(textAccept)) context.getString(R.string.text_accept) else textAccept
//    )
//
//    notificationBuilder.setStyle(NotificationCompat.DecoratedCustomViewStyle())
//    notificationBuilder.setCustomContentView(notificationHeadsUpViews)
//    notificationBuilder.setCustomBigContentView(notificationViews)
//    notificationBuilder.setCustomHeadsUpContentView(notificationHeadsUpViews)
//} else {
//    notificationBuilder.setContentTitle(data.getString(EXTRA_CALLKIT_NAME_CALLER, ""))
//    notificationBuilder.setContentText(data.getString(EXTRA_CALLKIT_HANDLE, ""))
//    val textDecline = data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_DECLINE, "")
//    val declineAction: NotificationCompat.Action = NotificationCompat.Action.Builder(
//            R.drawable.ic_decline,
//            if (TextUtils.isEmpty(textDecline)) context.getString(R.string.text_decline) else textDecline,
//            getDeclinePendingIntent(notificationId, data)
//    ).build()
//    notificationBuilder.addAction(declineAction)
//    val textAccept = data.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_ACCEPT, "")
//    val acceptAction: NotificationCompat.Action = NotificationCompat.Action.Builder(
//            R.drawable.ic_accept,
//            if (TextUtils.isEmpty(textDecline)) context.getString(R.string.text_accept) else textAccept,
//            getAcceptPendingIntent(notificationId, data)
//    ).build()
//    notificationBuilder.addAction(acceptAction)
//}