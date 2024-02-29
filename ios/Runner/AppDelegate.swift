import UIKit
import Flutter
import UserNotifications
import PushKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private let deviceTokenMethodChannel = "com.application.chat/method"
    private let sipMethodChannel = "com.application.chat/sip"
    private let audioDeviceMethodChannelName = "com.application.chat/audio_devices"
    private let writeFilesMethodChannel = "com.application.chat/permission_method_channel"
    var callServiceEventChannelName = "event.channel/call_service"
    let audioDeviceEventChannelName = "event.channel/audio_device_channel"
    var deviceIdResultCallback: FlutterResult? = nil
    var sipResultCallback: FlutterResult? = nil
    var audioDeviceResultCallback: FlutterResult? = nil
    private var eventSink: FlutterEventSink?
    private var audioDeviceSink: FlutterEventSink?
    let linphoneSDK = LinphoneSDK(sink: nil, audioSink: nil)
    
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        self.registerForPushNotifications()
        
        
        let controller = window?.rootViewController as! FlutterViewController
        let deviceIdChannel = FlutterMethodChannel(name: deviceTokenMethodChannel, binaryMessenger: controller.binaryMessenger)
        let sipChannel = FlutterMethodChannel(name: sipMethodChannel, binaryMessenger: controller.binaryMessenger)
        let audioDeviceMethodChannel = FlutterMethodChannel(name: audioDeviceMethodChannelName, binaryMessenger: controller.binaryMessenger)
        let writeFilesChannel = FlutterMethodChannel(name: writeFilesMethodChannel, binaryMessenger: controller.binaryMessenger)
        
        let callServiceEventChannel = FlutterEventChannel(name: callServiceEventChannelName,
                                                          binaryMessenger: controller.binaryMessenger)
        let audioDeviceEventChannel = FlutterEventChannel(name: audioDeviceEventChannelName,
                                                          binaryMessenger: controller.binaryMessenger)
        
        callServiceEventChannel.setStreamHandler(SwiftStreamHandlerSip(linphoneSDK: self.linphoneSDK))
        audioDeviceEventChannel.setStreamHandler(SwiftStreamHandlerAudioDevice(linphoneSDK: self.linphoneSDK))
        
        deviceIdChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self?.deviceIdResultCallback = result
            if call.method == "getDeviceToken" {
                self?.registerForPushNotifications()
            } else {
                result(FlutterMethodNotImplemented)
                return
            }
        })
        
        writeFilesChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "SAVE_FILE" {
                print("SAVE_FILE")
                let args = call.arguments as? Dictionary<String, Any>
                let type = args!["type"] as? String
                let filename = args!["filename"] as? String
                let base64String = args!["data"] as? String
                
                guard let data = Data(base64EncodedURLSafe: base64String!) else {
                    print("decoding error")
                    return
                }
                let temporaryFolder = FileManager.default.temporaryDirectory
                let fileName = filename
                let temporaryFileURL = temporaryFolder.appendingPathComponent(fileName!)
                print(temporaryFileURL.path)
                
                do {
                    try data.write(to: temporaryFileURL)
                    let activityViewController = UIActivityViewController(activityItems: [temporaryFileURL], applicationActivities: nil)
                    controller.present(activityViewController, animated: true, completion: nil)
                } catch {
                    print(error)
                }
            }
            if call.method == "SAVE_SIP_CONTACTS" {
                let args = call.arguments as? Dictionary<String, Any>
//                let type = args!["type"] as? String
//                let text = args!["data"] as? String
//                let d = text?.data(using: .utf8)
//                let data = try JSONSerialization.jsonObject(with: d!, options: .mutableContainers) as? Dictionary<String, Any>
                let data = args?["data"] as? String
//                let d = data as? Dictionary<String, Any>
                if (data != nil) {
                    let sm = StorageManager()
                    sm.saveDataToDocuments(data)
                } else {
                    print("Data error:  \(data)")
                }
            }
        })
        
        sipChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self?.sipResultCallback = result
            switch call.method{
            case "SIP_LOGIN":
                let args = call.arguments as? Dictionary<String, Any>
                let domain = args!["domain"] as? String
                let password = args!["password"] as? String
                let username = args!["username"] as? String
                let stunDomain = args!["stun_domain"] as? String
                let stunPort = args!["stun_port"] as? String
                let host = args!["host"] as? String
                let cert = args!["cert"] as? String
                print("loginData \(domain) \(username) \(password)")
                if (domain != nil && password != nil && username != nil
                    && stunDomain != nil && stunPort != nil && host != nil && cert != nil) {
                    self!.linphoneSDK.login(domain: domain!, password: password!, username: username!, stunDomain: stunDomain!, stunPort: stunPort!, host: host!, cert: cert!)
                } else {
                    print("No data to login into SIP account")
                }
            case "SIP_LOGOUT":
                self?.linphoneSDK.logout()
            case "OUTGOING_CALL":
                print("OUTGOING_CALL FLUTTER")
                let args = call.arguments as? Dictionary<String, Any>
                let number = args!["number"] as? String
                //              print("loginData \(type(of: domain))")
                if (number != nil) {
                    self!.linphoneSDK.outgoingCall(number: number!)
                } else {
                    print("No data to login into SIP account")
                }
            case "DESTROY_SIP":
                self?.linphoneSDK.mCore?.stop()
            case "DECLINE_CALL":
                print("DECLINE_CALL")
                print("Service State: decline request")
                self?.linphoneSDK.terminateCall()
            case "TOGGLE_MUTE":
                self?.sipResultCallback?(self?.linphoneSDK.muteMicrophone())
            case "CHECK_FOR_RUNNING_CALL":
                let result = self?.linphoneSDK.checkForRunningCall()
                self?.sipResultCallback?(result)
            default:
                result(FlutterMethodNotImplemented)
                return
            }
        })
        
        audioDeviceMethodChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self?.audioDeviceResultCallback = result
            print("audioDeviceMethodChannel \(call.method)");
            switch call.method{
            case "GET_DEVICE_LIST":
                self?.linphoneSDK.getAudioDeviceList()
            case "TOGGLE_MUTE":
                self?.audioDeviceResultCallback?(self?.linphoneSDK.muteMicrophone())
            case "TOGGLE_SPEAKER":
                self?.audioDeviceResultCallback?(self?.linphoneSDK.toggleSpeaker())
            case "GET_CURRENT_AUDIO_DEVICE":
                self?.linphoneSDK.getCurrentAudioDevice()
                print("")
            case "SET_AUDIO_DEVICE":
                let args = call.arguments as? Dictionary<String, Any>
                let deviceId = args!["device_id"] as? Int
                print("Set devicce \(deviceId)")
                if (deviceId != nil) {
                    self?.linphoneSDK.setAudioDevice(id: deviceId!)
                }
            default:
                result(FlutterMethodNotImplemented)
                return
            }
        })
        
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
//    public func onListen(withArguments arguments: Any?,
//                         eventSink: @escaping FlutterEventSink) -> FlutterError? {
//        self.eventSink = eventSink
//        self.linphoneSDK.eventSink = eventSink
//        return nil
//    }
//    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
//        eventSink = nil
//        self.linphoneSDK.eventSink = eventSink
//        return nil
//    }
    
    func registerForPushNotifications( ) {
        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                    print("Permission granted: \(granted)")
                    guard granted else { return }
                    self?.getNotificationSettings()
                }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    
    override func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
        //      result: @escaping FlutterResult
    )  {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        self.deviceIdResultCallback?(String(token))
        print("Device Token: \(token)")
    }
    
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]
         , fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
                print("We got push message")
    }

    
    override func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register: \(error)")
    }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        print("App become active")
        application.applicationIconBadgeNumber = 0
    }
}

class SwiftStreamHandlerSip: NSObject, FlutterStreamHandler {
    
    var linphoneSDK: LinphoneSDK
    
    init(linphoneSDK: LinphoneSDK) {
        self.linphoneSDK = linphoneSDK
    }
    
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
            self.linphoneSDK.eventSink = eventSink
            return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.linphoneSDK.eventSink = nil
        return nil
    }
}

class SwiftStreamHandlerAudioDevice: NSObject, FlutterStreamHandler {
    
    var linphoneSDK: LinphoneSDK
    
    init(linphoneSDK: LinphoneSDK) {
        self.linphoneSDK = linphoneSDK
    }
    
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.linphoneSDK.audioDeviceSink = eventSink
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.linphoneSDK.audioDeviceSink = nil
        return nil
    }
}

extension Data {
    init?(base64EncodedURLSafe string: String, options: Base64DecodingOptions = []) {
        let string = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        self.init(base64Encoded: string, options: options)
    }
}
