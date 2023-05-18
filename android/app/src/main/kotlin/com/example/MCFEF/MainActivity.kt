package com.example.MCFEF


import android.Manifest
import android.Manifest.permission.*
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.content.Intent.ACTION_OPEN_DOCUMENT_TREE
import android.content.pm.PackageManager
import android.graphics.Color
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.*
import android.provider.DocumentsContract
import android.util.Base64
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.lifecycle.lifecycleScope
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.launch
import org.linphone.core.*
import java.lang.Exception
import android.widget.*
import com.example.MCFEF.linphoneSDK.CoreContext
import com.example.MCFEF.linphoneSDK.LinphoneCore
import com.google.firebase.iid.FirebaseInstanceId


class MainActivity: FlutterActivity() {
    private val METHOD_CHANNEL_NAME = "com.application.chat/method"
    private val METHOD_CHANNEL_WRITE_FILES_PERMISSON = "com.application.chat/write_files_method"
    private val METHOD_CHANNEL_SIP = "com.application.chat/sip"
    val CREATE_FILE = 0
    var arrayBytesToWrite: String? = null
    lateinit var linphoneCore : LinphoneCore

    companion object {

        var eventSink: EventChannel.EventSink? = null
        var callServiceEventSink: EventChannel.EventSink? = null

    }
    private val callServiceEventChannel = "event.channel/call_service"


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
                val username = "118"
                val password = "1234"
                val domain = "aster.mcfef.com"

                Log.w("SIP method channel:", "$username, $password, $domain")

                if (username != null && password != null && domain != null) {
                    linphoneCore.login(username, password, domain)
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
            } else if (call.method.equals(("CHECK_FOR_RUNNING_CALL"))) {
                if (linphoneCore.core.currentCall != null) {
                    result.success(true)
                    val args = makePlatformEventPayload("CONNECTED", linphoneCore.core.currentCall!!.remoteAddress.username, null)
                    callServiceEventSink?.success(args)
                } else {
                    result.success(false)
                }
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


    private fun getDeviceToken(): String? {

        return FirebaseInstanceId.getInstance().getToken()

    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

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

}


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