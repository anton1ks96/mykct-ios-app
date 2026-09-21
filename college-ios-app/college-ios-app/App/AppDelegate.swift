//
//  AppDelegate.swift
//  college-ios-app
//
//  Created by pc on 17.11.2025.
//

import UIKit
import MetricKit
import UserNotifications
import Firebase
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, MXMetricManagerSubscriber {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
#if DEBUG
            let environment = "debug"
#else
            let environment = "production"
#endif

            CrashlyticsLogger.setAppState(
                appVersion: appVersion,
                buildNumber: buildNumber,
                environment: environment
            )
        }

        MXMetricManager.shared.add(self)
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        CrashlyticsLogger.logError(error, context: "apns_registration")
    }
}

// MARK: - MessagingDelegate

extension AppDelegate: @preconcurrency MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        AppDependencies.pushService.handle(token: fcmToken)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: @preconcurrency UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        AppDependencies.pushService.handle(tap: response.notification.request.content.userInfo)
    }
}
