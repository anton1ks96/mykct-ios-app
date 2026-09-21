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
    static let sentGroup = "notifications.sentGroup"
    static let sentAt = "notifications.sentAt"
}

nonisolated struct PushRegistration: Sendable, Equatable {
    let token: String
    let userID: String
    let group: String
}

struct PushRegistrationStore {

    static let lifetime: TimeInterval = 7 * 24 * 60 * 60

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
              let userID = defaults.string(forKey: NotificationsDefaultsKey.sentUserID),
              let group = defaults.string(forKey: NotificationsDefaultsKey.sentGroup)
        else { return nil }
        return PushRegistration(token: token, userID: userID, group: group)
    }

    func isExpired(now: Date = .now) -> Bool {
        let sentAt = defaults.object(forKey: NotificationsDefaultsKey.sentAt) as? Date
        guard let sentAt else { return true }
        return now.timeIntervalSince(sentAt) > Self.lifetime
    }

    func save(_ registration: PushRegistration?, now: Date = .now) {
        guard let registration else {
            defaults.removeObject(forKey: NotificationsDefaultsKey.sentToken)
            defaults.removeObject(forKey: NotificationsDefaultsKey.sentUserID)
            defaults.removeObject(forKey: NotificationsDefaultsKey.sentGroup)
            defaults.removeObject(forKey: NotificationsDefaultsKey.sentAt)
            return
        }
        defaults.set(registration.token, forKey: NotificationsDefaultsKey.sentToken)
        defaults.set(registration.userID, forKey: NotificationsDefaultsKey.sentUserID)
        defaults.set(registration.group, forKey: NotificationsDefaultsKey.sentGroup)
        defaults.set(now, forKey: NotificationsDefaultsKey.sentAt)
    }
}
