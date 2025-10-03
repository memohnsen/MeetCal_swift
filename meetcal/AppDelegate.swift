//
//  AppDelegate.swift
//  meetcal
//
//  Created by Maddisen Mohnsen on 9/1/25.
//

import UIKit
import RevenueCat
import FirebaseCore
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_UriFuFjiRHwcmgkTgoAgENezgcv")

        FirebaseApp.configure()

        // Set messaging delegate
        Messaging.messaging().delegate = self

        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self

        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }

        // Register for remote notifications
        application.registerForRemoteNotifications()

        return true
    }

    // Handle APNs token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if DEBUG
        print("APNs token retrieved: \(deviceToken)")
        #endif
        // Pass APNs token to Firebase
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }

    // MARK: - MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        #if DEBUG
        print("Firebase registration token: \(String(describing: fcmToken))")
        #endif
        // You can send this token to your server if needed
    }

    // MARK: - UNUserNotificationCenterDelegate
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }

    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Notification tapped with userInfo: \(userInfo)")
        completionHandler()
    }
}
