package com.example.MCFEF.linphoneSDK

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.widget.Toast
import androidx.core.app.ActivityCompat.requestPermissions
import com.example.MCFEF.MainActivity
import com.example.MCFEF.calls_manager.CallsManagerBroadcastReceiver
import com.example.MCFEF.calls_manager.Data
import com.example.MCFEF.makeCallDataPayload
import com.example.MCFEF.makePlatformEventPayload
import com.google.firebase.messaging.FirebaseMessaging
import io.flutter.Log
import org.linphone.core.*
import com.example.MCFEF.StorageManager

class LinphoneCore constructor(var core: Core, var context: Context) {

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
    val sm = StorageManager(context)
    var contacts: String? = null

    init {
        contacts = sm.readData()
    }

    fun login(username: String, password: String, domain: String, stunDomain: String, stunPort: String, host: String, displayName: String?, cert: String) {
        Log.i("SIP_REG", "Register in SIP with [ $username, $password, $domain ]")

        writeSipAccountToStorage(username, password, domain, stunDomain, stunPort, host, displayName, cert)

        val transportType = TransportType.Tls
        val authInfo = Factory.instance().createAuthInfo(username, null, password, null, null, domain, null)

        authInfo.tlsCert = cert
//        authInfo.tlsCert = this::class.java.classLoader.getResource("assets/certs/aster.mcfef.com.txt").readText()

        val accountParams = core.createAccountParams()
        val identity = Factory.instance().createAddress("sip:$username@$domain")
        identity?.displayName = displayName
        accountParams.identityAddress = identity

        val address = Factory.instance().createAddress("sip:$domain")

        address?.transport = transportType

        accountParams.serverAddress = address
        accountParams.registerEnabled = true
        accountParams.pushNotificationAllowed = true
        accountParams.remotePushNotificationAllowed = true

        Log.e("ADDRESS_HOST", "account domain: [${accountParams.domain}]   /    server address: [${accountParams.serverAddress?.domain}]")

        val nat = core.createNatPolicy()
//        nat.stunServer = "aster.mcfef.com:3478"
        nat.stunServer = "$stunDomain:$stunPort"
        nat.enableTcpTurnTransport(true)
        nat.stunServerUsername = username


        nat.enableStun(true)
        nat.enableTurn(true)
        nat.enableIce(true)
        core.natPolicy = nat
        accountParams.natPolicy = nat

        accountParams.contactUriParameters = "sip:$username@$domain"

        val token = MainActivity.deviceToken
        if (token != null) {
            accountParams.pushNotificationConfig.remoteToken = token
            accountParams.pushNotificationConfig.param = "671710503893"
            accountParams.pushNotificationConfig.provider = "fcm"
            accountParams.pushNotificationConfig.prid = token
            accountParams.pushNotificationConfig.bundleIdentifier = "671710503893"
        }

        Log.w("Account setup params", accountParams.identityAddress.toString())
        core.addAuthInfo(authInfo)
        val account = core.createAccount(accountParams)
        core.addAccount(account)

        core.defaultAccount = account
        core.addListener(
            coreListener
        )

        account.addListener { _, state, message ->
            Log.w("[Account] Registration state changed:", "$state, $message")
        }

        core.start()

    }

    private fun writeSipAccountToStorage(username: String, password: String, domain: String, stunDomain: String, stunPort: String,  host: String, displayName: String?, cert: String) {
        val sharedPreference =  context.getSharedPreferences(CoreContext.PREFERENCE_FILENAME,Context.MODE_PRIVATE)
        val editor = sharedPreference.edit()
        editor.putString("username",username)
        editor.putString("display_name", displayName)
        editor.putString("password",password)
        editor.putString("domain",domain)
        editor.putString("host",host)
        editor.putString("stun_domain",stunDomain)
        editor.putString("stun_port",stunPort)
        editor.putString("cert",cert)
        editor.apply()
    }

    fun readSipAccountFromStorageAndLogin() {
        val sharedPreference =  context.getSharedPreferences(CoreContext.PREFERENCE_FILENAME,Context.MODE_PRIVATE)
        val username = sharedPreference.getString("username", null)
        val displayName = sharedPreference.getString("display_name", null)
        val password = sharedPreference.getString("password", null)
        val domain = sharedPreference.getString("domain", null)
        val stunDomain = sharedPreference.getString("stun_domain", null)
        val stunPort = sharedPreference.getString("stun_port", null)
        val host = sharedPreference.getString("host", null)
        val cert = sharedPreference.getString("cert", null)

        if (username != null && password != null && domain != null && stunDomain != null && stunPort != null && host != null && cert != null) {
            login(username, password, domain, stunDomain, stunPort, host, displayName, cert)
        } else {
            Toast.makeText(context, "Входящий вызов получен, но не может быть обработан. Запустите MCFEF вручную", Toast.LENGTH_LONG).show()
        }
    }

    fun getCallerFromContacts(id: String): String {
        if (contacts == null) return id
        val mapped = contacts!!.substring(1, contacts!!.length -1).trim()
        val map: Map<String, String> = mapped.split(",").associate {
            val (left, right) = it.split(":")
            left.trim() to right.trim()
        }
        Log.i("SIP_CONTACTS", map[id].toString())
        return map[id] ?: id
    }

    private val coreListener = object: CoreListenerStub() {
        override fun onAccountRegistrationStateChanged(core: Core, account: Account, state: RegistrationState?, message: String) {

            if (state == RegistrationState.Failed || state == RegistrationState.Cleared) {
                Log.w("SIP RegistrationState status", "true")
                val args = makePlatformEventPayload("REGISTRATION_FAILED", null, null)
                MainActivity.callServiceEventSink?.success(args)
            } else if (state == RegistrationState.Ok) {
                Log.w("SIP RegistrationState status", "false")
                val args = makePlatformEventPayload("REGISTRATION_SUCCESS", null, null)
                MainActivity.callServiceEventSink?.success(args)
                CoreContext.core = core
                CoreContext.isLoggedIn = true
            }
        }

        override  fun onCallStateChanged(
            core: Core,
            call: Call,
            state: Call.State?,
            message: String
        ) {
            Log.i("onCallStateChanged", state.toString())
            // When a call is received
            when (state) {
                Call.State.IncomingReceived -> {
                    val caller = if(call.remoteAddress.displayName != null) {
                        getCallerFromContacts(call.remoteAddress.username.toString())
//                        call.remoteAddress.displayName!!
                    } else {
                        getCallerFromContacts(call.remoteAddress.username.toString())
                    }
                    Log.w("ACTIVE_CALL", "IncomingReceived   $caller, ${call.remoteAddress.domain}, ${call.remoteAddress.scheme}, ${call.remoteAddress.displayName}, ${call.remoteAddress.transport}")
                    val args: Map<String, Any?> = mapOf(
                        "nameCaller" to caller,
                        "android" to android
                    )

                    val data = Data(args).toBundle()

                    context.sendBroadcast(
                        CallsManagerBroadcastReceiver.getIntentIncoming(
                            context,
                            data
                        )
                    )
                    val callArgs = makePlatformEventPayload("INCOMING", call.remoteAddress.username, null)

                    MainActivity.callServiceEventSink?.success(callArgs)

                }
                Call.State.Connected -> {
                    Log.w("ACTIVE_CALL", "Connected   ${call.remoteAddress.username}")
                    val caller = if(call.remoteAddress.displayName != null) {
                        call.remoteAddress.displayName!!
                    } else {
                        call.remoteAddress.username.toString()
                    }
                    val args = makePlatformEventPayload("CONNECTED", call.remoteAddress.username, null)

                    MainActivity.callServiceEventSink?.success(args)

                    val dargs: Map<String, Any?> = mapOf(
                        "nameCaller" to caller,
                        "android" to android
                    )

                    val data = Data(dargs).toBundle()
                    context.sendBroadcast(
                        CallsManagerBroadcastReceiver.getIntentDecline(
                            context,
                            data
                        )
                    )
                }
                Call.State.End -> {
                    Log.w("ACTIVE_CALL", "Ended   ${call.remoteAddress.username}")
                    val caller = if(call.remoteAddress.displayName != null) {
                        call.remoteAddress.displayName!!
                    } else {
                        call.remoteAddress.username.toString()
                    }
                    val dargs: Map<String, Any?> = mapOf(
                            "nameCaller" to caller,
                            "android" to android
                    )

                    val data = Data(dargs).toBundle()
                    context.sendBroadcast(
                            CallsManagerBroadcastReceiver.getIntentDecline(
                                    context,
                                    data
                            )
                    )
                    val callData = makeCallDataPayload(duration = call.callLog.duration.toString(),
                            callStatus = if (call.callLog.status.name == "Success")  "ANSWERED" else "NO ANSWER",
                            fromCaller = call.callLog.fromAddress.username,
                            toCaller = call.callLog.toAddress.username, date = call.callLog.startDate.toString(),
                            callId = call.callLog.callId)
                    val args = makePlatformEventPayload("ENDED", call.remoteAddress.username, callData)

                    MainActivity.callServiceEventSink?.success(args)
                }
                Call.State.OutgoingInit -> {
                    Log.w("OUTGOING_CALL", "OutgoingInit")

                    val caller = if(call.remoteAddress.displayName != null) {
                        call.remoteAddress.displayName!!
                    } else {
                        call.remoteAddress.username.toString()
                    }
                    val args = makePlatformEventPayload("OUTGOING", call.remoteAddress.username, null)

                    MainActivity.callServiceEventSink?.success(args)
                }
                Call.State.OutgoingProgress  -> {
                    Log.w("OUTGOING_CALL", "OutgoingProgress")
                }
                Call.State.OutgoingRinging -> {
                    Log.w("OUTGOING_CALL", "OutgoingRinging")
                }
                Call.State.PushIncomingReceived -> {

                }
                Call.State.Idle -> {

                }
                Call.State.OutgoingEarlyMedia -> {

                }
                Call.State.StreamsRunning -> {

                }
                Call.State.Pausing -> {

                }
                Call.State.Paused -> {

                }
                Call.State.Resuming -> {

                }
                Call.State.Referred -> {

                }
                Call.State.Error -> {
                    val caller = if(call.remoteAddress.displayName != null) {
                        call.remoteAddress.displayName!!
                    } else {
                        call.remoteAddress.username.toString()
                    }
                    val args = makePlatformEventPayload("ERROR", call.remoteAddress.username, null)

                    MainActivity.callServiceEventSink?.success(args)
                }
                Call.State.PausedByRemote -> {

                }
                Call.State.UpdatedByRemote -> {

                }
                Call.State.IncomingEarlyMedia -> {

                }
                Call.State.Updating -> {

                }
                Call.State.Released -> {

                }
                Call.State.EarlyUpdatedByRemote -> {

                }
                Call.State.EarlyUpdating -> {

                }
                null -> {

                }
            }
        }

    }

    fun outgoingCall(remoteSipUri: String, context: Context) {
        val remoteAddress = Factory.instance().createAddress(remoteSipUri)
        remoteAddress ?: return

        val params = core.createCallParams(null)
        params ?: return

        params.mediaEncryption = MediaEncryption.None

        Log.w("OUTGOING", "$remoteAddress, $params")

        core.inviteAddressWithParams(remoteAddress, params)
    }

    fun toggleMute(): Boolean {
        core.enableMic(!core.micEnabled())

        return !core.micEnabled()
    }

    fun toggleSpeaker(): Boolean {
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
                Log.w("toggleSpeaker", (core.currentCall?.outputAudioDevice?.type == AudioDevice.Type.Speaker).toString())
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

}