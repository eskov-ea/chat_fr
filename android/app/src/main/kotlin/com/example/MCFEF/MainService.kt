package com.example.MCFEF

import android.Manifest
import android.app.*
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.widget.Toast
import androidx.core.app.ActivityCompat.requestPermissions
import androidx.core.app.NotificationCompat
import com.example.MCFEF.calls_manager.CallsManagerBroadcastReceiver
import com.example.MCFEF.calls_manager.CallsNotificationManager
import com.example.MCFEF.calls_manager.Data
import io.flutter.Log
import org.linphone.core.*


class MainService(context: Context) : Service() {


    companion object {
        lateinit var core: Core
    }
    private var notification: Notification? = null
    var mNotificationManager: NotificationManager? = null
    private val mNotificationId = 123
    val android: Map<String, Any?> = mapOf(
            "isCustomNotification" to true,
            "isShowLogo" to false,
            "isShowCallback" to false,
            "isShowMissedCallNotification" to true,
            "ringtonePath" to "system_ringtone_default",
            "backgroundColor" to "#0955fa",
            "backgroundUrl" to "https://i.pravatar.cc/500",
            "actionColor" to "#4CAF50"
    )

    override fun onBind(p0: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action != null && intent.action!!.equals(
                        "ACTION_STOP_FOREGROUND", ignoreCase = true)) {
            stopForeground(true)
            stopSelf()
        }
        generateForegroundNotification()
        return START_STICKY

    }

    fun generateForegroundNotification() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val intentMainLanding = Intent(this, MainActivity::class.java)
            val pendingIntent =
                    PendingIntent.getActivity(this, 0, intentMainLanding, 0)
            if (mNotificationManager == null) {
                mNotificationManager = this.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                assert(mNotificationManager != null)
                mNotificationManager?.createNotificationChannelGroup(
                        NotificationChannelGroup("chats_group", "Chats")
                )
                val notificationChannel =
                        NotificationChannel("service_channel", "Service Notifications",
                                NotificationManager.IMPORTANCE_MIN)
                notificationChannel.enableLights(false)
                notificationChannel.lockscreenVisibility = Notification.VISIBILITY_SECRET
                mNotificationManager?.createNotificationChannel(notificationChannel)
            }
            val builder = NotificationCompat.Builder(this, "service_channel")

            builder.setContentTitle(StringBuilder("MCFEF service is running"))
                    .setTicker("MCFEF service is running")
                    .setContentText("Touch to open")
                    .setPriority(NotificationCompat.PRIORITY_MAX)
                    .setWhen(0)
                    .setOnlyAlertOnce(true)
                    .setContentIntent(pendingIntent)
                    .setOngoing(true)
            notification = builder.build()
            startForeground(mNotificationId, notification)
        }

    }

    fun getName(): String {
        return "SIP_CORE_SERVICE"
    }

    fun initialize() {
        val factory = Factory.instance()
        factory.setDebugMode(true, "Hello Linphone")
        factory.enableLogcatLogs(true)
        core = factory.createCore(null, null, this)
        core.isPushNotificationEnabled = true
    }

    fun stopCore() {
        core.stop()
    }

    private val coreListener = object: CoreListenerStub() {
        override fun onAccountRegistrationStateChanged(core: Core, account: Account, state: RegistrationState?, message: String) {

            if (state == RegistrationState.Failed || state == RegistrationState.Cleared) {
                Log.w("SIP RegistrationState status", "true")
            } else if (state == RegistrationState.Ok) {
                Log.w("SIP RegistrationState status", "false")
                val args = makePlatformEventPayload("REGISTRATION", null, null)
                MainActivity.callServiceEventSink?.success(args)
                Log.w("Account setup 4", core.defaultAccount?.params?.identityAddress.toString())
            }
        }

        override  fun onCallStateChanged(
                core: Core,
                call: Call,
                state: Call.State?,
                message: String
        ) {

            // When a call is received
            when (state) {
                Call.State.IncomingReceived -> {

                    val args: Map<String, Any?> = mapOf(
                            "nameCaller" to call.remoteAddress.username,
                            "android" to android
                    )

                    val data = Data(args).toBundle()

                }


            }
        }

    }

    fun login(username: String, password: String, domain: String) {

        val transportType = TransportType.Tcp
        val authInfo = Factory.instance().createAuthInfo(username, null, password, null, null, domain, null)
        val accountParams = core.createAccountParams()
        val identity = Factory.instance().createAddress("sip:$username@$domain")
        accountParams.identityAddress = identity
        val address = Factory.instance().createAddress("sip:$domain")

        address?.transport = transportType
        accountParams.serverAddress = address
        accountParams.registerEnabled = true
        accountParams.pushNotificationAllowed = true
        accountParams.remotePushNotificationAllowed = true

        accountParams.contactUriParameters = "sip:$username@$domain"

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