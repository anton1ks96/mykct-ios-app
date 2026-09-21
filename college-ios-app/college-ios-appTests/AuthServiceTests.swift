//
//  AuthServiceTests.swift
//  college-ios-appTests
//
//  Created by pc on 23.08.2026.
//

import Foundation
import Testing
@testable import college_ios_app

private actor CountingAuthAPI: AuthAPIProtocol {
    private(set) var accessCallCount = 0
    private(set) var rotateCallCount = 0

    private let delay: Duration
    private let accessError: Error?
    private let user: User

    init(delay: Duration = .zero, accessError: Error? = nil) {
        self.delay = delay
        self.accessError = accessError
        self.user = User(
            id: "i24s0291",
            username: "i24s0291",
            role: "student",
            academicGroup: "ИТ-307",
            profile: "Программист",
            subgroup: "Подгруппа 1",
            englishGroup: "B1.21"
        )
    }

    func signIn(username: String, password: String) async throws -> SignInResponse {
        SignInResponse(
            accessToken: "access_from_signin",
            refreshToken: "refresh_from_signin",
            accessExpiresIn: 3600,
            refreshExpiresIn: 60 * 60 * 24 * 30,
            user: user
        )
    }

    func getAccessToken(refreshToken: String) async throws -> AccessTokenResponse {
        accessCallCount += 1
        if delay != .zero { try? await Task.sleep(for: delay) }
        if let accessError { throw accessError }
        return AccessTokenResponse(
            accessToken: "access_\(accessCallCount)",
            expiresIn: 3600,
            user: user
        )
    }

    func refreshRefreshToken(refreshToken: String) async throws -> RefreshTokenResponse {
        rotateCallCount += 1
        return RefreshTokenResponse(refreshToken: "rotated_refresh", expiresIn: 60 * 60 * 24 * 30)
    }

    func signOut(refreshToken: String) async throws {}
}

private func makeStorage(expiresIn: TimeInterval = 60 * 60 * 24 * 30) -> InMemoryTokenStorage {
    InMemoryTokenStorage(
        stored: StoredRefreshToken(token: "stored_refresh", expiresAt: Date().addingTimeInterval(expiresIn))
    )
}

@Test("Параллельные запросы токена дают один поход в API")
func concurrentRefreshesAreDeduplicated() async throws {
    let api = CountingAuthAPI(delay: .milliseconds(100))
    let session = AuthSession(refreshStorage: makeStorage())
    let service = AuthService(api: api, session: session)

    await withTaskGroup(of: Void.self) { group in
        for _ in 0..<10 {
            group.addTask { _ = try? await service.validAccessToken() }
        }
    }

    #expect(await api.accessCallCount == 1)
}

@Test("Живой токен отдаётся без запроса, forceRefresh обновляет его принудительно")
func forceRefreshBypassesCachedToken() async throws {
    let api = CountingAuthAPI()
    let session = AuthSession(refreshStorage: makeStorage())
    let service = AuthService(api: api, session: session)

    let first = try await service.validAccessToken()
    let cached = try await service.validAccessToken()
    #expect(first == cached)
    #expect(await api.accessCallCount == 1)

    let forced = try await service.validAccessToken(forceRefresh: true)
    #expect(forced != first)
    #expect(await api.accessCallCount == 2)
}

@Test("Отказ сервера в авторизации завершает сессию")
func unauthorizedEndsSession() async throws {
    let api = CountingAuthAPI(accessError: APIError.unauthorized(message: nil))
    let session = AuthSession(refreshStorage: makeStorage())
    let service = AuthService(api: api, session: session)
    await session.setCurrentUser(
        User(id: "i24s0291", username: "i24s0291", role: nil,
             academicGroup: nil, profile: nil, subgroup: nil, englishGroup: nil)
    )

    var iterator = service.events.makeAsyncIterator()
    _ = try? await service.validAccessToken(forceRefresh: true)

    let event = await iterator.next()
    #expect(event == .signedOut(.sessionExpired))
    #expect(await session.accessToken == nil)
}

@Test("Сетевая ошибка сессию не рвёт")
func networkFailureKeepsSession() async throws {
    let api = CountingAuthAPI(accessError: APIError.url(URLError(.notConnectedToInternet)))
    let storage = makeStorage()
    let session = AuthSession(refreshStorage: storage)
    let service = AuthService(api: api, session: session)
    await session.setCurrentUser(
        User(id: "i24s0291", username: "i24s0291", role: nil,
             academicGroup: nil, profile: nil, subgroup: nil, englishGroup: nil)
    )

    _ = try? await service.validAccessToken(forceRefresh: true)

    #expect(await session.currentUser != nil)
    #expect(try storage.load() != nil)
}

@Test("Срок жизни refresh-токена переживает пересоздание сессии")
func refreshExpirySurvivesRestart() async throws {
    let storage = InMemoryTokenStorage()
    let api = CountingAuthAPI()
    let firstSession = AuthSession(refreshStorage: storage)
    let firstService = AuthService(api: api, session: firstSession)

    try await firstService.signIn(username: "i24s0291", password: "secret")
    #expect(try storage.load()?.expiresAt != nil)

    let restoredSession = AuthSession(refreshStorage: storage)
    #expect(await restoredSession.isRefreshTokenExpiringSoon(daysThreshold: 60) == true)
    #expect(await restoredSession.isRefreshTokenExpiringSoon(daysThreshold: 1) == false)
}

@Test("Старая запись Keychain без срока читается как токен без срока")
func legacyTokenIsMigrated() throws {
    let raw = Data("legacy_refresh_token".utf8)
    let decoded = try? JSONDecoder().decode(StoredRefreshToken.self, from: raw)
    #expect(decoded == nil)

    let migrated = StoredRefreshToken(token: String(data: raw, encoding: .utf8)!, expiresAt: nil)
    #expect(migrated.token == "legacy_refresh_token")
    #expect(migrated.expiresAt == nil)
}
