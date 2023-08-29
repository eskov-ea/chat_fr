import UIKit
import Flutter
import UserNotifications
import PushKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
    private let deviceTokenMethodChannel = "com.application.chat/method"
    private let sipMethodChannel = "com.application.chat/sip"
    private let writeFilesMethodChannel = "com.application.chat/write_files_method"
    var callServiceEventChannelName = "event.channel/call_service"
    var deviceIdResultCallback: FlutterResult? = nil
    var sipResultCallback: FlutterResult? = nil
    private var eventSink: FlutterEventSink?
    let linphoneSDK = LinphoneSDK(sink: nil)
    
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        self.registerForPushNotifications()
        
        
        let controller = window?.rootViewController as! FlutterViewController
        let deviceIdChannel = FlutterMethodChannel(name: deviceTokenMethodChannel, binaryMessenger: controller.binaryMessenger)
        let sipChannel = FlutterMethodChannel(name: sipMethodChannel, binaryMessenger: controller.binaryMessenger)
        let writeFilesChannel = FlutterMethodChannel(name: writeFilesMethodChannel, binaryMessenger: controller.binaryMessenger)
        
        let callServiceEventChannel = FlutterEventChannel(name: callServiceEventChannelName,
                                                          binaryMessenger: controller.binaryMessenger)
        callServiceEventChannel.setStreamHandler(self)
        deviceIdChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            self?.deviceIdResultCallback = result
            if call.method == "getDeviceToken" {
                print("getDeviceToken")
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
                let type = args!["type"] as? String
                let data = args!["data"] as? Dictionary<String, String>
                if (data != nil) {
                    let sm = StorageManager()
                    sm.saveDataToDocuments(data!, jsonFilename: sm.filename)
                } else {
                    print("Data error:  \(args)  \(type)")
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
                self?.linphoneSDK.declineCall()
            case "TOGGLE_MUTE":
                self?.sipResultCallback?(self?.linphoneSDK.muteMicrophone())
            case "TOGGLE_SPEAKER":
                self?.sipResultCallback?(self?.linphoneSDK.toggleSpeaker())
            case "CHECK_FOR_RUNNING_CALL":
                let result = self?.linphoneSDK.checkForRunningCall()
                self?.sipResultCallback?(result)
            default:
                result(FlutterMethodNotImplemented)
                return
            }
        })
        
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    public func onListen(withArguments arguments: Any?,
                         eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        self.linphoneSDK.eventSink = eventSink
        return nil
    }
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        self.linphoneSDK.eventSink = eventSink
        return nil
    }
    
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
}

extension Data {
    init?(base64EncodedURLSafe string: String, options: Base64DecodingOptions = []) {
        let string = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        self.init(base64Encoded: string, options: options)
    }
}
