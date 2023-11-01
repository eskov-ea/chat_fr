package com.cashalot.MCFEF;


import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.widget.Toast
import com.cashalot.MCFEF.linphoneSDK.CoreContext
import com.cashalot.MCFEF.linphoneSDK.LinphoneCore
import io.flutter.Log


class PushBroadcastReceiver: BroadcastReceiver() {


    override fun onReceive(context: Context, intent: Intent) {
        Toast.makeText(context, "[Push] RECEIVED", Toast.LENGTH_SHORT).show()
        if (!CoreContext.isLoggedIn) {
            val core = CoreContext(context).getInstance()
            LinphoneCore(core, context).readSipAccountFromStorageAndLogin()
        }

    }

}

