//
//  NotificationsDefaults.swift
//  college-ios-app
//

import Foundation

nonisolated enum NotificationsDefaultsKey {
    static let enabled = "notifications.enabled"
    static let deviceID = "notifications.deviceID"
    static let sentToken = "notifications.sentToken"
    static let sentUserID = "notifications.sentUserID"
}

nonisolated struct PushRegistration: Sendable, Equatable {
    let token: String
    let userID: String
}

struct PushRegistrationStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var deviceID: String {
        if let stored = defaults.string(forKey: NotificationsDefaultsKey.deviceID) {
            return stored
        }
        let created = UUID().uuidString
        defaults.set(created, forKey: NotificationsDefaultsKey.deviceID)
        return created
    }

    var isEnabled: Bool {
        get { defaults.object(forKey: NotificationsDefaultsKey.enabled) as? Bool ?? true }
        nonmutating set { defaults.set(newValue, forKey: NotificationsDefaultsKey.enabled) }
    }

    func load() -> PushRegistration? {
        guard let token = defaults.string(forKey: NotificationsDefaultsKey.sentToken),
              let userID = defaults.string(forKey: NotificationsDefaultsKey.sentUserID)
        else { return nil }
        return PushRegistration(token: token, userID: userID)
    }

    func save(_ registration: PushRegistration?) {
        guard let registration else {
            defaults.removeObject(forKey: NotificationsDefaultsKey.sentToken)
            defaults.removeObject(forKey: NotificationsDefaultsKey.sentUserID)
            return
        }
        defaults.set(registration.token, forKey: NotificationsDefaultsKey.sentToken)
        defaults.set(registration.userID, forKey: NotificationsDefaultsKey.sentUserID)
    }
}
