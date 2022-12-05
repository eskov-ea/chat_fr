//package com.example.MCFEF
//
//import android.Manifest
//import android.content.Context
//import android.content.pm.PackageManager
//import android.os.Bundle
//import android.widget.ImageView
//import android.widget.Toast
//import com.example.MCFEF.calls_manager.CallsManagerBroadcastReceiver
//import com.example.MCFEF.calls_manager.Data
//import io.flutter.Log
//import io.flutter.plugin.common.EventChannel
//import org.linphone.core.*
//
//class LinphoneSDK {
//
//    private val METHOD_CHANNEL_NAME = "com.application.chat/method"
//    private val METHOD_CHANNEL_SIP = "com.application.chat/sip"
//
//    private lateinit var ivDeclineCallButton: ImageView
//    companion object {
//        lateinit var core: Core
//        var eventSink: EventChannel.EventSink? = null
//        var callServiceEventSink: EventChannel.EventSink? = null
//    }
//    private val callServiceEventChannel = "event.channel/call_service"
//
//    lateinit var nat: NatPolicy
//
//    val android: Map<String, Any?> = mapOf(
//            "isCustomNotification" to true,
//            "isShowLogo" to false,
//            "isShowCallback" to false,
//            "isShowMissedCallNotification" to true,
//            "ringtonePath" to "system_ringtone_default",
//            "backgroundColor" to "#0955fa",
//            "backgroundUrl" to "https://i.pravatar.cc/500",
//            "actionColor" to "#4CAF50"
//    )
//
//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        Log.w("LinphoneSDK", "APP WAS STARTED")
//        val factory = Factory.instance()
//        factory.setDebugMode(true, "Hello Linphone")
//        factory.enableLogcatLogs(true)
//        MainActivity.core = factory.createCore(null, null, this)
//
//        nat = MainActivity.core.createNatPolicy()
//        nat.enableIce(true)
//        nat.stunServer = "stun.sip.us:3478"
//        nat.enableTcpTurnTransport(true)
//        nat.enableStun(true)
//        MainActivity.core.natPolicy = nat
//
//
//        core.isPushNotificationEnabled = true
//    }
//
//    private val coreListener = object: CoreListenerStub() {
//        override fun onAccountRegistrationStateChanged(core: Core, account: Account, state: RegistrationState?, message: String) {
//
//            if (state == RegistrationState.Failed || state == RegistrationState.Cleared) {
//                Log.w("SIP RegistrationState status", "true")
//            } else if (state == RegistrationState.Ok) {
//                Log.w("SIP RegistrationState status", "false")
//                val args = makePlatformEventPayload("REGISTRATION", null)
//                MainActivity.callServiceEventSink?.success(args)
////                Log.w("Account setup", account.params.contactUriParameters.toString())
//                Log.w("Account setup 4", core.defaultAccount?.params?.identityAddress.toString())
//            }
//        }
//
//        override  fun onCallStateChanged(
//                core: Core,
//                call: Call,
//                state: Call.State?,
//                message: String,
//                context: Context
//        ) {
////        findViewById<TextView>(R.id.call_status).text = message
//
//            // When a call is received
//            when (state) {
//                Call.State.IncomingReceived -> {
//
//                    val args: Map<String, Any?> = mapOf(
//                            "nameCaller" to call.remoteAddress.username,
//                            "android" to android
//                    )
//
//                    val data = Data(args).toBundle()
//
//                    sendBroadcast(
//                            CallsManagerBroadcastReceiver.getIntentIncoming(
//                                    context,
//                                    data
//                            )
//                    )
//                    val callArgs = makePlatformEventPayload("INCOMING", call.remoteAddress.username)
//
//                    MainActivity.callServiceEventSink?.success(callArgs)
//
//                }
//                Call.State.Connected -> {
//                    Log.w("ACTIVE_CALL", "Connected   ${call.remoteAddress.username}")
//                    val args = makePlatformEventPayload("CONNECTED", call.remoteAddress.username)
//
//                    MainActivity.callServiceEventSink?.success(args)
//
//                    val dargs: Map<String, Any?> = mapOf(
//                            "nameCaller" to call.remoteAddress.username,
//                            "android" to android
//                    )
//
//                    val data = Data(dargs).toBundle()
//                    sendBroadcast(
//                            CallsManagerBroadcastReceiver.getIntentDecline(
//                                    context,
//                                    data
//                            )
//                    )
//
////                    val intent = Intent(context, CurrentCall::class.java).apply {
////                        flags =
////                                Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
////                    }
////                    context.startActivity(intent)
//                }
//                Call.State.Released -> {
////                    sendBroadcast(CurrentCall.getIntentEnded())
//                    val dargs: Map<String, Any?> = mapOf(
//                            "nameCaller" to call.remoteAddress.username,
//                            "android" to android
//                    )
//
//                    val data = Data(dargs).toBundle()
//                    sendBroadcast(
//                            CallsManagerBroadcastReceiver.getIntentDecline(
//                                    context,
//                                    data
//                            )
//                    )
//                    val args = makePlatformEventPayload("ENDED", call.remoteAddress.username)
//
//                    callServiceEventSink?.success(args)
//                }
//                Call.State.OutgoingInit -> {
//                    Log.w("OUTGOING_CALL", "OutgoingInit")
////                    val intent = Intent(context, RingingCall::class.java).apply {
////                        flags =
////                                Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
////                    }
////                    context.startActivity(intent)
//
//                    val args = makePlatformEventPayload("OUTGOING", call.remoteAddress.username)
//
//                    MainActivity.callServiceEventSink?.success(args)
//                }
//                Call.State.OutgoingProgress  -> {
//                    Log.w("OUTGOING_CALL", "OutgoingProgress")
//                }
//                Call.State.OutgoingRinging -> {
//                    Log.w("OUTGOING_CALL", "OutgoingRinging")
//                }
//
//            }
//        }
//
//    }
//
//
//    private fun login(username: String, password: String, domain: String) {
//
//        val transportType = TransportType.Tcp
//        val authInfo = Factory.instance().createAuthInfo(username, null, password, null, null, domain, null)
//        val accountParams = MainActivity.core.createAccountParams()
//        val identity = Factory.instance().createAddress("sip:$username@$domain")
//        accountParams.identityAddress = identity
//        val address = Factory.instance().createAddress("sip:$domain")
//
//        address?.transport = transportType
//        accountParams.serverAddress = address
//        accountParams.contactUriParameters = "sip:$username@$domain"
//        accountParams.registerEnabled = true
//        accountParams.pushNotificationAllowed = true
//
//        Log.w("Account setup params", accountParams.identityAddress.toString())
//        val account = MainActivity.core.createAccount(accountParams)
//        MainActivity.core.addAuthInfo(authInfo)
//        MainActivity.core.addAccount(account)
//
//        core.defaultAccount = account
//        MainActivity.core.addListener(coreListener)
//
//        account.addListener { _, state, message ->
//            Log.w("[Account] Registration state changed:", "$state, $message")
//        }
//
//        core.start()
//
//        if (packageManager.checkPermission(Manifest.permission.RECORD_AUDIO, packageName) != PackageManager.PERMISSION_GRANTED) {
//            requestPermissions(arrayOf(Manifest.permission.RECORD_AUDIO), 0)
//            return
//        }
//
//        if (!MainActivity.core.isPushNotificationAvailable) {
//            Toast.makeText(this, "Something is wrong with the push setup!", Toast.LENGTH_LONG).show()
//            Log.w("PUSH", "${MainActivity.core.isVerifyServerCertificates}")
//        }
//
//    }
//}