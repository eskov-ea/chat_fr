package com.cashalot.MCFEF;


import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.cashalot.MCFEF.linphoneSDK.CoreContext
import com.cashalot.MCFEF.linphoneSDK.LinphoneCore
import io.flutter.Log


class PushBroadcastReceiver: BroadcastReceiver() {


    override fun onReceive(context: Context, intent: Intent) {
        if (!CoreContext.isLoggedIn) {
            Log.i("BROADCAST", "We start new service")
            val core = CoreContext(context).getInstance()
            LinphoneCore(core, context).readSipAccountFromStorageAndLogin()
        }

    }

}

