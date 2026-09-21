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
    private(set) var registered: [String] = []
    private(set) var unregistered: [String] = []
    var failure: Error?

    func registerDevice(token: String, deviceID: String) async throws {
        if let failure { throw failure }
        lock.withLock { registered.append(token) }
    }

    func unregisterDevice(token: String) async throws {
        if let failure { throw failure }
        lock.withLock { unregistered.append(token) }
    }
}

private struct GrantedPermissions: PushPermissionsProtocol {
    var status: UNAuthorizationStatus { get async { .authorized } }
    func request() async -> Bool { true }
    func registerForRemoteNotifications() {}
}

@MainActor
@Suite("Регистрация устройства для пушей")
struct PushServiceTests {

    private func makeService(api: SpyPushAPI) -> (PushService, UserDefaults) {
        let defaults = UserDefaults(suiteName: "push.tests.\(UUID().uuidString)")!
        let service = PushService(
            api: api,
            store: PushRegistrationStore(defaults: defaults),
            permissions: GrantedPermissions()
        )
        return (service, defaults)
    }

    private func signIn(_ service: PushService, userID: String, token: String) async {
        service.refreshAuthorization()
        service.sync(userID: userID, isBootstrapping: false)
        service.handle(token: token)
        await service.settle()
    }

    @Test("Вход отправляет токен один раз")
    func registersOnce() async {
        let api = SpyPushAPI()
        let (service, _) = makeService(api: api)

        await signIn(service, userID: "i24s0291", token: "fcm-1")

        #expect(api.registered == ["fcm-1"])
        #expect(api.unregistered.isEmpty)
    }

    @Test("Повторный запуск с той же парой в сеть не ходит")
    func skipsKnownRegistration() async {
        let api = SpyPushAPI()
        let defaults = UserDefaults(suiteName: "push.tests.\(UUID().uuidString)")!
        let store = PushRegistrationStore(defaults: defaults)

        let first = PushService(api: api, store: store, permissions: GrantedPermissions())
        await signIn(first, userID: "i24s0291", token: "fcm-1")

        let second = PushService(api: api, store: store, permissions: GrantedPermissions())
        await signIn(second, userID: "i24s0291", token: "fcm-1")

        #expect(api.registered == ["fcm-1"])
    }

    @Test("Смена FCM-токена регистрирует устройство заново")
    func reregistersOnNewToken() async {
        let api = SpyPushAPI()
        let (service, _) = makeService(api: api)

        await signIn(service, userID: "i24s0291", token: "fcm-1")
        service.handle(token: "fcm-2")
        await service.settle()

        #expect(api.registered == ["fcm-1", "fcm-2"])
    }

    @Test("Смена пользователя регистрирует устройство заново")
    func reregistersOnNewUser() async {
        let api = SpyPushAPI()
        let (service, _) = makeService(api: api)

        await signIn(service, userID: "i24s0291", token: "fcm-1")
        service.sync(userID: "i25s0100", isBootstrapping: false)
        await service.settle()

        #expect(api.registered == ["fcm-1", "fcm-1"])
    }

    @Test("Выход снимает устройство с рассылки")
    func unregistersOnSignOut() async {
        let api = SpyPushAPI()
        let (service, _) = makeService(api: api)

        await signIn(service, userID: "i24s0291", token: "fcm-1")
        service.sync(userID: nil, isBootstrapping: false)
        await service.settle()

        #expect(api.unregistered == ["fcm-1"])
    }

    @Test("Загрузка сессии не снимает устройство")
    func keepsRegistrationWhileBootstrapping() async {
        let api = SpyPushAPI()
        let (service, _) = makeService(api: api)

        await signIn(service, userID: "i24s0291", token: "fcm-1")
        service.sync(userID: nil, isBootstrapping: true)
        await service.settle()

        #expect(api.unregistered.isEmpty)
    }

    @Test("Проверка разрешения до появления сессии устройство не снимает")
    func keepsRegistrationBeforeSessionIsKnown() async {
        let api = SpyPushAPI()
        let defaults = UserDefaults(suiteName: "push.tests.\(UUID().uuidString)")!
        let store = PushRegistrationStore(defaults: defaults)

        let first = PushService(api: api, store: store, permissions: GrantedPermissions())
        await signIn(first, userID: "i24s0291", token: "fcm-1")

        let second = PushService(api: api, store: store, permissions: GrantedPermissions())
        second.refreshAuthorization()
        second.handle(token: "fcm-1")
        await second.settle()

        #expect(api.unregistered.isEmpty)
        #expect(api.registered == ["fcm-1"])
    }

    @Test("Выключенный тумблер снимает устройство и не шлёт регистрацию")
    func disabledTogglerRemovesDevice() async {
        let api = SpyPushAPI()
        let (service, _) = makeService(api: api)

        await signIn(service, userID: "i24s0291", token: "fcm-1")
        service.setEnabled(false)
        await service.settle()
        service.handle(token: "fcm-2")
        await service.settle()

        #expect(api.unregistered == ["fcm-1"])
        #expect(api.registered == ["fcm-1"])
    }

    @Test("Неудачная регистрация повторяется при следующем запуске")
    func retriesAfterFailure() async {
        let api = SpyPushAPI()
        api.failure = APIError.server(code: 500)
        let defaults = UserDefaults(suiteName: "push.tests.\(UUID().uuidString)")!
        let store = PushRegistrationStore(defaults: defaults)

        let first = PushService(api: api, store: store, permissions: GrantedPermissions())
        await signIn(first, userID: "i24s0291", token: "fcm-1")
        #expect(store.load() == nil)

        api.failure = nil
        let second = PushService(api: api, store: store, permissions: GrantedPermissions())
        await signIn(second, userID: "i24s0291", token: "fcm-1")

        #expect(api.registered == ["fcm-1"])
    }
}
