//
//  NotificationService.swift
//  NotificationService
//
//  Created by Vishal More on 06/07/23.
//

import UserNotifications
import CTNotificationService
import CleverTapSDK

class NotificationService: CTNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        let defaults = UserDefaults.init(suiteName: "group.nativeios")
            
                let identity = defaults?.value(forKey: "identity")
                let email = defaults?.value(forKey: "email")
               print("email2 \(String(describing: email))")
                
                    let profile: Dictionary<String, Any> =
                   [
                    "Identity": identity as Any,
                    "Email": email as Any,
                   ]

                if(identity != nil){
                    CleverTap.sharedInstance()?.onUserLogin(profile)
                }
        CleverTap.sharedInstance()?.recordNotificationViewedEvent(withData: request.content.userInfo)
        
        super.didReceive(request, withContentHandler: contentHandler)
    }

}
