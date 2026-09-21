//
//  PushPermissions.swift
//  college-ios-app
//

import UIKit
import UserNotifications

protocol PushPermissionsProtocol {
    var status: UNAuthorizationStatus { get async }
    func request() async -> Bool
    func registerForRemoteNotifications()
}

struct PushPermissions: PushPermissionsProtocol {

    var status: UNAuthorizationStatus {
        get async {
            await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
        }
    }

    func request() async -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: options)
        } catch {
            CrashlyticsLogger.logError(error, context: "push_authorization_request")
            return false
        }
    }

    func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }
}
