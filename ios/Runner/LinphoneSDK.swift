//
//  LinphoneSDK.swift
//  Runner
//
//  Created by john on 14.07.2022.
//

import linphonesw


class LinphoneSDK : ObservableObject
{
    var mCore: Core!
        @Published var coreVersion: String = Core.getVersion
        
        var eventSink: FlutterEventSink?
        var audioDeviceSink: FlutterEventSink?
        var connectionEventSink: FlutterEventSink?
        
        var mAccount: Account?
        var mCoreDelegate : CoreDelegate!
        @Published var username : String = "user"
        @Published var passwd : String = "pwd"
        @Published var domain : String = "sip.example.org"
        @Published var loggedIn: Bool = false
        
        // Incoming call variables
        @Published var callMsg : String = ""
        @Published var isCallIncoming : Bool = false
        @Published var isCallRunning : Bool = false
        @Published var remoteAddress : String = "Nobody yet"
        @Published var isSpeakerEnabled : Bool = false
        @Published var isMicrophoneEnabled : Bool = false

        // Outgoing call related variables
        @Published var isVideoEnabled : Bool = false
        @Published var canChangeCamera : Bool = false
    
        // CallKit related variables
        var incomingCallName = "Unknown"
        var mCall : Call?
        var mProviderDelegate : CallKitProviderDelegate!
        var mCallAlreadyStopped : Bool = false;
        var outgoingNumber = ""
        var isOutgoingCallInited: Bool = false
        var sm: StorageManager!
        private var currentConnectionState: RegistrationState = RegistrationState.None


    
    init()
    {
        
//        eventSink = calleventSinc
//        audioDeviceSink = audioDeviceEventSinc
//        self.connectionStateSink = connectionStateSink
        sm = StorageManager()
        let factory = Factory.Instance
        let configDir = factory.getConfigDir(context: nil)
        
        try? mCore = Factory.Instance.createCore(configPath: "\(configDir)/linphonerc", factoryConfigPath: "", systemContext: nil)
        mProviderDelegate = CallKitProviderDelegate(context: self)
        // enabling push notifications management in the core
        mCore.callkitEnabled = true
        mCore.pushNotificationEnabled = true
        
        try? mCore.start()
        
        print("push status \(mCore.isPushNotificationAvailable)")
        
        mCoreDelegate = CoreDelegateStub( onCallStateChanged: { (core: Core, call: Call, state: Call.State, message: String) in
                print("Service State:  \(state)")
                self.callMsg = message
                if (state == .PushIncomingReceived){
                    // We're being called by someone (and app is in background)
                    self.mCall = call
                    self.isCallIncoming = true
                    self.incomingCallName = call.remoteAddress?.displayName ?? "Неизвестен"
                    self.mProviderDelegate.incomingCall()
                } else if (state == .IncomingReceived) { // When a call is received
                    if (!self.isCallIncoming) {
                        self.mCall = call
                        
                        self.incomingCallName = self.getCallerName()
                        self.isCallIncoming = true
                        let payload = makeCallEventPayload(event: "INCOMING", callerId: call.remoteAddress?.username, callData: nil)
                        self.eventSink?(payload)
                        self.mProviderDelegate.incomingCall()
                    } else {
                        if(self.incomingCallName == "Неизвестен" ||
                           self.incomingCallName == "Anonymous") {
                            let name = self.getCallerName()
                            self.mProviderDelegate.updateIncomingCall(callerName: name)
                        }
                    }
                    self.remoteAddress = call.remoteAddress!.asStringUriOnly()
                } else if (state == .Connected) { // When a call
                    self.isCallRunning = true
                    self.getAudioDeviceList()
                    self.getCurrentAudioDevice()
                    let callData = CallData(duration: call.callLog?.duration.description, disposition: self.getCallStatus(code: call.callLog?.status.rawValue), dst: call.callLog?.toAddress?.username, src: call.callLog?.fromAddress?.username, calldate: call.callLog?.startDate.description, uniqueid: call.callLog?.callId)
                    let payload = makeCallEventPayload(event: "CONNECTED", callerId: call.remoteAddress?.username, callData: callData)
                    self.eventSink?(payload)
                } else if ( state == .Released ) {
                    let callData = CallData(duration: call.callLog?.duration.description, disposition: self.getCallStatus(code: call.callLog?.status.rawValue), dst: call.callLog?.toAddress?.username, src: call.callLog?.fromAddress?.username, calldate: call.callLog?.startDate.description, uniqueid: call.callLog?.callId   )
                        print("CALL_STATUS  \(callData)")
                    let payload = makeCallEventPayload(event: "RELEASED", callerId: call.remoteAddress?.username, callData: callData)
                    print("CALL_ENDED IOS  \(callData)")
                    self.eventSink?(payload)
                    self.mProviderDelegate.stopCall()
                    self.isCallRunning = false
                    self.remoteAddress = "Nobody yet"
                } else if (state == .End) {
                    print("End call reason: \(call.callLog?.errorInfo)")
                    let callData = CallData(duration: call.callLog?.duration.description, disposition: self.getCallStatus(code: call.callLog?.status.rawValue), dst: call.callLog?.toAddress?.username, src: call.callLog?.fromAddress?.username, calldate: call.callLog?.startDate.description, uniqueid: call.callLog?.callId)
                    let payload = makeCallEventPayload(event: "ENDED", callerId: call.remoteAddress?.username, callData: callData)
                    self.eventSink?(payload)
                    self.mProviderDelegate.stopCall()
                    self.isCallRunning = false
                } else if (state == .Error) {
                    print("End call reason err: \(call.callLog?.errorInfo.unsafelyUnwrapped)")
                    let callData = CallData(duration: call.callLog?.duration.description, disposition: self.getCallStatus(code: call.callLog?.status.rawValue), dst: call.callLog?.toAddress?.username, src: call.callLog?.fromAddress?.username, calldate: call.callLog?.startDate.description, uniqueid: call.callLog?.callId)
                    let payload = makeCallEventPayload(event: "ERROR", callerId: call.remoteAddress?.username, callData: callData)
                    self.eventSink?(payload)
                    self.mProviderDelegate.stopCall()
                    self.isCallRunning = false
                }  else if (state == .OutgoingInit) {
                    let callData = CallData(duration: call.callLog?.duration.description, disposition: self.getCallStatus(code: call.callLog?.status.rawValue), dst: call.callLog?.toAddress?.username, src: call.callLog?.fromAddress?.username, calldate: call.callLog?.startDate.description, uniqueid: call.callLog?.callId)
                    let payload = makeCallEventPayload(event: "OUTGOING", callerId: call.remoteAddress?.username, callData: callData)
                    self.isCallRunning = true
                    self.eventSink?(payload)
                } else if (state == .OutgoingProgress) {
                    print("Call.State  ->  \(state)")
                    self.getAudioDeviceList()
                    self.getCurrentAudioDevice()
                    // Right after outgoing init
                } else if (state == .OutgoingRinging) {
                    self.isCallRunning = true
                    let callData = CallData(duration: call.callLog?.duration.description, disposition: self.getCallStatus(code: call.callLog?.status.rawValue), dst: call.callLog?.toAddress?.username, src: call.callLog?.fromAddress?.username, calldate: call.callLog?.startDate.description, uniqueid: call.callLog?.callId)
                    let payload = makeCallEventPayload(event: "OUTGOING_RINGING", callerId: call.remoteAddress?.username, callData: callData)
                    self.eventSink?(payload)
                } else if (state == .StreamsRunning) {
                    let callData = CallData(duration: call.callLog?.duration.description, disposition: self.getCallStatus(code: call.callLog?.status.rawValue), dst: call.callLog?.toAddress?.username, src: call.callLog?.fromAddress?.username, calldate: call.callLog?.startDate.description, uniqueid: call.callLog?.callId)
                    let payload = makeCallEventPayload(event: "STREAM_RUNNING", callerId: call.remoteAddress?.username, callData: callData)
                    self.eventSink?(payload)
                    // This state indicates the call is active.
                    // You may reach this state multiple times, for example after a pause/resume
                    // or after the ICE negotiation completes
                    // Wait for the call to be connected before allowing a call update
                    self.isCallRunning = true
                    
                    // Only enable toggle camera button if there is more than 1 camera
                    // We check if core.videoDevicesList.size > 2 because of the fake camera with static image created by our SDK (see below)
//                    self.canChangeCamera = core.videoDevicesList.count > 2
                } else if (state == .Paused) {
                    // When you put a call in pause, it will became Paused
                    self.canChangeCamera = false
                } else if (state == .PausedByRemote) {
                    // When the remote end of the call pauses it, it will be PausedByRemote
                } else if (state == .Updating) {
                    // When we request a call update, for example when toggling video
                } else if (state == .UpdatedByRemote) {
                    // When the remote requests a call update
                }

            }, onAudioDeviceChanged: { (core: Core, device: AudioDevice) in
                // This callback will be triggered when a successful audio device has been changed
                print("onAudioDeviceChanged  \(device.type.rawValue)")
                self.getCurrentAudioDevice()
            }, onAudioDevicesListUpdated: { (core: Core) in
                self.getAudioDeviceList()
            }, onAccountRegistrationStateChanged: { (core: Core, account: Account, state: RegistrationState, message: String) in
                if (self.currentConnectionState == state) {return}
                self.currentConnectionState = state
                NSLog("New registration state \(state) \(self.currentConnectionState) \(message)")
                if (state == .Ok) {
                    self.loggedIn = true
                    let payload = makeSipConnectionEventPayload(event: "REGISTRATION_SUCCESS", message: message)
                    self.connectionEventSink?(payload)
                } else if (state == .Cleared) {
                    self.loggedIn = false
                    let payload = makeSipConnectionEventPayload(event: "REGISTRATION_CLEARED", message: message)
                    self.connectionEventSink?(payload)
                } else if (state == .Failed) {
                    self.loggedIn = false
                    let payload = makeSipConnectionEventPayload(event: "REGISTRATION_FAILED", message: message)
                    self.connectionEventSink?(payload)
                } else if (state == .None) {
                    self.loggedIn = false
                    let payload = makeSipConnectionEventPayload(event: "REGISTRATION_NONE", message: message)
                    self.connectionEventSink?(payload)
                } else if (state == .Progress) {
                    self.loggedIn = false
                    let payload = makeSipConnectionEventPayload(event: "REGISTRATION_PROGRESS", message: message)
                    self.connectionEventSink?(payload)
                }
        })

        mCore.addDelegate(delegate: mCoreDelegate)

    }
    
    func getCallerName() -> String {
        let displayName = mCall?.remoteAddress?.displayName
        if(displayName != nil && displayName != "") {return displayName!}
        let callerId: String = mCall?.remoteAddress?.username ?? "Неизвестен"
        do {
            let storedContacts = sm.readDataFromDocuments()
            let callerName = try storedContacts!.contacts[callerId]
            return callerName ?? callerId
        } catch {
            return callerId
        }
    }
    
    func checkForRunningCall() -> Bool {
        if (self.isCallRunning) {
            let payload = makeCallEventPayload(event: "CONNECTED", callerId: mCore!.currentCall?.remoteAddress?.username, callData: nil)
            self.eventSink?(payload)
            return true
        }
        return false
    }
    
    func outgoingCall(number: String) {
            do {
                outgoingNumber = number
                // As for everything we need to get the SIP URI of the remote and convert it to an Address
                let remoteAddress = try Factory.Instance.createAddress(addr: number)
                
                // We also need a CallParams object
                // Create call params expects a Call object for incoming calls, but for outgoing we must use null safely
                let params = try mCore.createCallParams(call: nil)
                
                // We can now configure it
                // Here we ask for no encryption but we could ask for ZRTP/SRTP/DTLS
                params.mediaEncryption = MediaEncryption.None
                // If we wanted to start the call with video directly
                //params.videoEnabled = true
                
                // Finally we start the call
                let _call = mCore.inviteAddressWithParams(addr: remoteAddress, params: params)
                self.incomingCallName = _call?.toAddress?.username ?? "Unknown"
                self.mProviderDelegate.outgoingCall()
                // Call process can be followed in onCallStateChanged callback from core listener
                print("OUTGOING CALL  ->  \( String(describing: _call) )")
            } catch { NSLog(error.localizedDescription) }
            
        }

    
    func login(domain: String, password: String, username: String,
               stunDomain: String, stunPort: String, host: String, cert: String) {
            
            do {
                
                var transport : TransportType
                transport = TransportType.Tls
                
                let authInfo = try Factory.Instance.createAuthInfo(username: username, userid: "", passwd: password, ha1: "", realm: "", domain: domain)
                authInfo.tlsCert = cert
                let accountParams = try mCore.createAccountParams()
                let identity = try Factory.Instance.createAddress(addr: String("sip:" + username + "@" + domain))
                try! accountParams.setIdentityaddress(newValue: identity)
                let address = try Factory.Instance.createAddress(addr: String("sip:" + domain))
                try address.setTransport(newValue: transport)
                try accountParams.setServeraddress(newValue: address)
                accountParams.registerEnabled = true
                accountParams.pushNotificationAllowed = true
                accountParams.pushNotificationConfig?.provider = "apns"
                let account = try mCore.createAccount(params: accountParams)
                
                let nat = try? mCore.createNatPolicy()
                nat?.stunServer = "\(stunDomain):\(stunPort)"
                nat?.tcpTurnTransportEnabled = true
                nat?.stunServerUsername = username
                nat?.stunEnabled = true
                nat?.turnEnabled = true
                nat?.iceEnabled = true
                
                mCore.addAuthInfo(info: authInfo)
                try mCore.addAccount(account: account)
                mCore.defaultAccount = account
                mCore.natPolicy = nat
                accountParams.natPolicy = nat
            } catch { NSLog(error.localizedDescription) }
        }
    
        func logout() {
            mCore.clearAccounts()
            mCore.clearProxyConfig()
            mCore.clearAllAuthInfo()
            
            let factory = Factory.Instance
            let configDir = factory.getConfigDir(context: nil)
            let path = "\(configDir)/linphonerc"
            if (FileManager.default.fileExists(atPath: path)) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                    print("File deleted")
                } catch {
                    print("Could not delete file \(error)")
                }
            }
        }
    
        func declineCall() {
            do {
                try mCore?.currentCall?.terminate()
            } catch {
                print("Decline call error: \(error)")
            }
//            self.mProviderDelegate.stopCall()
        }
        
        func unregister()
        {
            if let account = mCore.defaultAccount {
                let params = account.params
                let clonedParams = params?.clone()
                clonedParams?.registerEnabled = false
                account.params = clonedParams
            }
        }
        func delete() {
            if let account = mCore.defaultAccount {
                mCore.removeAccount(account: account)
                mCore.clearAccounts()
                mCore.clearAllAuthInfo()
            }
        }
        
        func terminateCall() {
            do {
                self.mProviderDelegate.stopCall()
                if (mCore.callsNb == 0) { return }
                
                // If the call state isn't paused, we can get it using core.currentCall
                let coreCall = (mCore.currentCall != nil) ? mCore.currentCall : mCore.calls[0]
                
                // Terminating a call is quite simple
                if let call = coreCall {
                    try call.terminate()
                }
            } catch {
                print("Terminate call error: \(error)")
                NSLog(error.localizedDescription)
                
            }
        }
    
        func pauseOrResume() {
            do {
                if (mCore.callsNb == 0) { return }
                let coreCall = (mCore.currentCall != nil) ? mCore.currentCall : mCore.calls[0]
                
                if let call = coreCall {
                    if (call.state != Call.State.Paused && call.state != Call.State.Pausing) {
                        // If our call isn't paused, let's pause it
                        try call.pause()
                    } else if (call.state != Call.State.Resuming) {
                        // Otherwise let's resume it
                        try call.resume()
                    }
                }
            } catch { NSLog(error.localizedDescription) }
        }

        
        func acceptCall() {
            // IMPORTANT : Make sure you allowed the use of the microphone (see key "Privacy - Microphone usage description" in Info.plist) !
            do {
                // if we wanted, we could create a CallParams object
                // and answer using this object to make changes to the call configuration
                // (see OutgoingCall tutorial)
                try mCore.currentCall?.accept()
            } catch {
                print("Accept call error: \(error)")
                NSLog(error.localizedDescription)
            }
        }
        
    func muteMicrophone() -> Bool {
            mCore.micEnabled = !mCore.micEnabled
            isMicrophoneEnabled = !isMicrophoneEnabled
            
        print("muteMicrophone  \(mCore.micEnabled)")
            return isMicrophoneEnabled
        }
        
    func getAudioDeviceList() {
        do {
            var deviceList = [Int]()
            for audioDevice in mCore.audioDevices {
                deviceList.append(audioDevice.type.rawValue)
                if (audioDevice.type.rawValue == 0) {
                    print("0 audio device: \(audioDevice.deviceName), \(audioDevice.driverName), \(audioDevice.id), \(audioDevice.type)")
                }
            }
            let eventPayload = makeAudioDeviceEventPayload(event: "DEVICE_LIST", data: deviceList.description)
            print("Audio device list:  \(deviceList)")
            self.audioDeviceSink?(eventPayload)
        } catch {
            print("Error happened while get device list:  \(error)")
        }
    }
    
    func setAudioDevice(id: Int) {
        for audioDevice in mCore.audioDevices {
            if (audioDevice.type.rawValue == id) {
                mCore.currentCall?.outputAudioDevice = audioDevice
            }
        }
        print("We set ad: \(id)")
        
        self.getAudioDeviceList()
        self.getCurrentAudioDevice()
    }
    
    func getCurrentAudioDevice() {
        do {
            var deviceId: Int? = nil
            if (mCore.currentCall == nil) {return}
            repeat {
                sleep(UInt32(0.1))
                deviceId = mCore.currentCall?.outputAudioDevice?.type.rawValue
            } while deviceId == nil
            
            let payload = makeAudioDeviceEventPayload(event: "CURRENT_DEVICE_ID", data: String(deviceId!))
            print("getCurrentAudioDevice  \(payload)")
            self.audioDeviceSink?(payload)
        } catch {
            print("Error while get current audio device \(error)")
        }
    }
    
    func toggleSpeaker() -> Bool {
            let currentAudioDevice = mCore.currentCall?.outputAudioDevice
            let speakerEnabled = currentAudioDevice?.type == AudioDeviceType.Speaker
            
            for audioDevice in mCore.audioDevices {

                if (speakerEnabled && audioDevice.type == AudioDeviceType.Microphone) {
                    mCore.currentCall?.outputAudioDevice = audioDevice
                } else if (!speakerEnabled && audioDevice.type == AudioDeviceType.Speaker) {
                    mCore.currentCall?.outputAudioDevice = audioDevice
                }
            }
        getCurrentAudioDevice()
            return false
        }
    
    func getCallStatus(code: Int?) -> String {
        if (code == 0) {
            return "ANSWERED"
        } else if (code == 1) {
            return "DECLINED"
        } else if (code == 2) {
            return "NO ANSWER"
        } else if (code == 3) {
            return "DECLINED"
        } else if (code == 4) {
            return "NO ANSWER"
        } else if (code == 5) {
            return "ANSWERED"
        } else if (code == 6) {
            return "DECLINED"
        } else {
            return "ANSWERED"
        }
    }
}

func makeCallEventPayload(event: String, callerId: String?, callData: CallData?) -> String? {
    do {
        let eventPayload = CallEventPayload(event: event, callerId: callerId, callData: callData)
        let jsonEventPayload = try JSONEncoder().encode(eventPayload)
        let jsonEventPayloadString = String(data: jsonEventPayload, encoding: .utf8)!
        return jsonEventPayloadString
    } catch {
        print(error)
        return nil
    }
}

func makeSipConnectionEventPayload(event: String, message: String?) -> String? {
    do {
        let payload = SipConnectionState(event: event, message: message)
        let jsonEventPayload = try JSONEncoder().encode(payload)
        let jsonEventPayloadString = String(data: jsonEventPayload, encoding: .utf8)!
        return jsonEventPayloadString
    } catch {
        print("JSON errro \(error)")
        return nil
    }
}

func makeAudioDeviceEventPayload(event: String, data: String?) -> String? {
    do {
        let eventPayload = AudioDeviceEventPayload(event: event, data: data)
        let jsonEventPayload = try JSONEncoder().encode(eventPayload)
        let jsonEventPayloadString = String(data: jsonEventPayload, encoding: .utf8)!
        return jsonEventPayloadString
    } catch {
        print(error)
        return nil
    }
}

struct AudioDeviceEventPayload: Codable {
    
    let event: String
    let data: String?
    
    init(event: String, data: String?) {
        self.event = event
        self.data = data
    }
}

struct CallEventPayload: Codable {
    
    let event: String
    let callerId: String?
    let callData: CallData?
    
    init(event: String, callerId: String?, callData: CallData?) {
        self.event = event
        self.callerId = callerId
        self.callData = callData
    }
}

struct SipConnectionState: Codable {
    
    let event: String
    let message: String?
    
    init(event: String, message: String?) {
        self.event = event
        self.message = message
    }
}

struct CallData: Codable {
    let duration: String?
    let disposition: String?
    let dst: String?
    let src: String?
    let calldate: String?
    let uniqueid: String?
    
    init(duration: String?, disposition: String?, dst: String?, src: String?,
         calldate: String?, uniqueid: String?) {
        self.duration = duration
        self.disposition = disposition
        self.dst = dst
        self.src = src
        self.calldate = calldate
        self.uniqueid = uniqueid
    }
}
