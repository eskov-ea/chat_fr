package com.cashalot.MCFEF.calls_manager

import android.os.Bundle

class Call {

}
data class CallData(val args: Map<String, Any?>) {

    var id: String = (args["call_id"] as? String) ?: ""
    var uuid: String = (args["id"] as? String) ?: ""
    var nameCaller: String = (args["nameCaller"] as? String) ?: ""
    var appName: String = (args["appName"] as? String) ?: ""
    var handle: String = (args["handle"] as? String) ?: ""
    var avatar: String = (args["avatar"] as? String) ?: ""
    var type: Int = (args["type"] as? Int) ?: 0
    var duration: Long = (args["duration"] as? Long) ?: ((args["duration"] as? Int)?.toLong() ?: 30000L)
    var textAccept: String = (args["textAccept"] as? String) ?: ""
    var textDecline: String = (args["textDecline"] as? String) ?: ""
    var textMissedCall: String = (args["textMissedCall"] as? String) ?: ""
    var textCallback: String = (args["textCallback"] as? String) ?: ""
    var extra: HashMap<String, Any?> =
            (args["extra"] ?: HashMap<String, Any?>()) as HashMap<String, Any?>
    var headers: HashMap<String, Any?> =
            (args["headers"] ?: HashMap<String, Any?>()) as HashMap<String, Any?>
    var from: String = ""

    var isCustomNotification: Boolean = false
    var isShowLogo: Boolean = false
    var isShowCallback: Boolean = true
    var ringtonePath: String
    var backgroundColor: String
    var backgroundUrl: String
    var actionColor: String
    var isShowMissedCallNotification: Boolean = true

    var isAccepted: Boolean = false

    init {
        val android: HashMap<String, Any?>? = args["android"] as? HashMap<String, Any?>?
        if (android != null) {
            isCustomNotification = (android["isCustomNotification"] as? Boolean) ?: false
            isShowLogo = (android["isShowLogo"] as? Boolean) ?: false
            isShowCallback = (android["isShowCallback"] as? Boolean) ?: true
            ringtonePath = (android["ringtonePath"] as? String) ?: ""
            backgroundColor = (android["backgroundColor"] as? String) ?: "#0955fa"
            backgroundUrl = (android["backgroundUrl"] as? String) ?: ""
            actionColor = (android["actionColor"] as? String) ?: "#4CAF50"
            isShowMissedCallNotification = (android["isShowMissedCallNotification"] as? Boolean) ?: true
        } else {
            isCustomNotification = (args["isCustomNotification"] as? Boolean) ?: false
            isShowLogo = (args["isShowLogo"] as? Boolean) ?: false
            isShowCallback = (args["isShowCallback"] as? Boolean) ?: true
            ringtonePath = (args["ringtonePath"] as? String) ?: ""
            backgroundColor = (args["backgroundColor"] as? String) ?: "#0955fa"
            backgroundUrl = (args["backgroundUrl"] as? String) ?: ""
            actionColor = (args["actionColor"] as? String) ?: "#4CAF50"
            isShowMissedCallNotification = (args["isShowMissedCallNotification"] as? Boolean) ?: true
        }
    }

    override fun hashCode(): Int {
        return id.hashCode()
    }

    override fun equals(other: Any?): Boolean {
        if (other == null) return false
        val e: com.cashalot.MCFEF.calls_manager.CallData = other as com.cashalot.MCFEF.calls_manager.CallData
        return this.id == e.id
    }


    fun toBundle(): Bundle {
        val bundle = Bundle()
        bundle.putString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_ID, id)
        bundle.putString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_NAME_CALLER, nameCaller)
        bundle.putString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_HANDLE, handle)
        bundle.putString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_AVATAR, avatar)
        bundle.putInt(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TYPE, type)
        bundle.putLong(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_DURATION, duration)
        bundle.putString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_ACCEPT, textAccept)
        bundle.putString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_DECLINE, textDecline)
        bundle.putString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_MISSED_CALL, textMissedCall)
        bundle.putString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_CALLBACK, textCallback)
        bundle.putSerializable(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_EXTRA, extra)
        bundle.putSerializable(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_HEADERS, headers)
        bundle.putBoolean(
                CallsManagerBroadcastReceiver.EXTRA_CALLKIT_IS_CUSTOM_NOTIFICATION,
                isCustomNotification
        )
        bundle.putBoolean(
                CallsManagerBroadcastReceiver.EXTRA_CALLKIT_IS_SHOW_LOGO,
                isShowLogo
        )
        bundle.putBoolean(
                CallsManagerBroadcastReceiver.EXTRA_CALLKIT_IS_SHOW_CALLBACK,
                isShowCallback
        )
        bundle.putString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_RINGTONE_PATH, ringtonePath)
        bundle.putString(
                CallsManagerBroadcastReceiver.EXTRA_CALLKIT_BACKGROUND_COLOR,
                backgroundColor
        )
        bundle.putString(
                CallsManagerBroadcastReceiver.EXTRA_CALLKIT_BACKGROUND_URL,
                backgroundUrl
        )
        bundle.putString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_ACTION_COLOR, actionColor)
        bundle.putString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_ACTION_FROM, from)
        bundle.putBoolean(
                CallsManagerBroadcastReceiver.EXTRA_CALLKIT_IS_SHOW_MISSED_CALL_NOTIFICATION,
                isShowMissedCallNotification
        )
        return bundle
    }

    companion object {

        fun fromBundle(bundle: Bundle): com.cashalot.MCFEF.calls_manager.CallData {
            val callData = CallData(emptyMap())
            callData.id = bundle.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_ID, "")
            callData.nameCaller =
                    bundle.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_NAME_CALLER, "")
            callData.appName =
                    bundle.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_APP_NAME, "")
            callData.handle =
                    bundle.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_HANDLE, "")
            callData.avatar =
                    bundle.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_AVATAR, "")
            callData.type = bundle.getInt(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TYPE, 0)
            callData.duration =
                    bundle.getLong(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_DURATION, 30000L)
            callData.textAccept =
                    bundle.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_ACCEPT, "")
            callData.textDecline =
                    bundle.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_DECLINE, "")
            callData.textMissedCall =
                    bundle.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_MISSED_CALL, "")
            callData.textCallback =
                    bundle.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_TEXT_CALLBACK, "")
            callData.extra =
                    bundle.getSerializable(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_EXTRA) as HashMap<String, Any?>
            callData.headers =
                    bundle.getSerializable(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_HEADERS) as HashMap<String, Any?>

            callData.isCustomNotification = bundle.getBoolean(
                    CallsManagerBroadcastReceiver.EXTRA_CALLKIT_IS_CUSTOM_NOTIFICATION,
                    false
            )
            callData.isShowLogo = bundle.getBoolean(
                    CallsManagerBroadcastReceiver.EXTRA_CALLKIT_IS_SHOW_LOGO,
                    false
            )
            callData.isShowCallback = bundle.getBoolean(
                    CallsManagerBroadcastReceiver.EXTRA_CALLKIT_IS_SHOW_CALLBACK,
                    true
            )
            callData.ringtonePath = bundle.getString(
                    CallsManagerBroadcastReceiver.EXTRA_CALLKIT_RINGTONE_PATH,
                    ""
            )
            callData.backgroundColor = bundle.getString(
                    CallsManagerBroadcastReceiver.EXTRA_CALLKIT_BACKGROUND_COLOR,
                    "#0955fa"
            )
            callData.backgroundUrl =
                    bundle.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_BACKGROUND_URL, "")
            callData.actionColor = bundle.getString(
                    CallsManagerBroadcastReceiver.EXTRA_CALLKIT_ACTION_COLOR,
                    "#4CAF50"
            )
            callData.from =
                    bundle.getString(CallsManagerBroadcastReceiver.EXTRA_CALLKIT_ACTION_FROM, "")
            callData.isShowMissedCallNotification = bundle.getBoolean(
                    CallsManagerBroadcastReceiver.EXTRA_CALLKIT_IS_SHOW_MISSED_CALL_NOTIFICATION,
                    true
            )
            return callData
        }
    }
}