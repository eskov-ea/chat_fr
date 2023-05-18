package com.example.MCFEF;


import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.example.MCFEF.linphoneSDK.CoreContext
import com.example.MCFEF.linphoneSDK.LinphoneCore


class PushBroadcastReceiver: BroadcastReceiver() {


    override fun onReceive(context: Context, intent: Intent) {

        val core = CoreContext(context).getInstance()
        LinphoneCore(core, context).readSipAccountFromStorageAndLogin()

    }


}

