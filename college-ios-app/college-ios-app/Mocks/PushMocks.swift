//
//  PushMocks.swift
//  college-ios-app
//

#if DEBUG
import Foundation
import UserNotifications

nonisolated final class MockPushAPI: PushAPIProtocol {

    func registerDevice(token: String, deviceID: String) async throws {}

    func unregisterDevice(token: String) async throws {}
}

struct MockPushPermissions: PushPermissionsProtocol {

    let granted: Bool

    init(granted: Bool = true) {
        self.granted = granted
    }

    var status: UNAuthorizationStatus {
        get async { granted ? .authorized : .denied }
    }

    func request() async -> Bool { granted }

    func registerForRemoteNotifications() {}
}
#endif
