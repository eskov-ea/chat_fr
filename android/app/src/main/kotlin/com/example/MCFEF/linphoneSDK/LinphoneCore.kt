package com.example.MCFEF.linphoneSDK

import com.example.MCFEF.MainActivity
import org.linphone.core.Core
import org.linphone.core.Factory

class LinphoneCore {

    var core: Core? = null

    fun getSDKCore(): Core {
        if (core == null) {
            createCore()
        }
        return core!!
    }

    fun getInstance() {

    }

    fun createCore() {
        val factory = Factory.instance()
        factory.setDebugMode(true, "Hello Linphone")
        factory.enableLogcatLogs(true)
        core = factory.createCore(null, null, this)
        core!!.isPushNotificationEnabled = true
    }
}