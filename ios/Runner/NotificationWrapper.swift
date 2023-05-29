//
//  NotificationWrapper.swift
//  Runner
//
//  Created by john on 29.05.2023.
//

import Foundation
import linphonesw


let APP_GROUP_ID = "group.com.application.chat.notification"


class NotificationWrapper {
    init() {
        NSLog("[notificationServiceAppExtension] create core")
            let config = Config.newForSharedCore(appGroupId: APP_GROUP_ID, configFilename: "linphonerc", factoryConfigFilename: "")
            if (self.log == nil) {
                self.log = LoggingService.Instance /*enable liblinphone logs.*/
                self.logDelegate = try! LinphoneLoggingServiceManager(config: config!, log: self.log, domain: "notificationServiceAppExtension")
            }
        lc = try! Factory.Instance.createSharedCoreWithConfig(config: config!, systemContext: nil, appGroupId: APP_GROUP_ID, mainCore: false)
        self.log.message(message: "received push payload : payload")
    }
    
    var lc: Core?
    var logDelegate: LinphoneLoggingServiceManager!
    var log: LoggingService!
        
    func stopCore() {
        self.log.message(message: "stop core")
        if let lc = lc {
            lc.stop()
        }
    }
    
}
