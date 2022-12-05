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
import com.example.MCFEF.MainActivity.Companion.core
import com.example.MCFEF.linphoneSDK.LinphoneSDK
import com.google.android.gms.tasks.OnCompleteListener
import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.launch
import org.linphone.core.*
import java.io.File
import java.io.FileOutputStream
import java.lang.Exception


class MainActivity: FlutterActivity() {
    private val METHOD_CHANNEL_NAME = "com.application.chat/method"
    private val METHOD_CHANNEL_WRITE_FILES_PERMISSON = "com.application.chat/write_files_method"
    private val METHOD_CHANNEL_SIP = "com.application.chat/sip"
    val CREATE_FILE = 0
    var arrayBytesToWrite: String? = null

    private lateinit var ivDeclineCallButton: ImageView

    companion object {
        lateinit var core: Core
        lateinit var linphoneLib: LinphoneSDK
        var eventSink: EventChannel.EventSink? = null
        var callServiceEventSink: EventChannel.EventSink? = null
    }
    private val callServiceEventChannel = "event.channel/call_service"

    lateinit var nat: NatPolicy

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
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME).setMethodCallHandler {
            call, result ->
            if (call.method == "getDeviceToken") {
                lifecycleScope.launch {
                    val token =  getDeviceToken()
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



//                if (checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED &&
//                        checkSelfPermission(Manifest.permission.MANAGE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {
////                    val path = call.argument<String?>("path")
//                    val folder = filesDir
//                    val f = File(folder, "MCFEF")
//                    if (f.mkdir()) {
//                        Log.w("FILESAVER", "dir created")
//                    }
//                } else {
//                    ActivityCompat.requestPermissions(
//                            this,
//                            arrayOf(WRITE_EXTERNAL_STORAGE, READ_EXTERNAL_STORAGE, MANAGE_EXTERNAL_STORAGE),
//                            0
//                    )
//
//                    if (checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED &&
//                            checkSelfPermission(Manifest.permission.MANAGE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {
//                        val folder = filesDir
//                        val f = File(folder, "MCFEF")
//                        if (f.mkdir()) {
//                            Log.w("FILESAVER", "dir created")
//                        }
//                    } else {
//                        Log.w("FILESAVER", "Permissions not granted")
//                    }
//                }
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

//                lifecycleScope.launch {
//                    if (checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {
//                        result.success( true )
//                    } else {
//                        Log.w("ASK PERMISSION", "TO WRITE TO EXTERNAL STORAGE ")
//                        requestPermissions(arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE), 0)
////                        result.success( permissionGranted )
//                    }
//
//
//                }
            }
        }

//      Start listen to SIP activities
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_SIP ).setMethodCallHandler {
            call, result ->
            if (call.method.equals("SIP_LOGIN")) {
                val username = call.argument<String?>("username")
                val password = call.argument<String?>("password")
                val domain = call.argument<String?>("domain")

                Log.w("SIP method channel:", "$username, $password, $domain")

                if (username != null && password != null && domain != null) {
                    linphoneLib.login(username, password, domain, this)
                }
            } else if (call.method.equals("OUTGOING_CALL")) {
                Log.w("OUTGOING", "Start event")
                val number = call.argument<String?>("number")
                if (number != null) {
                    outgoingCall(number, context)
                }
            } else if (call.method.equals("DESTROY_SIP")) {
                Log.w("DESTROY_SIP", "DESTROY_SIP event")
                core?.stop()
            } else if (call.method.equals("DECLINE_CALL")) {
                Log.w("DECLINE_CALL", "DESTROY_SIP event")
                core?.currentCall?.terminate()
            } else if (call.method.equals("ACCEPT_CALL")) {
                Log.w("ACCEPT_CALL", "DESTROY_SIP event")
                core?.currentCall?.accept()
            } else if (call.method.equals("TOGGLE_MUTE")) {
                result.success(toggleMute())
            } else if (call.method.equals("TOGGLE_SPEAKER")) {
                result.success(toggleSpeaker())
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
        FirebaseMessaging.getInstance().token.addOnCompleteListener(OnCompleteListener { task ->
            def.complete(if (task.isSuccessful) task.result else null)
        })
        return def.await()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.w("MAIN_ACTIVITY", "APP WAS STARTED")
//        val factory = Factory.instance()
//        factory.setDebugMode(true, "Hello Linphone")
//        factory.enableLogcatLogs(true)
//        core = factory.createCore(null, null, this)
//
//        nat = core.createNatPolicy()
//        nat.enableIce(true)
//        nat.stunServer = "stun.sip.us:3478"
//        nat.enableTcpTurnTransport(true)
//        nat.enableStun(true)
//        core.natPolicy = nat
//
//
//        core.isPushNotificationEnabled = true
//        MyFirebaseMessagingService()
        linphoneLib = LinphoneSDK(this)
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
        core.stop()
        super.onDestroy()
    }


    private fun login(username: String, password: String, domain: String) {

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
        val account = core.createAccount(accountParams)
        core.addAuthInfo(authInfo)
        core.addAccount(account)

        core.defaultAccount = account
        core.addListener(
                linphoneLib.coreListener)

        account.addListener { _, state, message ->
            Log.w("[Account] Registration state changed:", "$state, $message")
        }

        core.start()

        if (packageManager.checkPermission(Manifest.permission.RECORD_AUDIO, packageName) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(arrayOf(Manifest.permission.RECORD_AUDIO), 0)
            return
        }

        if (!core.isPushNotificationAvailable) {
//            Toast.makeText(this, "Something is wrong with the push setup!", Toast.LENGTH_LONG).show()
            Log.w("PUSH", "${core.isVerifyServerCertificates}")
        }

    }

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
//                val args = makePlatformEventPayload("REGISTRATION", null)
//                callServiceEventSink?.success(args)
////                Log.w("Account setup", account.params.contactUriParameters.toString())
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
////        findViewById<TextView>(R.id.call_status).text = message
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
//                    val callArgs = makePlatformEventPayload("INCOMING", call.remoteAddress.username)
//
//                    callServiceEventSink?.success(callArgs)
//
//                }
//                Call.State.Connected -> {
//                    Log.w("ACTIVE_CALL", "Connected   ${call.remoteAddress.username}")
//                    val args = makePlatformEventPayload("CONNECTED", call.remoteAddress.username)
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

private fun outgoingCall(remoteSipUri: String, context: Context) {
    Log.w("OUTGOING", "$remoteSipUri")
    val remoteAddress = Factory.instance().createAddress(remoteSipUri)
    remoteAddress ?: return

    val params = core.createCallParams(null)
    params ?: return

    params.mediaEncryption = MediaEncryption.None


    core.inviteAddressWithParams(remoteAddress, params)
}

fun makePlatformEventPayload(event: String, callerId: String?): Map<String, Any?> {
    return mapOf(
            "event" to event,
            "callerId" to callerId
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
 * Convert data to JSON to send to Dart side
 */
data class CallData (
        var state: String? = null,
        var username: String? = null) {
}

/**
 * View for incoming call
 */

private fun toggleSpeaker(): Boolean {
    // Get the currently used audio device
    val currentAudioDevice = core.currentCall?.outputAudioDevice
    val speakerEnabled = currentAudioDevice?.type == AudioDevice.Type.Speaker

    Log.w("toggleSpeaker", speakerEnabled.toString())

    // We can get a list of all available audio devices using
    // Note that on tablets for example, there may be no Earpiece device
    for (audioDevice in core.audioDevices) {
//            Log.w("toggleSpeaker", audioDevice.type.toString())

        if (speakerEnabled && audioDevice.type == AudioDevice.Type.Earpiece) {
            Log.w("toggleSpeaker", "AudioDevice.Type.Microphone")

            core.currentCall?.outputAudioDevice = audioDevice
            Log.w("toggleSpeaker", (MainActivity.core.currentCall?.outputAudioDevice?.type == AudioDevice.Type.Speaker).toString())
            return false
        } else if (!speakerEnabled && audioDevice.type == AudioDevice.Type.Speaker) {
            Log.w("toggleSpeaker", "AudioDevice.Type.Speaker")

            core.currentCall?.outputAudioDevice = audioDevice
            return true
        }
//        else if (audioDevice.type == AudioDevice.Type.Bluetooth) {
//            core.currentCall?.outputAudioDevice = audioDevice
//        }
    }
    return false
}

private fun toggleMute(): Boolean {
    core.enableMic(!core.micEnabled())

    return !core.micEnabled()
}
