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
//        Toast.makeText(context, "[Push] RECEIVED + ${CoreContext.isLoggedIn}", Toast.LENGTH_SHORT).show()
        if (CoreContext.core == null || !CoreContext.isLoggedIn) {
            Log.i("PUSH_BROADCAST_RECEIVER", intent.extras.toString())
            val core = CoreContext(context).getInstance()
            LinphoneCore(core, context).readSipAccountFromStorageAndLogin()
        }

    }

}

