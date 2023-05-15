package com.example.MCFEF
//
//
//import android.annotation.SuppressLint
//import android.app.NotificationChannel
//import android.app.NotificationManager
//import android.content.Context
//import android.graphics.Color
//import android.media.AudioAttributes
//import android.media.RingtoneManager
//import android.os.Build
//import android.os.Handler
//import android.os.Looper
//import android.util.Log
//import android.widget.Toast
//import androidx.core.app.NotificationCompat
//import androidx.core.app.NotificationManagerCompat
//import com.example.MCFEF.calls_manager.CallsManagerBroadcastReceiver
//import com.example.MCFEF.calls_manager.Data
//import com.google.firebase.messaging.FirebaseMessagingService
//import com.google.firebase.messaging.RemoteMessage
//import org.linphone.core.*
//
//
//class MyFirebaseMessagingService: FirebaseMessagingService() {
//
//    override fun onNewToken(token: String) {
//        Log.d("FirebaseMessaging refresh token", "Refreshed token: $token")
//
//    }
//
//    override fun onMessageReceived(message: RemoteMessage) {
////        Toast.makeText(this, "NOTIFICATION RECEIVER", Toast.LENGTH_LONG).show()
//
//        val context = this
////        showMessage("NOTIFICATION RECEIVER", context)
//        val android: Map<String, Any?> = mapOf(
//                "isCustomNotification" to true,
//                "isShowLogo" to false,
//                "isShowCallback" to false,
//                "isShowMissedCallNotification" to true,
//                "ringtonePath" to "system_ringtone_default",
//                "backgroundColor" to "#0955fa",
//                "backgroundUrl" to "https://i.pravatar.cc/500",
//                "actionColor" to "#4CAF50"
//        )
//
//        if (message.data.isNotEmpty()) {
//            if (MainActivity.core != null && MainActivity.core.isInBackground) {
//
//                var builder = NotificationCompat.Builder(this, "default_notification_channel_id")
//                        .setSmallIcon(R.drawable.bg_button_accept)
//                        .setContentTitle("Notification from script")
//                        .setContentText("I create a notification")
//                        .setPriority(NotificationCompat.PRIORITY_MAX)
//                with(NotificationManagerCompat.from(this)) {
//                    // notificationId is a unique int for each notification that you must define
//                    notify(112211, builder.build())
//                }
//                PushBroadcastReceiver()
//                // For long-running tasks (10 seconds or more) use WorkManager.
////                Log.d(TAG, "Message data payload ")
//            } else {
//
//
//                val factory = Factory.instance()
//                val core = factory.createCore(null, null, this)
//
//                Toast.makeText(this, core.isInBackground.toString(), Toast.LENGTH_LONG).show()
//
//                val coreListener = object : CoreListenerStub() {
//                    override fun onAccountRegistrationStateChanged(core: Core, account: Account, state: RegistrationState?, message: String) {
//
//                        if (state == RegistrationState.Failed || state == RegistrationState.Cleared) {
//
//                        }
//                    }
//
//                    override fun onCallStateChanged(
//                            core: Core,
//                            call: Call,
//                            state: Call.State?,
//                            message: String
//                    ) {
//
//                        // When a call is received
//                        when (state) {
//                            Call.State.IncomingReceived -> {
////                                Toast.makeText(context, "INCOMING RECEIVED ", Toast.LENGTH_LONG).show()
//                                                        val args: Map<String, Any?> = mapOf(
//                                                                "nameCaller" to call.remoteAddress.username,
//                                                                "android" to android
//                                                        )
//
//                                                        val data = Data(args).toBundle()
//
//                                                        context.sendBroadcast(
//                                                                CallsManagerBroadcastReceiver.getIntentIncoming(
//                                                                        context,
//                                                                        data
//                                                                )
//                                                        )
//
//                            }
//
//                        }
//                    }
//                }
//
//                val username = "115"
//                val password = "1234"
//                val domain = "flexi.mcfef.com"
//
//                val transportType = TransportType.Tcp
//                val authInfo = Factory.instance().createAuthInfo(username, null, password, null, null, domain, null)
//                val accountParams = core.createAccountParams()
//                val identity = Factory.instance().createAddress("sip:$username@$domain")
//                accountParams.identityAddress = identity
//                val address = Factory.instance().createAddress("sip:$domain")
//
//                address?.transport = transportType
//                accountParams.serverAddress = address
//                accountParams.contactUriParameters = "sip:$username@$domain"
//                accountParams.registerEnabled = true
//                accountParams.pushNotificationAllowed = true
//
//                core.addAuthInfo(authInfo)
//                val account = core.createAccount(accountParams)
//                core.addAccount(account)
//
//                core.defaultAccount = account
//
//                core.addListener(
//                        coreListener
//                )
//
//                core.start()
//
//
//
//                if (message.notification?.channelId == "CALLKIT_NOTIFICATION_CHANNEL") {
//
//                }
//            }
//
//
//
//
//
//
//            fun createNotificationChannel() {
//                io.flutter.Log.w("MY_NOTIFICATION", "CREATING A NOTIFICATION CHANNEL")
//                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//                    val name = "New message notification channel"
//                    val descriptionText = "This channel responsible for operate push notification of new message received"
//                    val importance = NotificationManager.IMPORTANCE_HIGH
//                    val mChannel = NotificationChannel("default_notification_channel_id", name, importance)
//                    mChannel.description = descriptionText
//                    mChannel.lightColor = Color.GREEN
//                    mChannel.enableLights(true)
//                    val audioAttributes = AudioAttributes.Builder()
//                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
//                            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
//                            .build()
//                    mChannel.setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION), audioAttributes)
//
//                    val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
//                    notificationManager.createNotificationChannel(mChannel)
//                }
//            }
//
//
//        }
//    }
//}
//
//fun showMessage(msg: String, context: Context) {
//    Looper.prepare() //Call looper.prepare()
//
//
//    val mHandler: Handler = @SuppressLint("HandlerLeak")
//    object : Handler() {
//        fun handleMessage(msg: String) {
//            Toast.makeText(context, msg, Toast.LENGTH_LONG).show()
//        }
//    }
//
//    Looper.loop()
//}