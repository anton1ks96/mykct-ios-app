//
//  PushServiceTests.swift
//  college-ios-appTests
//

import Foundation
import Testing
import UserNotifications
@testable import college_ios_app

private final class SpyPushAPI: PushAPIProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var state = State()

    private struct State {
        var registered: [String] = []
        var unregistered: [String] = []
        var failure: Error?
    }

    var registered: [String] { lock.withLock { state.registered } }
    var unregistered: [String] { lock.withLock { state.unregistered } }

    func fail(with error: Error?) {
        lock.withLock { state.failure = error }
    }

    func registerDevice(token: String, deviceID: String) async throws {
        try lock.withLock {
            if let failure = state.failure { throw failure }
            state.registered.append(token)
        }
    }

    func unregisterDevice(token: String) async throws {
        try lock.withLock {
            if let failure = state.failure { throw failure }
            state.unregistered.append(token)
        }
    }
}

private final class SpyPermissions: PushPermissionsProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var current: UNAuthorizationStatus
    private let onRequest: UNAuthorizationStatus
    private var registrations = 0

    init(status: UNAuthorizationStatus = .authorized, onRequest: UNAuthorizationStatus = .authorized) {
        self.current = status
        self.onRequest = onRequest
    }

    var registerCount: Int { lock.withLock { registrations } }

    func grantFromSettings() {
        lock.withLock { current = .authorized }
    }

    var status: UNAuthorizationStatus {
        get async { lock.withLock { current } }
    }

    func request() async -> Bool {
        lock.withLock {
            current = onRequest
            return current == .authorized
        }
    }

    func registerForRemoteNotifications() {
        lock.withLock { registrations += 1 }
    }
}

@MainActor
@Suite("Регистрация устройства для пушей")
struct PushServiceTests {

    private static let group = "ИТ25-11"

    private func makeStore() -> PushRegistrationStore {
        PushRegistrationStore(defaults: UserDefaults(suiteName: "push.tests.\(UUID().uuidString)")!)
    }

    private func makeService(
        api: SpyPushAPI,
        store: PushRegistrationStore,
        permissions: PushPermissionsProtocol = SpyPermissions()
    ) -> PushService {
        PushService(api: api, store: store, permissions: permissions)
    }

    private func signIn(
        _ service: PushService,
        userID: String,
        token: String?,
        group: String = PushServiceTests.group
    ) async {
        service.refreshAuthorization()
        service.sync(userID: userID, group: group, isBootstrapping: false)
        service.handle(token: token)
        await service.settle()
    }

    @Test("Вход отправляет токен один раз")
    func registersOnce() async {
        let api = SpyPushAPI()
        let service = makeService(api: api, store: makeStore())

        await signIn(service, userID: "i24s0291", token: "fcm-1")

        #expect(api.registered == ["fcm-1"])
        #expect(api.unregistered.isEmpty)
    }

    @Test("Повторный запуск с тем же слепком в сеть не ходит")
    func skipsKnownRegistration() async {
        let api = SpyPushAPI()
        let store = makeStore()

        await signIn(makeService(api: api, store: store), userID: "i24s0291", token: "fcm-1")
        await signIn(makeService(api: api, store: store), userID: "i24s0291", token: "fcm-1")

        #expect(api.registered == ["fcm-1"])
    }

    @Test("Смена FCM-токена регистрирует устройство заново")
    func reregistersOnNewToken() async {
        let api = SpyPushAPI()
        let service = makeService(api: api, store: makeStore())

        await signIn(service, userID: "i24s0291", token: "fcm-1")
        service.handle(token: "fcm-2")
        await service.settle()

        #expect(api.registered == ["fcm-1", "fcm-2"])
    }

    @Test("Смена пользователя регистрирует устройство заново")
    func reregistersOnNewUser() async {
        let api = SpyPushAPI()
        let service = makeService(api: api, store: makeStore())

        await signIn(service, userID: "i24s0291", token: "fcm-1")
        service.sync(userID: "i25s0100", group: Self.group, isBootstrapping: false)
        await service.settle()

        #expect(api.registered == ["fcm-1", "fcm-1"])
    }

    @Test("Смена учебной группы регистрирует устройство заново")
    func reregistersOnNewGroup() async {
        let api = SpyPushAPI()
        let service = makeService(api: api, store: makeStore())

        await signIn(service, userID: "i24s0291", token: "fcm-1", group: "ИТ24-11")
        service.sync(userID: "i24s0291", group: "ИТ25-11", isBootstrapping: false)
        await service.settle()

        #expect(api.registered == ["fcm-1", "fcm-1"])
    }

    @Test("Протухший слепок регистрируется заново")
    func reregistersExpired() async {
        let api = SpyPushAPI()
        let defaults = UserDefaults(suiteName: "push.tests.\(UUID().uuidString)")!
        let store = PushRegistrationStore(defaults: defaults)

        await signIn(makeService(api: api, store: store), userID: "i24s0291", token: "fcm-1")
        let long = PushRegistrationStore.lifetime + 60
        defaults.set(Date.now.addingTimeInterval(-long), forKey: NotificationsDefaultsKey.sentAt)

        await signIn(makeService(api: api, store: store), userID: "i24s0291", token: "fcm-1")

        #expect(api.registered == ["fcm-1", "fcm-1"])
    }

    @Test("Выход снимает устройство с рассылки")
    func unregistersOnSignOut() async {
        let api = SpyPushAPI()
        let service = makeService(api: api, store: makeStore())

        await signIn(service, userID: "i24s0291", token: "fcm-1")
        service.sync(userID: nil, group: nil, isBootstrapping: false)
        await service.settle()

        #expect(api.unregistered == ["fcm-1"])
    }

    @Test("Пустой FCM-токен снимает устройство с рассылки")
    func unregistersOnLostToken() async {
        let api = SpyPushAPI()
        let service = makeService(api: api, store: makeStore())

        await signIn(service, userID: "i24s0291", token: "fcm-1")
        service.handle(token: nil)
        await service.settle()

        #expect(api.unregistered == ["fcm-1"])
    }

    @Test("Загрузка сессии не снимает устройство")
    func keepsRegistrationWhileBootstrapping() async {
        let api = SpyPushAPI()
        let service = makeService(api: api, store: makeStore())

        await signIn(service, userID: "i24s0291", token: "fcm-1")
        service.sync(userID: nil, group: nil, isBootstrapping: true)
        await service.settle()

        #expect(api.unregistered.isEmpty)
    }

    @Test("Проверка разрешения до появления сессии устройство не снимает")
    func keepsRegistrationBeforeSessionIsKnown() async {
        let api = SpyPushAPI()
        let store = makeStore()

        await signIn(makeService(api: api, store: store), userID: "i24s0291", token: "fcm-1")

        let next = makeService(api: api, store: store)
        next.refreshAuthorization()
        next.handle(token: "fcm-1")
        await next.settle()

        #expect(api.unregistered.isEmpty)
        #expect(api.registered == ["fcm-1"])
    }

    @Test("Выключенный тумблер снимает устройство и не шлёт регистрацию")
    func disabledTogglerRemovesDevice() async {
        let api = SpyPushAPI()
        let service = makeService(api: api, store: makeStore())

        await signIn(service, userID: "i24s0291", token: "fcm-1")
        service.setEnabled(false)
        await service.settle()
        service.handle(token: "fcm-2")
        await service.settle()

        #expect(api.unregistered == ["fcm-1"])
        #expect(api.registered == ["fcm-1"])
    }

    @Test("Тумблер выключается сразу, не дожидаясь сети")
    func togglerReactsImmediately() async {
        let api = SpyPushAPI()
        let service = makeService(api: api, store: makeStore())

        await signIn(service, userID: "i24s0291", token: "fcm-1")
        service.setEnabled(false)

        #expect(service.isEnabled == false)
        await service.settle()
    }

    @Test("Повторное включение тумблера запрашивает APNs-токен")
    func reenablingRegistersForRemoteNotifications() async {
        let api = SpyPushAPI()
        let permissions = SpyPermissions()
        let service = makeService(api: api, store: makeStore(), permissions: permissions)

        await signIn(service, userID: "i24s0291", token: "fcm-1")
        service.setEnabled(false)
        await service.settle()

        let before = permissions.registerCount
        service.setEnabled(true)
        await service.settle()

        #expect(permissions.registerCount > before)
        #expect(api.registered == ["fcm-1", "fcm-1"])
    }

    @Test("Запрет в системе поднимает подсказку, но намерение сохраняется")
    func systemDenialKeepsIntent() async {
        let api = SpyPushAPI()
        let permissions = SpyPermissions(status: .denied, onRequest: .denied)
        let store = makeStore()
        let service = makeService(api: api, store: store, permissions: permissions)

        service.sync(userID: "i24s0291", group: Self.group, isBootstrapping: false)
        service.handle(token: "fcm-1")
        service.setEnabled(true)
        await service.settle()

        #expect(service.isSystemDenied)
        #expect(service.isEnabled == false)
        #expect(api.registered.isEmpty)

        permissions.grantFromSettings()
        service.refreshAuthorization()
        await service.settle()

        #expect(service.isEnabled)
        #expect(api.registered == ["fcm-1"])
    }

    @Test("Неудачная регистрация повторяется при следующем запуске")
    func retriesAfterFailure() async {
        let api = SpyPushAPI()
        api.fail(with: APIError.server(code: 500))
        let store = makeStore()

        await signIn(makeService(api: api, store: store), userID: "i24s0291", token: "fcm-1")
        #expect(store.load() == nil)

        api.fail(with: nil)
        await signIn(makeService(api: api, store: store), userID: "i24s0291", token: "fcm-1")

        #expect(api.registered == ["fcm-1"])
    }

    @Test("Отказ сервера на снятие не повторяется бесконечно")
    func dropsRegistrationOnClientError() async {
        let api = SpyPushAPI()
        let store = makeStore()
        let service = makeService(api: api, store: store)

        await signIn(service, userID: "i24s0291", token: "fcm-1")
        api.fail(with: APIError.notFound)
        service.sync(userID: nil, group: nil, isBootstrapping: false)
        await service.settle()

        #expect(store.load() == nil)
    }
}
