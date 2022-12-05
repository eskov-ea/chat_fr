import UIKit
import Flutter
import UserNotifications
import PushKit


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
  private let deviceTokenMethodChannel = "com.application.chat/method"
  private let sipMethodChannel = "com.application.chat/sip"
  var callServiceEventChannelName = "event.channel/call_service"
  var deviceIdResultCallback: FlutterResult? = nil
  var sipResultCallback: FlutterResult? = nil
  private var eventSink: FlutterEventSink?
  let linphoneSDK = LinphoneSDK(sink: nil)
    
    
    override func application(
    _ application: UIApplication,
    willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
      
      UNUserNotificationCenter.current().requestAuthorization(options:[.alert, .sound, .badge]) { (granted: Bool, error: Error?) in
            if (error != nil) {
              print("Failed to request authorization")
              return
            }
            if granted {
                DispatchQueue.main.async {
                  UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
              print("The user refused the push notification")
            }
          }
      UNUserNotificationCenter.current().delegate = self

      DispatchQueue.main.async {
          self.voipRegistration()
      }
      
      return true
  }
    
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      
      
      let controller = window?.rootViewController as! FlutterViewController
      let deviceIdChannel = FlutterMethodChannel(name: deviceTokenMethodChannel, binaryMessenger: controller.binaryMessenger)
      let sipChannel = FlutterMethodChannel(name: sipMethodChannel, binaryMessenger: controller.binaryMessenger)
      
      let callServiceEventChannel = FlutterEventChannel(name: callServiceEventChannelName,
                                                  binaryMessenger: controller.binaryMessenger)
      callServiceEventChannel.setStreamHandler(self)
      deviceIdChannel.setMethodCallHandler({
          [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          self?.deviceIdResultCallback = result
          if call.method == "getDeviceToken" {
              self?.registerForPushNotifications(result: result)
          } else {
              result(FlutterMethodNotImplemented)
              return
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
//              print("loginData \(type(of: domain))")
              if (domain != nil && password != nil && username != nil) {
                  self!.linphoneSDK.login(domain: domain!, password: password!, username: username!)
              } else {
                  print("No data to login into SIP account")
              }
            case "OUTGOING_CALL":
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
              self?.linphoneSDK.muteMicrophone()
            case "TOGGLE_SPEAKER":
              self?.linphoneSDK.toggleSpeaker()
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

    override func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
      print("Failed to register: \(error)")
    }
    
    func registerForPushNotifications( result: @escaping FlutterResult) {
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
 
    override func application(_ application: UIApplication,
            didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
         
         // Perform background operation
         print("we received a push  \(userInfo)")
//        self.linphoneSDK.outgoingCall(number: "40")
//         if let value = userInfo["some-key"] as? String {
//            print(value) // output: "some-value"
//         }
         
         // Inform the system after the background operation is completed.
         completionHandler(.newData)
    }
    
    func voipRegistration() {
            
            // Create a push registry object
            let mainQueue = DispatchQueue.main
            let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
            voipRegistry.delegate = self
            voipRegistry.desiredPushTypes = [PKPushType.voIP]
        }
    
}


extension AppDelegate : PKPushRegistryDelegate {
    
    // Handle updated push credentials
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print(credentials.token)
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        print("pushRegistry -> deviceToken :\(deviceToken)")
    }
        
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("pushRegistry:didInvalidatePushTokenForType:")
    }
    
    // Handle incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
         print(payload.dictionaryPayload)
        
        if (linphoneSDK.mCore != nil) {
            
        } else {
            linphoneSDK.login(domain: "aster.mcfef.com", password: "ase4eekpgfewd43rh743674", username: "40")
        }

        
        
         return false
    }
}
