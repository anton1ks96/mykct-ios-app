//
//  PushService.swift
//  college-ios-app
//

import Foundation
import Observation
import UserNotifications

@Observable
final class PushService {

    private(set) var pendingRoute: PushRoute?
    private(set) var isSystemDenied = false

    var isEnabled: Bool { wantsNotifications && Self.isGranted(status) }

    private let api: PushAPIProtocol
    private let store: PushRegistrationStore
    private let permissions: PushPermissionsProtocol

    private var wantsNotifications: Bool
    private var status: UNAuthorizationStatus = .notDetermined
    private var token: String?
    private var userID: String?
    private var group: String?
    private var isSessionKnown = false
    private var queue: Task<Void, Never>?

    init(
        api: PushAPIProtocol = AppDependencies.pushAPI,
        store: PushRegistrationStore = PushRegistrationStore(),
        permissions: PushPermissionsProtocol = PushPermissions()
    ) {
        self.api = api
        self.store = store
        self.permissions = permissions
        self.wantsNotifications = store.isEnabled
    }

    // MARK: - Intents

    func sync(userID: String?, group: String?, isBootstrapping: Bool) {
        guard !isBootstrapping else { return }
        self.userID = userID
        self.group = group
        isSessionKnown = true

        enqueue { [weak self] in
            guard let self else { return }
            if userID != nil, self.status == .notDetermined, self.wantsNotifications {
                await self.ask()
            }
            await self.apply()
        }
    }

    func setEnabled(_ isEnabled: Bool) {
        wantsNotifications = isEnabled
        store.isEnabled = isEnabled

        enqueue { [weak self] in
            guard let self else { return }
            if isEnabled {
                await self.ask()
                self.isSystemDenied = !Self.isGranted(self.status)
            }
            await self.apply()
        }
    }

    func refreshAuthorization() {
        enqueue { [weak self] in
            guard let self else { return }
            self.status = await self.permissions.status
            self.registerForRemoteNotificationsIfNeeded()
            await self.apply()
        }
    }

    func dismissSystemDenied() {
        isSystemDenied = false
    }

    func handle(token: String?) {
        guard token != self.token else { return }
        self.token = token
        enqueue { [weak self] in await self?.apply() }
    }

    func handle(tap userInfo: [AnyHashable: Any]) {
        guard let route = PushPayload.route(from: userInfo) else { return }
        pendingRoute = route
    }

    func consumeRoute() {
        pendingRoute = nil
    }

    func settle() async {
        await queue?.value
    }

    // MARK: - Authorization

    private func ask() async {
        status = await permissions.status
        if status == .notDetermined {
            _ = await permissions.request()
            status = await permissions.status
        }
        registerForRemoteNotificationsIfNeeded()
    }

    private func registerForRemoteNotificationsIfNeeded() {
        guard isEnabled else { return }
        permissions.registerForRemoteNotifications()
    }

    private static func isGranted(_ status: UNAuthorizationStatus) -> Bool {
        switch status {
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            return false
        }
    }

    // MARK: - Registration

    private func enqueue(_ work: @escaping @MainActor () async -> Void) {
        let previous = queue
        queue = Task {
            await previous?.value
            await work()
        }
    }

    private func apply() async {
        guard isSessionKnown else { return }

        guard isEnabled, let userID, let group, let token else {
            await unregister()
            return
        }

        let wanted = PushRegistration(token: token, userID: userID, group: group)
        guard store.load() != wanted || store.isExpired() else { return }

        do {
            try await api.registerDevice(token: token, deviceID: store.deviceID)
            store.save(wanted)
        } catch {
            CrashlyticsLogger.recordBreadcrumb("Push registration will be retried")
        }
    }

    private func unregister() async {
        guard let sent = store.load() else { return }
        do {
            try await api.unregisterDevice(token: sent.token)
            store.save(nil)
        } catch {
            guard Self.isRetryable(error) else {
                store.save(nil)
                return
            }
            CrashlyticsLogger.recordBreadcrumb("Push removal will be retried")
        }
    }

    private static func isRetryable(_ error: Error) -> Bool {
        guard let apiError = error as? APIError else { return true }
        switch apiError {
        case .unauthorized, .forbidden, .notFound, .decodingFailed:
            return false
        case .statusCode(let code, _):
            return !(400..<500).contains(code)
        case .api(_, _, let status):
            return !(400..<500).contains(status)
        default:
            return true
        }
    }
}
