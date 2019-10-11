//
//  UIApplication+.swift
//  PilgrimStripped
//
//  Created by Zack Gilbert on 3/4/19.
//  Copyright © 2019 Zack Gilbert. All rights reserved.
//

import UIKit
import UserNotifications

extension UIApplication {
    
    func scheduleLocalNotification(title: String, body: String, timeInterval: TimeInterval = 5.0) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = body
        
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: notificationTrigger)
        
        UNUserNotificationCenter.current().add(notificationRequest) { _ in }
    }
    
}
