package com.example.MCFEF


import android.Manifest
import android.Manifest.permission.*
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.Intent.ACTION_OPEN_DOCUMENT_TREE
import android.content.pm.PackageManager
import android.graphics.Color
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.*
import android.provider.DocumentsContract
import android.util.Base64
import android.widget.ImageView
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.lifecycle.lifecycleScope
//import com.example.MCFEF.MainActivity.Companion.core
//import com.example.MCFEF.linphoneSDK.LinphoneSDK
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.launch
import org.linphone.core.*
import java.lang.Exception

import com.example.MCFEF.calls_manager.Data
import com.example.MCFEF.calls_manager.CallsManagerBroadcastReceiver
import android.widget.*
import androidx.work.OneTimeWorkRequest
import androidx.work.WorkManager
import com.example.MCFEF.linphoneSDK.CoreContext
import com.example.MCFEF.linphoneSDK.LinphoneCore
import com.google.firebase.iid.FirebaseInstanceId
import org.linphone.core.tools.service.CoreService


class MainActivity: FlutterActivity() {
    private val METHOD_CHANNEL_NAME = "com.application.chat/method"
    private val METHOD_CHANNEL_WRITE_FILES_PERMISSON = "com.application.chat/write_files_method"
    private val METHOD_CHANNEL_SIP = "com.application.chat/sip"
    val CREATE_FILE = 0
    var arrayBytesToWrite: String? = null

    private lateinit var ivDeclineCallButton: ImageView
    lateinit var linphoneCore : LinphoneCore

    companion object {
//        lateinit var core: Core

        //        lateinit var linphoneLib: LinphoneSDK
        var eventSink: EventChannel.EventSink? = null
        var callServiceEventSink: EventChannel.EventSink? = null
        var mainService: MainService? = null

    }
    private val callServiceEventChannel = "event.channel/call_service"

    lateinit var nat: NatPolicy

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
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME).setMethodCallHandler {
            call, result ->
            if (call.method == "getDeviceToken") {
                lifecycleScope.launch {
                    val token =  getDeviceToken()
                    Log.d("token:", "$token")
                    result.success( token )
                }
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_WRITE_FILES_PERMISSON).setMethodCallHandler {
            call, result ->
            if (call.method == "SAVE_FILE") {
                arrayBytesToWrite = call.argument<String?>("data")
                val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = call.argument<String?>("type")
                    putExtra(Intent.EXTRA_TITLE, call.argument<String?>("filename"))
                    putExtra(DocumentsContract.EXTRA_INITIAL_URI, "")
                }
                startActivityForResult(intent, CREATE_FILE)
            }
            if (call.method == "CHECK_WRITE_FILES_PERMISSION") {
                Log.w("SAVEFILE", "STARTED")
                ActivityCompat.requestPermissions(
                        this,
                        arrayOf(ACTION_OPEN_DOCUMENT_TREE),
                        0
                )
                if (checkSelfPermission(ACTION_OPEN_DOCUMENT_TREE) == PackageManager.PERMISSION_GRANTED){
                    result.success( true )
                } else {
                    result.success( false )
                }
            }
        }

//      Start listen to SIP activities
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_SIP ).setMethodCallHandler {
            call, result ->
            if (call.method.equals("SIP_LOGIN")) {
//                val username = call.argument<String?>("username")
//                val password = call.argument<String?>("password")
//                val domain = call.argument<String?>("domain")
                val username = "115"
                val password = "1234"
                val domain = "flexi.mcfef.com"

//                val username = "115cashalot"
//                val password = "1234"
//                val domain = "sip.linphone.org"

                Log.w("SIP method channel:", "$username, $password, $domain")

                if (username != null && password != null && domain != null) {
                    linphoneCore.login(username, password, domain)
//                    mainService!!.login(username, password, domain)
                }
            } else if (call.method.equals("OUTGOING_CALL")) {
                Log.w("OUTGOING", "Start event")
                val number = call.argument<String?>("number")
                if (number != null) {
                    linphoneCore.outgoingCall(number, context)
                }
            } else if (call.method.equals("DESTROY_SIP")) {
                Log.w("DESTROY_SIP", "DESTROY_SIP event")
                linphoneCore.core.stop()
            } else if (call.method.equals("DECLINE_CALL")) {
                Log.w("DECLINE_CALL", "DESTROY_SIP event")
                linphoneCore.core.currentCall?.terminate()
            } else if (call.method.equals("ACCEPT_CALL")) {
                Log.w("ACCEPT_CALL", "DESTROY_SIP event")
                linphoneCore.core.currentCall?.accept()
            } else if (call.method.equals("TOGGLE_MUTE")) {
                result.success(linphoneCore.toggleMute())
            } else if (call.method.equals("TOGGLE_SPEAKER")) {
                result.success(linphoneCore.toggleSpeaker())
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, callServiceEventChannel)
                .setStreamHandler(
                        object : EventChannel.StreamHandler {
                            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                                Log.w("callServiceEventChannel", "listen")
                                callServiceEventSink = events
                            }

                            override fun onCancel(arguments: Any?) {
                                Log.w("callServiceEventChannel", "dispose")
                                callServiceEventSink = null
                            }
                        }
                )

        super.configureFlutterEngine(flutterEngine)

    }


    private suspend fun getDeviceToken(): String? {
        val def = CompletableDeferred<String?>()
//        FirebaseMessaging.getInstance().token.addOnCompleteListener(OnCompleteListener { task ->
//            def.complete(if (task.isSuccessful) task.result else null)
//        })
        return FirebaseInstanceId.getInstance().getToken()

//        return def.await()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.w("MAIN_ACTIVITY", "APP WAS STARTED")
//        mainService = MainService()
//        mainService!!.initialize()

//        val factory = Factory.instance()
//        factory.setDebugMode(true, "Hello Linphone")
//        factory.enableLogcatLogs(true)
//        core = factory.createCore(null, null, this)
//        core.isPushNotificationEnabled = true

        val core = CoreContext(context).getInstance()
        linphoneCore = LinphoneCore(core, context)

        createNotificationChannel()

        lifecycleScope.launch {
            if (checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {

            } else {
                Log.w("ASK PERMISSION", "TO WRITE TO EXTERNAL STORAGE ")
                requestPermissions(arrayOf(WRITE_EXTERNAL_STORAGE, MANAGE_EXTERNAL_STORAGE), 0)
            }


        }
    }

    override fun onDestroy() {
        Log.w("MAIN_ACTIVITY", "APP WAS CLOSED")
        linphoneCore.core.stop()
        super.onDestroy()
    }


//    private fun login(username: String, password: String, domain: String) {
//
//        val transportType = TransportType.Tcp
//        val authInfo = Factory.instance().createAuthInfo(username, null, password, null, null, domain, null)
//        val accountParams = core.createAccountParams()
//        val identity = Factory.instance().createAddress("sip:$username@$domain")
//        accountParams.identityAddress = identity
//        val address = Factory.instance().createAddress("sip:$domain")
//
//        address?.transport = transportType
//        accountParams.serverAddress = address
//        accountParams.registerEnabled = true
//        accountParams.pushNotificationAllowed = true
//        accountParams.remotePushNotificationAllowed = true
//
//
//        accountParams.pushNotificationConfig.provider = "fcm"
//        accountParams.pushNotificationConfig.prid = "fzHsENASQWeyhDKriEVO14:APA91bFcdDCuIxguyAFKvFuTlahdGaJSGBTL05NW4bFIpytNb2EVInOzv5bE680hj2PL9-x9PTgsDhniXxM41itP_Fwwrk65DIgUNqmJXM5M35RjtpVuRQIyDYu_SWgOIHk6_x9srjQR"
//        accountParams.pushNotificationConfig.bundleIdentifier = "1:671710503893:android:9a8e318c84b6a0ad97535c"
////        Log.w("pushNotificationConfig", accountParams.pushNotificationConfig.provider)
////        Log.w("pushNotificationConfig", accountParams.pushNotificationConfig.prid)
////        Log.w("pushNotificationConfig", accountParams.pushNotificationConfig.bundleIdentifier)
//
//
//        accountParams.contactUriParameters = "sip:$username@$domain"
//
//        Log.w("Account setup params", accountParams.identityAddress.toString())
//        core.addAuthInfo(authInfo)
//        val account = core.createAccount(accountParams)
//        core.addAccount(account)
//
//        core.defaultAccount = account
//        core.addListener(
////                linphoneLib.coreListener
//                coreListener
//        )
//
////        account.addListener { _, state, message ->
////            Log.w("[Account] Registration state changed:", "$state, $message")
////        }
//
//        core.start()
//
//        if (packageManager.checkPermission(Manifest.permission.RECORD_AUDIO, packageName) != PackageManager.PERMISSION_GRANTED) {
//            requestPermissions(arrayOf(Manifest.permission.RECORD_AUDIO), 0)
//            return
//        }
//
//        if (!core.isPushNotificationAvailable) {
//            Toast.makeText(this, "Something is wrong with the push setup!", Toast.LENGTH_LONG).show()
//            Log.w("PUSH", "${core.isVerifyServerCertificates}")
//        }
//
//        startCallService(context)
//
//    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == CREATE_FILE && resultCode == RESULT_OK) {
            try {
                val uri = data!!.data
                val outputStream = this.contentResolver.openOutputStream(uri!!)
                var bytes = Base64.decode(arrayBytesToWrite, 0)
                outputStream?.write(bytes)
                outputStream?.close()


//                val file = File(getExternalFilesDir()?.path)
//                val fos = FileOutputStream(file)
//                fos.write(arrayBytesToWrite)
//                fos.close()
            } catch (e: Exception) {
                Log.w("SAVEFILE", e.toString())
            }
        }
    }

//    private val coreListener = object: CoreListenerStub() {
//        override fun onAccountRegistrationStateChanged(core: Core, account: Account, state: RegistrationState?, message: String) {
//
//            if (state == RegistrationState.Failed || state == RegistrationState.Cleared) {
//                Log.w("SIP RegistrationState status", "true")
//            } else if (state == RegistrationState.Ok) {
//                Log.w("SIP RegistrationState status", "false")
//                val args = makePlatformEventPayload("REGISTRATION", null, null)
//                callServiceEventSink?.success(args)
//                Log.w("Account setup 4", core.defaultAccount?.params?.identityAddress.toString())
//            }
//        }
//
//        override  fun onCallStateChanged(
//                core: Core,
//                call: Call,
//                state: Call.State?,
//                message: String
//        ) {
//
//            // When a call is received
//            when (state) {
//                Call.State.IncomingReceived -> {
//
//                    val args: Map<String, Any?> = mapOf(
//                        "nameCaller" to call.remoteAddress.username,
//                        "android" to android
//                    )
//
//                    val data = Data(args).toBundle()
//
//                    sendBroadcast(
//                        CallsManagerBroadcastReceiver.getIntentIncoming(
//                            context,
//                            data
//                        )
//                    )
//                    val callArgs = makePlatformEventPayload("INCOMING", call.remoteAddress.username, null)
//
//                    callServiceEventSink?.success(callArgs)
//
//                }
//                Call.State.Connected -> {
//                    Log.w("ACTIVE_CALL", "Connected   ${call.remoteAddress.username}")
//                    val args = makePlatformEventPayload("CONNECTED", call.remoteAddress.username, null)
//
//                    callServiceEventSink?.success(args)
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
//                    val callData = makeCallDataPayload(duration = call.callLog.duration.toString(),
//                        callStatus = if (call.callLog.status.name == "Success")  "ANSWERED" else "NO ANSWER",
//                        fromCaller = call.callLog.fromAddress.username,
//                        toCaller = call.callLog.toAddress.username, date = call.callLog.startDate.toString(),
//                        callId = call.callLog.callId)
//                    val args = makePlatformEventPayload("ENDED", call.remoteAddress.username, callData)
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
//                    val args = makePlatformEventPayload("OUTGOING", call.remoteAddress.username, null)
//
//                    callServiceEventSink?.success(args)
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

    private fun startCallService(context: Context) {
//        val intent = Intent(context, SipForegroundService::class.java)
        Toast.makeText(context, "startCallService", Toast.LENGTH_LONG).show()
        val request = OneTimeWorkRequest.Builder(SipForegroundService::class.java).build()
        WorkManager.getInstance(context).enqueue(request)
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            context.startForegroundService(intent)
//        } else {
//            context.startService(intent)
//        }

    }

    fun createNotificationChannel() {
        Log.w("MY_NOTIFICATION", "CREATING A NOTIFICATION CHANNEL")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Message notification channel"
            val descriptionText = "This channel is responsible for operate push notification of new message received"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val mChannel = NotificationChannel("default_notification_channel_id", name, importance)
            mChannel.description = descriptionText
            mChannel.lightColor = Color.GREEN
            mChannel.enableLights(true)
            val audioAttributes = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build()
            mChannel.setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION), audioAttributes)

            val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(mChannel)
        }
    }

}

//private fun outgoingCall(remoteSipUri: String, context: Context) {
//    Log.w("OUTGOING", "$remoteSipUri")
//    val remoteAddress = Factory.instance().createAddress(remoteSipUri)
//    remoteAddress ?: return
//
//    val params = core.createCallParams(null)
//    params ?: return
//
//    params.mediaEncryption = MediaEncryption.None
//
//
//    core.inviteAddressWithParams(remoteAddress, params)
//}

fun makePlatformEventPayload(event: String, callerId: String?, callData: Map<String, Any?>?): Map<String, Any?> {
    return mapOf(
            "event" to event,
            "callerId" to callerId,
            "callData" to callData
    )
}



/**
 * Part of code to refactor
 */
class EventHandlerSip: EventChannel.StreamHandler{

    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.w("networkEventChannel", "listen")
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        Log.w("networkEventChannel", "listen")
        eventSink = null
    }

}

/**
 * View for incoming call
 */

//private fun toggleSpeaker(): Boolean {
//    // Get the currently used audio device
//    val currentAudioDevice = core.currentCall?.outputAudioDevice
//    val speakerEnabled = currentAudioDevice?.type == AudioDevice.Type.Speaker
//
//    Log.w("toggleSpeaker", speakerEnabled.toString())
//
//    // We can get a list of all available audio devices using
//    // Note that on tablets for example, there may be no Earpiece device
//    for (audioDevice in core.audioDevices) {
////            Log.w("toggleSpeaker", audioDevice.type.toString())
//
//        if (speakerEnabled && audioDevice.type == AudioDevice.Type.Earpiece) {
//            Log.w("toggleSpeaker", "AudioDevice.Type.Microphone")
//
//            core.currentCall?.outputAudioDevice = audioDevice
//            Log.w("toggleSpeaker", (MainActivity.core.currentCall?.outputAudioDevice?.type == AudioDevice.Type.Speaker).toString())
//            return false
//        } else if (!speakerEnabled && audioDevice.type == AudioDevice.Type.Speaker) {
//            Log.w("toggleSpeaker", "AudioDevice.Type.Speaker")
//
//            core.currentCall?.outputAudioDevice = audioDevice
//            return true
//        }
////        else if (audioDevice.type == AudioDevice.Type.Bluetooth) {
////            core.currentCall?.outputAudioDevice = audioDevice
////        }
//    }
//    return false
//}

//private fun toggleMute(): Boolean {
//    core.enableMic(!core.micEnabled())
//
//    return !core.micEnabled()
//}

fun makeCallDataPayload(duration: String?, callStatus: String?, fromCaller: String?, toCaller: String?,
                        date: String?, callId: String?): Map<String, Any?> {
    return mapOf(
            "duration" to duration,
            "disposition" to callStatus,
            "dst" to toCaller,
            "src" to fromCaller,
            "calldate" to date,
            "uniqueid" to callId
    )
}