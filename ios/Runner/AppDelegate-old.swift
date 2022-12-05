import UIKit
import Flutter
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    ///
    // https://www.youtube.com/watch?v=CUM5OIw9zDI

    let METHOD_CHANNEL_NAME = 'com.application.chat/method'
    let TOKEN_CHANNEL_NAME = 'com.application.getToken'

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController

    let methodChannel = FlutterMethodChannel(name: METHOD_CHANNEL_NAME, binaryMessenger: controller.binaryMessenger)

    methodChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        call.method {
            result(registerForPushNotifications())
        }
    })

    ///
    GeneratedPluginRegistrant.register(with: self)
//     registerForPushNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func registerForPushNotifications() {
    UNUserNotificationCenter.current()
      .requestAuthorization(
        options: [.alert, .sound, .badge]) { [weak self] granted, _ in
        print("Permission granted: \(granted)")
        guard granted else { return }
        self?.getNotificationSettings()
      )
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

  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("Device Token: \(token)")
  }
}


