package com.cashalot.MCFEF.calls_manager

import android.annotation.SuppressLint
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import com.cashalot.MCFEF.linphoneSDK.CoreContext
import org.linphone.core.Reason

class CallsManagerBroadcastReceiver : BroadcastReceiver() {

    private val call = CoreContext.core

    companion object {
        const val ACTION_CALL_INCOMING =
                "com.cashalot.MCFEF.calls_manager.ACTION_CALL_INCOMING"
        const val ACTION_CALL_ACCEPT =
                "com.cashalot.MCFEF.calls_manager.ACTION_CALL_ACCEPT"
        const val ACTION_CALL_DECLINE =
                "com.cashalot.MCFEF.calls_manager.ACTION_CALL_DECLINE"
        const val ACTION_CALL_ENDED =
                "com.cashalot.MCFEF.calls_manager.ACTION_CALL_ENDED"
        const val ACTION_CALL_TIMEOUT =
                "com.cashalot.MCFEF.calls_manager.ACTION_CALL_TIMEOUT"
        const val ACTION_CALL_CALLBACK =
                "com.cashalot.MCFEF.calls_manager.ACTION_CALL_CALLBACK"
        const val ACTION_CALL_ACCEPTED =
                "com.cashalot.MCFEF.calls_manager.ACTION_CALL_ACCEPTED"


        const val EXTRA_CALLKIT_INCOMING_DATA = "EXTRA_CALLKIT_INCOMING_DATA"

        const val EXTRA_CALLKIT_ID = "EXTRA_CALLKIT_ID"
        const val EXTRA_CALLKIT_NAME_CALLER = "EXTRA_CALLKIT_NAME_CALLER"
        const val EXTRA_CALLKIT_APP_NAME = "EXTRA_CALLKIT_APP_NAME"
        const val EXTRA_CALLKIT_HANDLE = "EXTRA_CALLKIT_HANDLE"
        const val EXTRA_CALLKIT_TYPE = "EXTRA_CALLKIT_TYPE"
        const val EXTRA_CALLKIT_AVATAR = "EXTRA_CALLKIT_AVATAR"
        const val EXTRA_CALLKIT_DURATION = "EXTRA_CALLKIT_DURATION"
        const val EXTRA_CALLKIT_TEXT_ACCEPT = "EXTRA_CALLKIT_TEXT_ACCEPT"
        const val EXTRA_CALLKIT_TEXT_DECLINE = "EXTRA_CALLKIT_TEXT_DECLINE"
        const val EXTRA_CALLKIT_TEXT_MISSED_CALL = "EXTRA_CALLKIT_TEXT_MISSED_CALL"
        const val EXTRA_CALLKIT_TEXT_CALLBACK = "EXTRA_CALLKIT_TEXT_CALLBACK"
        const val EXTRA_CALLKIT_EXTRA = "EXTRA_CALLKIT_EXTRA"
        const val EXTRA_CALLKIT_HEADERS = "EXTRA_CALLKIT_HEADERS"
        const val EXTRA_CALLKIT_IS_CUSTOM_NOTIFICATION = "EXTRA_CALLKIT_IS_CUSTOM_NOTIFICATION"
        const val EXTRA_CALLKIT_IS_SHOW_LOGO = "EXTRA_CALLKIT_IS_SHOW_LOGO"
        const val EXTRA_CALLKIT_IS_SHOW_MISSED_CALL_NOTIFICATION = "EXTRA_CALLKIT_IS_SHOW_MISSED_CALL_NOTIFICATION"
        const val EXTRA_CALLKIT_IS_SHOW_CALLBACK = "EXTRA_CALLKIT_IS_SHOW_CALLBACK"
        const val EXTRA_CALLKIT_RINGTONE_PATH = "EXTRA_CALLKIT_RINGTONE_PATH"
        const val EXTRA_CALLKIT_BACKGROUND_COLOR = "EXTRA_CALLKIT_BACKGROUND_COLOR"
        const val EXTRA_CALLKIT_BACKGROUND_URL = "EXTRA_CALLKIT_BACKGROUND_URL"
        const val EXTRA_CALLKIT_ACTION_COLOR = "EXTRA_CALLKIT_ACTION_COLOR"
        const val EXTRA_CALLKIT_IS_CUSTOM_SMALL_EX_NOTIFICATION =
                "EXTRA_CALLKIT_IS_CUSTOM_SMALL_EX_NOTIFICATION"
        const val EXTRA_CALLKIT_ACTION_FROM = "EXTRA_CALLKIT_ACTION_FROM"


        fun getIntent(context: Context, action: String, data: Bundle?) =
                Intent(context, CallsManagerBroadcastReceiver::class.java).apply {
                    this.action = "${context.packageName}.${action}"
                    putExtra(EXTRA_CALLKIT_INCOMING_DATA, data)
                }
        fun getIntentDecline(context: Context, data: Bundle?) =
                Intent(context, CallsManagerBroadcastReceiver::class.java).apply {
                    action = ACTION_CALL_DECLINE
                    putExtra(EXTRA_CALLKIT_INCOMING_DATA, data)
                }
        fun getIntentTimeout(context: Context, data: Bundle?) =
                Intent(context, CallsManagerBroadcastReceiver::class.java).apply {
                    action = ACTION_CALL_TIMEOUT
                    putExtra(EXTRA_CALLKIT_INCOMING_DATA, data)
                }
        fun getIntentAccept(context: Context, data: Bundle?) =
                Intent(context, CallsManagerBroadcastReceiver::class.java).apply {
                    action = ACTION_CALL_ACCEPT
                    putExtra(EXTRA_CALLKIT_INCOMING_DATA, data)
                }
        fun getIntentCallback(context: Context, data: Bundle?) =
                Intent(context, CallsManagerBroadcastReceiver::class.java).apply {
                    action = ACTION_CALL_CALLBACK
                    putExtra(EXTRA_CALLKIT_INCOMING_DATA, data)
                }
        fun getIntentIncoming(context: Context, data: Bundle?) =
                Intent(context, CallsManagerBroadcastReceiver::class.java).apply {
                    action = ACTION_CALL_INCOMING
                    putExtra(EXTRA_CALLKIT_INCOMING_DATA, data)
                }

    }

    @SuppressLint("MissingPermission")
    override fun onReceive(context: Context, intent: Intent) {
        val callkitNotificationManager = CallsNotificationManager(context)
        val action = intent.action ?: return
        val data = intent.extras?.getBundle(EXTRA_CALLKIT_INCOMING_DATA) ?: return
        when (action) {
            ACTION_CALL_INCOMING -> {
                try {
                    callkitNotificationManager.showIncomingNotification(data)
                    val soundPlayerServiceIntent = Intent(context, CallsSoundPlayerService::class.java)
                    soundPlayerServiceIntent.putExtras(data)
                    context.startService(soundPlayerServiceIntent)
                } catch (error: Exception) {
                    error.printStackTrace()
                    Log.w("ERROR CALL","$error")
                }
            }
            ACTION_CALL_ACCEPT -> {
                try {
                    context.stopService(Intent(context, CallsSoundPlayerService::class.java))
                    callkitNotificationManager.clearIncomingNotification(data)
                    call!!.currentCall?.accept()
                } catch (error: Exception) {
                    error.printStackTrace()
                    Log.w("ERROR CALL","$error")
                }
            }
            ACTION_CALL_DECLINE -> {
                try {
                    Log.w("DECLINE_CALL", "$this")
                    context.stopService(Intent(context, CallsSoundPlayerService::class.java))
                    call!!.currentCall?.decline(Reason.Declined)
                    callkitNotificationManager.clearIncomingNotification(data)
                } catch (error: Exception) {
                    error.printStackTrace()
                }
            }
            ACTION_CALL_ENDED -> {
                try {
                    Log.w("ENDED_CALL", "$this")
                    context.stopService(Intent(context, CallsSoundPlayerService::class.java))
                    callkitNotificationManager.clearIncomingNotification(data)
                } catch (error: Exception) {
                    error.printStackTrace()
                }
            }
            ACTION_CALL_TIMEOUT -> {
                try {
                    context.stopService(Intent(context, CallsSoundPlayerService::class.java))
                    if (data.getBoolean(EXTRA_CALLKIT_IS_SHOW_MISSED_CALL_NOTIFICATION, true)) {
                        callkitNotificationManager.showMissCallNotification(data)
                    }
                } catch (error: Exception) {
                    error.printStackTrace()
                }
            }
            ACTION_CALL_CALLBACK -> {
                try {
//                    callkitNotificationManager.clearMissCallNotification(data)
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
                        val closeNotificationPanel = Intent(Intent.ACTION_CLOSE_SYSTEM_DIALOGS)
                        context.sendBroadcast(closeNotificationPanel)
                    }
                } catch (error: Exception) {
                    error.printStackTrace()
                }
            }
        }
    }

}