package com.cashalot.MCFEF


import android.Manifest.permission.CAMERA
import android.Manifest.permission.POST_NOTIFICATIONS
import android.Manifest.permission.READ_EXTERNAL_STORAGE
import android.Manifest.permission.READ_MEDIA_IMAGES
import android.Manifest.permission.RECORD_AUDIO
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.content.Intent.ACTION_OPEN_DOCUMENT_TREE
import android.content.pm.PackageManager
import android.graphics.Color
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import android.provider.DocumentsContract
import android.util.Base64
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationManagerCompat
import androidx.lifecycle.lifecycleScope
import com.cashalot.MCFEF.linphoneSDK.CoreContext
import com.cashalot.MCFEF.linphoneSDK.LinphoneCore
import com.google.android.gms.tasks.OnCompleteListener
import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch


class MainActivity : FlutterActivity() {
    private val METHOD_CHANNEL_NAME = "com.application.chat/method"
    private val METHOD_CHANNEL_WRITE_FILES_PERMISSON = "com.application.chat/permission_method_channel"
    private val METHOD_CHANNEL_SIP = "com.application.chat/sip"
    private val METHOD_CHANNEL_AUDIO_DEVICES = "com.application.chat/audio_devices"
    private val CALL_SERVICE_EVENT_CHANNEL = "event.channel/call_service"
    private val SIP_CONNECTION_STATE_EVENT_CHANNEL = "event.channel/sip_connection_state"
    private val AUDIO_DEVICE_EVENT_CHANNEL = "event.channel/audio_device_channel"
    val CREATE_FILE = 0
    var arrayBytesToWrite: String? = null
    lateinit var linphoneCore : LinphoneCore
    var notificationManager: NotificationManagerCompat? = null
    val PERMISSION_REQUEST_CODE = 112
    private val listPermissions = listOf<String>(
        POST_NOTIFICATIONS,
        RECORD_AUDIO,
        CAMERA,
        READ_EXTERNAL_STORAGE,
        READ_MEDIA_IMAGES
    )
    private lateinit var permissionManager: PermissionManager

    companion object {

        var callServiceEventSink: EventChannel.EventSink? = null
        var sipConnectionStateEventSink: EventChannel.EventSink? = null
        var audioDeviceEventSink: EventChannel.EventSink? = null
        var deviceToken: String? = null
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {


        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_NAME).setMethodCallHandler {
            call, result ->
            if (call.method == "getDeviceToken") {
                lifecycleScope.launch {
                    val token = deviceToken
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
            if (call.method == "CHECK_APP_PERMISSION") {

                permissionManager = PermissionManager(this, listPermissions, PERMISSION_REQUEST_CODE)
                permissionManager.checkPermissions()

            }
            if (call.method == "SAVE_SIP_CONTACTS") {
                var data= call.argument<String?>("data")
                if (data != null) {
                    var sm = StorageManager(context)
                    sm.writeData(data)
                }
            }
        }

//      Start listen to SIP activities
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_SIP ).setMethodCallHandler {
            call, result ->
            Log.i("SIP_METHOD_CHANNEL", "${call.method}")
            if (call.method.equals("SIP_LOGIN")) {
                val username = call.argument<String?>("username")
                val displayName = call.argument<String?>("display_name")
                val password = call.argument<String?>("password")
                val domain = call.argument<String?>("domain")
                val stunDomain = call.argument<String?>("stun_domain")
                val stunPort = call.argument<String?>("stun_port")
                val host = call.argument<String?>("host")
                val cert = call.argument<String?>("cert")

                Log.w("SIP method channel:", "$username, $password, $domain,  $displayName, $cert")

                if (username != null && password != null && domain != null && stunDomain != null && stunPort != null && host != null && cert != null) {
                    linphoneCore.login(username, password, domain, stunDomain, stunPort, host, displayName, cert)
                }
            } else if (call.method.equals("SIP_LOGOUT")) {
                linphoneCore.logout()
            } else if (call.method.equals("OUTGOING_CALL")) {
                val number = call.argument<String?>("number")
                Log.w("OUTGOING", "Start event  $number")
                if (number != null) {
                    linphoneCore.outgoingCall(number, context)
                }
            } else if (call.method.equals("DESTROY_SIP")) {
                Log.w("DESTROY_SIP", "DESTROY_SIP event")
                linphoneCore.logout()
//                linphoneCore.core.stop()
            } else if (call.method.equals("DECLINE_CALL")) {
                Log.w("CALL", "DECLINE_CALL action")
//                linphoneCore.core.currentCall?.terminate()
                linphoneCore.hangUp()
            } else if (call.method.equals("ACCEPT_CALL")) {
                Log.w("ACCEPT_CALL", "DESTROY_SIP event")
                linphoneCore.core.currentCall?.accept()
            } else if (call.method.equals(("CHECK_FOR_RUNNING_CALL"))) {
                if (linphoneCore.core.currentCall != null) {
                    result.success(true)
                    Log.v("CHECK_FOR_RUNNING_CALL", linphoneCore.core.currentCall!!.remoteAddress.username.toString())
                    val args = makePlatformEventPayload("CONNECTED", linphoneCore.core.currentCall!!.remoteAddress.username, null)
                    callServiceEventSink?.success(args)
                } else {
                    result.success(false)
                }
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL_AUDIO_DEVICES).setMethodCallHandler {
                call, result ->
            Log.w("AUDIO_DEVICES", call.method)
            if (call.method.equals("GET_DEVICE_LIST")) {
                Log.w("AUDIO_DEVICES", call.method)
                linphoneCore.getAudioDeviceList()
            } else if (call.method.equals("TOGGLE_SPEAKER")) {
                result.success(
                    mapOf("event" to "", "data" to linphoneCore.toggleSpeaker())
                )
            } else if (call.method.equals("GET_CURRENT_AUDIO_DEVICE")) {
                linphoneCore.getCurrentAudioDevice();
            } else if (call.method.equals("SET_AUDIO_DEVICE")) {
                val deviceId = call.argument<Int?>("device_id")
                if (deviceId != null) linphoneCore.setAudioDevice(deviceId)
            } else if (call.method.equals("TOGGLE_MUTE")) {
                result.success(linphoneCore.toggleMute())
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, CALL_SERVICE_EVENT_CHANNEL)
            .setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        callServiceEventSink = events
                    }

                    override fun onCancel(arguments: Any?) {
                        callServiceEventSink = null
                    }
                }
        )

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SIP_CONNECTION_STATE_EVENT_CHANNEL)
            .setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        sipConnectionStateEventSink = events
                    }

                    override fun onCancel(arguments: Any?) {
                        sipConnectionStateEventSink = null
                    }
                }
        )

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_DEVICE_EVENT_CHANNEL)
            .setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                        Log.w("audioDeviceEventSink", "listen")
                        audioDeviceEventSink = events
                    }

                    override fun onCancel(arguments: Any?) {
                        Log.w("audioDeviceEventSink", "dispose")
                        audioDeviceEventSink = null
                    }
                }
            )

        super.configureFlutterEngine(flutterEngine)

    }


    private fun getDeviceToken() {

        FirebaseMessaging.getInstance().token.addOnCompleteListener(OnCompleteListener {
            task -> if (!task.isSuccessful) {
            Log.w("GET_PUSH", "Failed getting push")
        }
            deviceToken = task.result
        })
    }




    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        Log.v("savedInstanceState: Bundle", "Create")
        val core = CoreContext(context).getInstance()
        linphoneCore = LinphoneCore(core, context)

        createNotificationChannel()
        getDeviceToken()

        notificationManager = NotificationManagerCompat.from(this)
        notificationManager!!.cancelAll()
    }

    override fun onDestroy() {
        Log.w("MAIN_ACTIVITY", "APP WAS CLOSED")
        linphoneCore.core.stop()
        super.onDestroy()
    }


    fun getNotificationPermission() {
        try {
            if (Build.VERSION.SDK_INT > 32) {
                ActivityCompat.requestPermissions(this, arrayOf(POST_NOTIFICATIONS),
                        PERMISSION_REQUEST_CODE)
            }
        } catch (e: Exception) {
            Log.d("REQUEST_PUSH_PERMISION", e.toString())
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

            } catch (e: Exception) {
                Log.w("SAVEFILE", e.toString())
            }
        }
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

    override fun onResume() {
        super.onResume()
        notificationManager!!.cancelAll()
    }

}


fun makePlatformEventPayload(event: String, callerId: String? = null, callData: Map<String, Any?>? = null): Map<String, Any?> {
    return mapOf(
            "event" to event,
            "callerId" to callerId,
            "callData" to callData
    )
}

fun makePlatformSipConnectionEventPayload(event: String, message: String?): Map<String, Any?> {
    return mapOf(
        "event" to event,
        "message" to message
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

fun makeCallDataPayload(duration: String?, callStatus: Int?, fromCaller: String?, toCaller: String?,
                        date: String?, callId: String?): Map<String, Any?> {
    return mapOf(
            "duration" to duration,
            "reason" to callStatus,
            "sip_to" to toCaller,
            "sip_from" to fromCaller,
            "date" to date,
            "call_id" to callId
    )
}