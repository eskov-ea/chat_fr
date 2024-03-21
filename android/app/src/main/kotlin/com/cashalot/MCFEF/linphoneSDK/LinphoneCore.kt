package com.cashalot.MCFEF.linphoneSDK

import android.content.Context
import android.os.PowerManager
import android.widget.Toast
import com.cashalot.MCFEF.MainActivity
import com.cashalot.MCFEF.StorageManager
import com.cashalot.MCFEF.calls_manager.CallsManagerBroadcastReceiver
import com.cashalot.MCFEF.calls_manager.Data
import com.cashalot.MCFEF.makeCallDataPayload
import com.cashalot.MCFEF.makePlatformEventPayload
import com.cashalot.MCFEF.makePlatformSipConnectionEventPayload
import io.flutter.Log
import org.linphone.core.*


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
    var pm: PowerManager
    var wakeLock: PowerManager.WakeLock

    init {
        pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = pm.newWakeLock(
            0x00000020,
            "com.cashalot.MCFEF.linphoneSDK:VOIP_CALL_LOCK_SCREEN_TAG"
        )
        contacts = sm.readData()
    }

    fun login(username: String, password: String, domain: String, stunDomain: String, stunPort: String, host: String, displayName: String?, cert: String) {
        Log.i("SIP_REG", "Register in SIP with [ $username, $password, $domain ]")
//        mediaPlayerService.playAssetConnectingSound()
        writeSipAccountToStorage(username, password, domain, stunDomain, stunPort, host, displayName, cert)

        val transportType = TransportType.Tls
        val authInfo = Factory.instance().createAuthInfo(username, null, password, null, null, domain, null)

        authInfo.tlsCert = cert

        val accountParams = core.createAccountParams()
        val identity = Factory.instance().createAddress("sip:$username@$domain")
        identity?.displayName = displayName
        accountParams.identityAddress = identity

        val address = Factory.instance().createAddress("sip:$domain")

        address?.transport = transportType

        accountParams.serverAddress = address
//        accountParams.isRegisterEnabled = true
        accountParams.registerEnabled = true
        accountParams.pushNotificationAllowed = true
        accountParams.remotePushNotificationAllowed = true

        Log.e("ADDRESS_HOST", "account domain: [${accountParams.domain}]   /    server address: [${accountParams.serverAddress?.domain}]")

        val nat: NatPolicy = core.createNatPolicy()
        nat.stunServer = "$stunDomain:$stunPort"
//        nat.isTcpTurnTransportEnabled = true
        nat.stunServerUsername = username
//        nat.isStunEnabled = true
        nat.enableTurn(true)
//        nat.isTurnEnabled = true
//        nat.isIceEnabled = true
        nat.enableIce(true)
//        core.natPolicy = nat
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
        val account = core.createAccount(accountParams)

        core.addAuthInfo(authInfo)
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

    fun logout() {
        core.clearAccounts()
        core.clearProxyConfig()
        core.clearAllAuthInfo()

        deleteSipAccountCredentialFromStorage()

    }

    private fun deleteSipAccountCredentialFromStorage() {
        val sharedPreference =  context.getSharedPreferences(CoreContext.PREFERENCE_FILENAME,Context.MODE_PRIVATE)
        val editor = sharedPreference.edit()
        editor.putString("username",null)
        editor.putString("display_name", null)
        editor.putString("password",null)
        editor.putString("domain",null)
        editor.putString("host",null)
        editor.putString("stun_domain",null)
        editor.putString("stun_port",null)
        editor.putString("cert",null)
        editor.apply()
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
        Log.i("SIP_CONTACTS", contacts.toString())
        if (contacts == null) return id
        val mapped = contacts!!.substring(1, contacts!!.length -1).trim()
        val map: Map<String, String> = mapped.split(",").associate {
            val (left, right) = it.split(":")
            left.trim() to right.trim()
        }
        Log.i("SIP_CONTACTS", map[id].toString())
        return map[id] ?: id
    }

    private fun activateWakeLockListener() {
        try {
            if (!wakeLock.isHeld){
                wakeLock.acquire()
            }
        } catch (error: Exception) {
            Log.e("Wakelock on:", error.toString())
        }
    }
    private fun deactivateWakeLockListener() {
        try {
            if (wakeLock.isHeld) {
                wakeLock.release()
            }
        } catch (error: Exception) {
            Log.e("Wakelock off:", error.toString())
        }
    }

    private val coreListener = object: CoreListenerStub() {
        override fun onAccountRegistrationStateChanged(core: Core, account: Account, state: RegistrationState?, message: String) {
            Log.w("SIP state::", "$state \r\n $message")

            if (state == RegistrationState.Failed) {
                Log.w("SIP RegistrationState status", state.toString())
                val args = makePlatformSipConnectionEventPayload("REGISTRATION_FAILED", message)
                MainActivity.sipConnectionStateEventSink?.success(args)
            } else if (state == RegistrationState.Cleared) {
                val args = makePlatformSipConnectionEventPayload("REGISTRATION_CLEARED", message)
                MainActivity.sipConnectionStateEventSink?.success(args)
                CoreContext.isLoggedIn = false
            } else if (state == RegistrationState.None) {
                val args = makePlatformSipConnectionEventPayload("REGISTRATION_NONE", message)
                MainActivity.sipConnectionStateEventSink?.success(args)
                CoreContext.isLoggedIn = false
            } else if (state == RegistrationState.Progress) {
                val args = makePlatformSipConnectionEventPayload("REGISTRATION_PROGRESS", message)
                MainActivity.sipConnectionStateEventSink?.success(args)
                CoreContext.isLoggedIn = false
            } else if (state == RegistrationState.Ok) {
                Log.w("SIP RegistrationState status", "false")
                val args = makePlatformSipConnectionEventPayload("REGISTRATION_SUCCESS", message)
                MainActivity.sipConnectionStateEventSink?.success(args)
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
                        call.remoteAddress.displayName!!
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
                    val callData = makeCallDataPayload(call)
                    val callArgs = makePlatformEventPayload("INCOMING", call.remoteAddress.username, callData)

                    MainActivity.callServiceEventSink?.success(callArgs)

                }
                Call.State.Connected -> {
                    getAudioDeviceList()
                    checkForHeadphoneDevicesAvailable(call)
                    activateWakeLockListener()
                    Log.w("ACTIVE_CALL", "Connected   ${call.remoteAddress.username} ${call.callLog.startDate}")
                    val caller = if(call.remoteAddress.displayName != null) {
                        call.remoteAddress.displayName!!
                    } else {
                        call.remoteAddress.username.toString()
                    }

//
                    val callData = makeCallDataPayload(call)
                    val args = makePlatformEventPayload("CONNECTED", call.remoteAddress.username, callData)

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
                    Log.w("[ Finish call ]", "end ${call.callLog.errorInfo}")
                    Log.w("[ Finish call ]", "end ${call.callLog.status.toInt()}")
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

                    val callData = makeCallDataPayload(call)
                    val args = makePlatformEventPayload("ENDED", null, callData)

                    MainActivity.callServiceEventSink?.success(args)
                }
                Call.State.OutgoingInit -> {
                    getAudioDeviceList()
                    activateWakeLockListener()
                    Log.w("OUTGOING_CALL", "${call.remoteAddress.username}")

                    val callData = makeCallDataPayload(call)
                    val args = makePlatformEventPayload("OUTGOING", call.remoteAddress.username, callData)

                    MainActivity.callServiceEventSink?.success(args)
                }
                Call.State.OutgoingProgress  -> {
                    Log.w("OUTGOING_CALL", "OutgoingProgress")
                }
                Call.State.OutgoingRinging -> {
                    getAudioDeviceList()
                    checkForHeadphoneDevicesAvailable(call)
                    Log.w("OUTGOING_CALL", "OutgoingRinging")
                    val callData = makeCallDataPayload(call)
                    val args = makePlatformEventPayload("OUTGOING_RINGING", call.remoteAddress.username, callData)

                    MainActivity.callServiceEventSink?.success(args)
                }
                Call.State.PushIncomingReceived -> {

                }
                Call.State.Idle -> {

                }
                Call.State.OutgoingEarlyMedia -> {

                }
                Call.State.StreamsRunning -> {
                    Log.w("ACTIVE_CALL", "StreamsRunning")

                    val callData = makeCallDataPayload(call)

                    val args = makePlatformEventPayload("STREAM_RUNNING", null, callData)

                    MainActivity.callServiceEventSink?.success(args)
                }
                Call.State.Pausing -> {

                }
                Call.State.Paused -> {
                    val callData = makeCallDataPayload(call)
                    val args = makePlatformEventPayload("PAUSED", call.remoteAddress.username, callData)
                    MainActivity.callServiceEventSink?.success(args)
                }
                Call.State.Resuming -> {
                    val callData = makeCallDataPayload(call)
                    val args = makePlatformEventPayload("RESUMED", call.remoteAddress.username, callData)
                    MainActivity.callServiceEventSink?.success(args)
                }
                Call.State.Referred -> {

                }
                Call.State.Error -> {
                    Log.w("[ Finish call ]", "end ${call.callLog.errorInfo}")
                    Log.w("[ Finish call ]", "end ${call.callLog.status.toInt()}")
                    deactivateWakeLockListener()
                    val caller = if(call.remoteAddress.displayName != null) {
                        call.remoteAddress.displayName!!
                    } else {
                        call.remoteAddress.username.toString()
                    }
                    Log.v("CALLS FIND ERROR", call.remoteAddress.username.toString())

                    val callData = makeCallDataPayload(call)

                    val args = makePlatformEventPayload("ERROR", call.remoteAddress.username, callData)

                    MainActivity.callServiceEventSink?.success(args)
                }
                Call.State.PausedByRemote -> {
                    val callData = makeCallDataPayload(call)
                    val args = makePlatformEventPayload("PAUSED", call.remoteAddress.username, callData)
                    MainActivity.callServiceEventSink?.success(args)
                }
                Call.State.UpdatedByRemote -> {

                }
                Call.State.IncomingEarlyMedia -> {

                }
                Call.State.Updating -> {

                }
                Call.State.Released -> {
                    deactivateWakeLockListener()
                    Log.w("ACTIVE_CALL", "Released   ${call.remoteAddress.username}")
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
                    val callData = makeCallDataPayload(call)

                    val args = makePlatformEventPayload("RELEASED", call.remoteAddress.username, callData)

                    MainActivity.callServiceEventSink?.success(args)
                }
                Call.State.EarlyUpdatedByRemote -> {

                }
                Call.State.EarlyUpdating -> {

                }
                null -> {

                }
            }
        }


        override  fun onAudioDevicesListUpdated(core: Core) {
            getAudioDeviceList()
            checkForHeadphoneDevicesAvailable(core.currentCall)
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

    fun makeConference() {
        try {
            Log.i("CONFERENCE_rc", "[Calls] Merging all calls into new conference")
            val params = core.createConferenceParams()

            val conference = core.createConferenceWithParams(params)
            conference?.addParticipants(core.calls)

//            val remoteAddress = Factory.instance().createAddress(remoteSipUri)
//            remoteAddress ?: return

//            val params = core.createConferenceParams()

//            val conference = core.conference ?: core.createConferenceWithParams(params)
//            conference?.addParticipants(core.calls)


            Log.w("CONFERENCE_rc", "finish $conference, $params\r\ncalls: ${core.calls}, conf: ${core.conference}")

//            core.createConferenceWithParams(params)

//            for (call in core.calls) {
//                Log.w("CONFERENCE", "calls loop: $call  ${call.userData}")
//                core.addToConference(call)
//            }
        } catch (err: Error) {
            Log.w("CONFERENCE_rc", "Error:   $err")
        }
    }

    fun hangUp() {
        if (core.callsNb == 0) return

        val call = if (core.currentCall != null) core.currentCall else core.calls[0]
        Log.i("HANGUP", "${call}")
        call ?: return

        call.terminate()
    }

    fun checkForHeadphoneDevicesAvailable(call: Call?) {
        if (call == null) {
            return
        }
        var currentDevice: AudioDevice? = call.outputAudioDevice

        if (currentDevice?.type?.toInt() == 10 || currentDevice?.type?.toInt() == 9 ||
            currentDevice?.type?.toInt() == 5 || currentDevice?.type?.toInt() == 4 ) {
            Log.w("CHECK_HEADPHONE_AUDIO_DEVICE device already set", currentDevice.type.toInt().toString())
            return
        }
        for (audioDevice in core.audioDevices) {
            Log.w("CHECK_HEADPHONE_AUDIO_DEVICE loop", "${audioDevice.type.toInt().toString()} : ${audioDevice.type.toInt() == 10}")
            if (audioDevice.type.toInt() == 10) {
                currentDevice = audioDevice
                break
            } else if (audioDevice.type.toInt() == 9) {
                currentDevice = audioDevice
                break
            } else if (audioDevice.type.toInt() == 4) {
                currentDevice = audioDevice
                break
            } else if (audioDevice.type.toInt() == 5) {
                currentDevice = audioDevice
                break
            }
        }

        if (currentDevice != null) {
            core.currentCall?.outputAudioDevice = currentDevice

            MainActivity.audioDeviceEventSink?.success(
                mapOf("event" to "CURRENT_DEVICE_ID", "data" to currentDevice.type.toInt().toString())
            )

            Log.w("CHECK_HEADPHONE_AUDIO_DEVICE result", currentDevice.type.toInt().toString())
        }
    }


    fun toggleMute(): Boolean {
        return if (core.micEnabled()) {
            core.enableMic(false)
            false
        } else {
            core.enableMic(true)
            true
        }
    }

    fun getCurrentAudioDevice() {
        try {
            var deviceId: Int? = null
            while (deviceId == null) {
                deviceId = core.currentCall?.outputAudioDevice?.type?.toInt()
                if (deviceId == null) {
                    Thread.sleep(1_000)
                }
            }

            MainActivity.audioDeviceEventSink?.success(
                mapOf("event" to "CURRENT_DEVICE_ID", "data" to deviceId.toString())
            )

            Log.w("GET_CURRENT_AUDIO_DEVICE res", deviceId.toString())
        } catch (error: Exception) {
            MainActivity.audioDeviceEventSink?.success(
                mapOf("event" to "CURRENT_DEVICE_ID", "data" to "2")
            )
        }
    }

    fun setAudioDevice(deviceId: Int) {
        for (audioDevice in core.audioDevices) {
            if (audioDevice.type.toInt() == deviceId) {
                core.currentCall?.outputAudioDevice = audioDevice
            }
        }
        getCurrentAudioDevice()
    }

    fun tryToResumeCall(callId: String?) {
        if (callId == null) {
            val args = makePlatformEventPayload("NO_SUCH_CALL", null, null)
            MainActivity.callServiceEventSink?.success(args)
        } else {
            try {
                core.calls.forEach {
                    if (it.callLog.callId == callId) {
                        it.resume()
                        return
                    }
                }
                val args = makePlatformEventPayload("NO_SUCH_CALL", null, null)
                MainActivity.callServiceEventSink?.success(args)
            } catch (e: Error) {
                val args = makePlatformEventPayload("NO_SUCH_CALL", null, null)
                MainActivity.callServiceEventSink?.success(args)
            }
        }
    }

    fun getAudioDeviceList() {
        try {
            var deviceList = listOf<Int>()
            for (audioDevice in core.audioDevices) {
                deviceList = deviceList.plus(audioDevice.type.toInt())
            }

            MainActivity.audioDeviceEventSink?.success(
                mapOf("event" to "DEVICE_LIST", "data" to deviceList)
            )

        } catch (err: Exception) {
            Log.w("__AudioDevice error", err.toString())

        }
    }

    fun toggleSpeaker(): Boolean {
        val currentAudioDevice = core.currentCall?.outputAudioDevice
        val speakerEnabled = currentAudioDevice?.type == AudioDevice.Type.Speaker
        Log.w("toggleSpeaker currentAudioDevice", currentAudioDevice?.type.toString());

        for (audioDevice in core.audioDevices) {
            if (speakerEnabled && audioDevice.type == AudioDevice.Type.Earpiece) {
                core.currentCall?.outputAudioDevice = audioDevice
            } else if (!speakerEnabled && audioDevice.type == AudioDevice.Type.Speaker) {
                core.currentCall?.outputAudioDevice = audioDevice
            }
        }
        getCurrentAudioDevice()
        return false
    }

}