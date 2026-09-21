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
    private(set) var isEnabled = false
    private(set) var isSystemDenied = false

    private let api: PushAPIProtocol
    private let store: PushRegistrationStore
    private let permissions: PushPermissionsProtocol

    private var token: String?
    private var userID: String?
    private var status: UNAuthorizationStatus = .notDetermined
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
    }

    // MARK: - Intents

    func sync(userID: String?, isBootstrapping: Bool) {
        guard !isBootstrapping else { return }
        self.userID = userID
        isSessionKnown = true

        enqueue { [weak self] in
            guard let self else { return }
            if userID != nil, self.status == .notDetermined, self.store.isEnabled {
                await self.ask()
            }
            await self.apply()
        }
    }

    func setEnabled(_ isEnabled: Bool) {
        enqueue { [weak self] in
            guard let self else { return }
            guard isEnabled else {
                self.store.isEnabled = false
                self.isEnabled = false
                await self.apply()
                return
            }

            await self.ask()
            guard Self.isGranted(self.status) else {
                self.isSystemDenied = true
                return
            }
            self.store.isEnabled = true
            self.isEnabled = true
            await self.apply()
        }
    }

    func refreshAuthorization() {
        enqueue { [weak self] in
            guard let self else { return }
            self.status = await self.permissions.status
            self.updateEnabled()
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
        updateEnabled()
    }

    private func updateEnabled() {
        isEnabled = store.isEnabled && Self.isGranted(status)
        if isEnabled {
            permissions.registerForRemoteNotifications()
        }
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

        if let userID, isEnabled {
            guard let token else { return }
            let wanted = PushRegistration(token: token, userID: userID)
            guard store.load() != wanted else { return }
            do {
                try await api.registerDevice(token: token, deviceID: store.deviceID)
                store.save(wanted)
            } catch {
                CrashlyticsLogger.recordBreadcrumb("Push registration will be retried")
            }
            return
        }

        guard let sent = store.load() else { return }
        do {
            try await api.unregisterDevice(token: sent.token)
            store.save(nil)
        } catch {
            CrashlyticsLogger.recordBreadcrumb("Push removal will be retried")
        }
    }
}
