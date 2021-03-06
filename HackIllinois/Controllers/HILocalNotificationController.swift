//
//  HILocalNotificationController.swift
//  HackIllinois
//
//  Created by Rauhul Varma on 2/22/18.
//  Copyright © 2018 HackIllinois. All rights reserved.
//

import Foundation
import UserNotifications

class HILocalNotificationController: NSObject {
    static let shared = HILocalNotificationController()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization(authorized: @escaping (() -> Void)) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized: authorized()
            case .denied: break
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (granted, _) in
                    if granted { authorized() }
                }
            }
        }
    }

    func scheduleNotifications(for events: [Event]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        let favoritedEvents = events.filter { $0.favorite }

        for event in favoritedEvents {
            scheduleNotification(for: event)
        }
    }

    func scheduleNotification(for event: Event) {
        requestAuthorization {
            let scheduleDelay: TimeInterval = 10
            let secondsPerMinute: TimeInterval = 60
            let timeBeforeEventStartForNotification = scheduleDelay * secondsPerMinute

            let now = Date()
            guard event.start > now else { return }
            let timeIntervalUntilEventStart = event.start.timeIntervalSince(now)
            let triggerDelay = max(1, timeIntervalUntilEventStart - timeBeforeEventStartForNotification)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: triggerDelay, repeats: false)

            let content = UNMutableNotificationContent()
            let minutesUntilEvent = min(10, Int(timeIntervalUntilEventStart/secondsPerMinute))
            if minutesUntilEvent <= 1 {
                content.title = "\(event.name) starts now!"
            } else {
                content.title = "\(event.name) starts in \(minutesUntilEvent) minutes!"
            }
            content.body = event.info
            content.sound = UNNotificationSound.default()

            let request = UNNotificationRequest(identifier: "\(event.id)", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request)
        }
    }

    func unscheduleNotification(for event: Event) {
        requestAuthorization {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(event.id)"])
        }
    }
}

extension HILocalNotificationController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Play a sound.
        completionHandler([.sound, .alert])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
