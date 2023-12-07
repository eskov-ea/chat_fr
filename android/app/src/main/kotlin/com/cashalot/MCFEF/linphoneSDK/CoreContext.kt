package com.cashalot.MCFEF.linphoneSDK

import android.content.Context
import org.linphone.core.Core
import org.linphone.core.Factory

class CoreContext (val context: Context) {

    companion object {
        var core: Core? = null
        val PREFERENCE_FILENAME = "FLEXISIP_LOGIN_ACCOUNT"
        var isLoggedIn: Boolean = false
    }

    private fun createCore() {
        val factory = Factory.instance()
        factory.setDebugMode(true, "Linphone::")
        factory.enableLogcatLogs(false)
        factory.enableLogcatLogs(true)
        core = factory.createCore(null, null, context)
        core!!.isPushNotificationEnabled = true
    }

    fun getInstance(): Core {
        if (core == null) {
            createCore()
        }
        return core!!
    }

    fun stop() {
        core!!.stop()
    }
}