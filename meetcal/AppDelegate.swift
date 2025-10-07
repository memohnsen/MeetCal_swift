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
import PostHog

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
        Purchases.logLevel = .debug
        #endif
        let revenueCatKey = Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_API_KEY") as! String
        Purchases.configure(withAPIKey: revenueCatKey)
        
        let POSTHOG_API_KEY = Bundle.main.object(forInfoDictionaryKey: "POSTHOG_API_KEY") as! String
        let POSTHOG_HOST = Bundle.main.object(forInfoDictionaryKey: "POSTHOG_HOST") as! String
        let config = PostHogConfig(apiKey: POSTHOG_API_KEY, host: POSTHOG_HOST)
        PostHogSDK.shared.setup(config)

        FirebaseApp.configure()

        // Set messaging delegate
        Messaging.messaging().delegate = self

        // Set notification delegate
        UNUserNotificationCenter.current().delegate = self

        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                #if DEBUG
                print("Notification permission granted")
                #endif
                AnalyticsManager.shared.trackNotificationPermissionGranted()
                AnalyticsManager.shared.setNotificationEnabled(true)
            } else if let error = error {
                #if DEBUG
                print("Error requesting notification permission: \(error)")
                #endif
                AnalyticsManager.shared.trackNotificationPermissionDenied()
                AnalyticsManager.shared.setNotificationEnabled(false)
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
        #if DEBUG
        print("Failed to register for remote notifications: \(error)")
        #endif
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
        #if DEBUG
        print("Notification tapped with userInfo: \(userInfo)")
        #endif

        // Track notification opened
        let notificationType = userInfo["type"] as? String ?? "unknown"
        AnalyticsManager.shared.trackNotificationOpened(type: notificationType)

        completionHandler()
    }
}
