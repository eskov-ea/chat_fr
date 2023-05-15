package com.example.MCFEF;


//import com.example.MCFEF.MainActivity.Companion.core
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import android.widget.Toast
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import org.linphone.core.*


class PushBroadcastReceiver: BroadcastReceiver() {


    override fun onReceive(context: Context, intent: Intent) {

        Toast.makeText(context, "Push received with app shut down", Toast.LENGTH_LONG).show()
//        Toast.makeText(context, intent.action, Toast.LENGTH_LONG).show()
        startCallService(context)

    }

    private fun startCallService(context: Context) {
        val intent = Intent(context, SipForegroundService::class.java)
        Toast.makeText(context, "startCallService", Toast.LENGTH_LONG).show()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val request = OneTimeWorkRequest.Builder(SipForegroundService::class.java).addTag("RESTORE_CORE_TAG").build()
            WorkManager.getInstance(context).enqueue(request)
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }

    }


    private fun login(core: Core, coreListener: CoreListener, context: Context) {
        val username = "115"
        val password = "1234"
        val domain = "flexi.mcfef.com"
        Toast.makeText(context, "Call state listener ", Toast.LENGTH_LONG).show()

        val transportType = TransportType.Tcp
        val authInfo = Factory.instance().createAuthInfo(username, null, password, null, null, domain, null)
        val accountParams = core.createAccountParams()
        val identity = Factory.instance().createAddress("sip:$username@$domain")
        accountParams.identityAddress = identity
        val address = Factory.instance().createAddress("sip:$domain")

        address?.transport = transportType
        accountParams.serverAddress = address
        accountParams.contactUriParameters = "sip:$username@$domain"
        accountParams.registerEnabled = true
        accountParams.pushNotificationAllowed = true

        Log.w("Account setup params", accountParams.identityAddress.toString())
        core.addAuthInfo(authInfo)
        val account = core.createAccount(accountParams)
        core.addAccount(account)

        core.defaultAccount = account

        core.addListener(
            coreListener
        )

        core.start()



    }






}

