package com.example.MCFEF;


import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.widget.Toast
import com.example.MCFEF.linphoneSDK.CoreContext
import com.example.MCFEF.linphoneSDK.LinphoneCore
import io.flutter.Log


class PushBroadcastReceiver: BroadcastReceiver() {


    override fun onReceive(context: Context, intent: Intent) {

        Toast.makeText(context, "We have received PUSH", Toast.LENGTH_LONG).show()
        val core = CoreContext(context).getInstance()
//        core.isReady?
        LinphoneCore(core, context).readSipAccountFromStorageAndLogin()

    }


}

