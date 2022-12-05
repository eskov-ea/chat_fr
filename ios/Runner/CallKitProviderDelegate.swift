//
//  CallKitProviderDelegate.swift
//  Runner
//
//  Created by john on 17.07.2022.
//

import Foundation
import CallKit
import linphonesw
import AVFoundation


class CallKitProviderDelegate : NSObject
{
    private let provider: CXProvider
    let mCallController = CXCallController()
    var callkitContext : LinphoneSDK!
    
    var incomingCallUUID : UUID!
    var outgoingCallUUID : UUID!
    
    init(context: LinphoneSDK)
    {
        callkitContext = context
        let providerConfiguration = CXProviderConfiguration(localizedName: Bundle.main.infoDictionary!["CFBundleName"] as! String)
        providerConfiguration.supportsVideo = false
        providerConfiguration.supportedHandleTypes = [.generic]
        
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.maximumCallGroups = 1
        
        provider = CXProvider(configuration: providerConfiguration)
        super.init()
        provider.setDelegate(self, queue: nil) // The CXProvider delegate will trigger CallKit related callbacks
        
    }
    
    func incomingCall()
    {
        incomingCallUUID = UUID()
        print("INCOMING UUID  ->  \(String(describing: incomingCallUUID))")
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type:.generic, value: callkitContext.incomingCallName)
        
        provider.reportNewIncomingCall(with: incomingCallUUID, update: update, completion: { error in }) // Report to CallKit a call is incoming
    }
    
    func outgoingCall()
    {
        if (callkitContext.isOutgoingCallInited == true) {return}
        callkitContext.isOutgoingCallInited = true
        self.outgoingCallUUID = UUID()
        print("OUTGOING UUID  ->  \(String(describing: outgoingCallUUID))")
//        let update = CXCallUpdate()
//        update.remoteHandle = CXHandle(type:.generic, value: callkitContext.incomingCallName)
        let handle = CXHandle(type: .generic, value: callkitContext.incomingCallName)
        let startCallAction = CXStartCallAction(call: outgoingCallUUID, handle: handle)
        let transaction = CXTransaction(action: startCallAction)

        provider.reportOutgoingCall(with: outgoingCallUUID, startedConnectingAt: Date.init())
        mCallController.request(transaction, completion: { error in })
        print("OUTGING reported    \(callkitContext.incomingCallName)")
        // Report to CallKit a call is outgoing
    }
    
    func stopCall()
    {
        var callId = UUID()
        if (callkitContext.isCallIncoming) {
            callId = incomingCallUUID
        } else {
            callId = outgoingCallUUID
        }
        print("STOP CALL UUID   \(callId)")
        let endCallAction = CXEndCallAction(call: callId)
        let transaction = CXTransaction(action: endCallAction)
        callkitContext.isOutgoingCallInited = false
        
        mCallController.request(transaction, completion: { error in }) // Report to CallKit a call must end
    }
    
}


// In this extension, we implement the action we want to be done when CallKit is notified of something.
// This can happen through the CallKit GUI in the app, or directly in the code (see, incomingCall(), stopCall() functions above)
extension CallKitProviderDelegate: CXProviderDelegate {
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        do {
            if (callkitContext.mCall?.state != .End && callkitContext.mCall?.state != .Released)  {
                try? callkitContext.mCall?.terminate()
            }
        } catch { NSLog(error.localizedDescription) }
        
        callkitContext.isCallRunning = false
        callkitContext.isCallIncoming = false
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        do {
            try callkitContext.mCall?.accept()
            callkitContext.isCallRunning = true
        } catch {
            print(error)
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {}
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        do {
            let remoteAddress = try Factory.Instance.createAddress(addr: callkitContext.outgoingNumber)
            callkitContext.mCall = callkitContext.mCore.inviteAddressWithParams(addr: remoteAddress, params: try callkitContext.mCore.createCallParams(call: nil))
        } catch {
            print("OUTGOUNG ERROR   \(error)")
        }
        action.fulfill()
    }
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {}
    func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {}
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {}
    func providerDidReset(_ provider: CXProvider) {}
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        callkitContext.mCore.activateAudioSession(actived: true)
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        callkitContext.mCore.activateAudioSession(actived: false)
    }
}

