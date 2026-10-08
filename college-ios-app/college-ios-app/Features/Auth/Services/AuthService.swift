//
//  AuthService.swift
//  college-ios-app
//
//  Created by pc on 18.10.2025.
//

import Foundation

public actor AuthService {
    private let api: AuthAPIProtocol
    private let session: AuthSession
    private var refreshTask: Task<String, Error>?
    private let eventContinuation: AsyncStream<AuthEvent>.Continuation

    public nonisolated let events: AsyncStream<AuthEvent>

    public init(api: AuthAPIProtocol, session: AuthSession) {
        self.api = api
        self.session = session
        let (stream, continuation) = AsyncStream<AuthEvent>.makeStream()
        self.events = stream
        self.eventContinuation = continuation
    }
    
    // MARK: - Public API
    
    public func signIn(username: String, password: String) async throws {
        let resp = try await api.signIn(username: username, password: password)
        try await session.setLoggedIn(signIn: resp)
        eventContinuation.yield(.signedIn)
    }
    
    public func bootstrapAutoLogin() async {
        do {
            _ = try await validAccessToken(forceRefresh: true)
        } catch {
            CrashlyticsLogger.logAuthError(
                error,
                operation: "bootstrap_auto_login"
            )
            CrashlyticsLogger.recordBreadcrumb("Auto-login failed on app start")
        }
    }
    
    public func signOut() async {
        do {
            let refresh = try await session.refreshToken()
            try await api.signOut(refreshToken: refresh)
        } catch {
            CrashlyticsLogger.logAuthError(
                error,
                operation: "signout_api"
            )
        }
        do {
            try await session.logoutLocal()
        } catch {
            CrashlyticsLogger.logAuthError(
                error,
                operation: "signout_local_cleanup"
            )
        }
        eventContinuation.yield(.signedOut(.userInitiated))
    }
    
    public func validAccessToken(forceRefresh: Bool = false) async throws -> String {
        if !forceRefresh,
           let token = await session.accessToken,
           await session.isAccessTokenExpiringSoon() == false {
            return token
        }

        if let refreshTask {
            return try await refreshTask.value
        }

        let task = Task<String, Error> { [api, session] in
            if await session.isRefreshTokenExpiringSoon() {
                do {
                    let refresh = try await session.refreshToken()
                    let rotated = try await api.refreshRefreshToken(refreshToken: refresh)
                    try await session.updateAfterRefreshRefresh(rotated)
                } catch {
                    CrashlyticsLogger.logAuthError(
                        error,
                        operation: "refresh_token_renewal"
                    )
                }
            }

            let refresh = try await session.refreshToken()
            let accessResp = try await api.getAccessToken(refreshToken: refresh)
            try await session.updateAfterAccessRefresh(accessResp)
            guard let token = await session.accessToken else { throw APIError.refreshFailed }
            return token
        }
        refreshTask = task
        defer { refreshTask = nil }

        do {
            return try await task.value
        } catch {
            if Self.isSessionExpired(error) {
                let hadSession = await session.currentUser != nil
                try? await session.logoutLocal()
                if hadSession {
                    eventContinuation.yield(.signedOut(.sessionExpired))
                }
            }
            throw error
        }
    }

    private static func isSessionExpired(_ error: Error) -> Bool {
        guard let apiError = error as? APIError else { return false }
        switch apiError {
        case .unauthorized, .forbidden, .missingRefreshToken, .refreshFailed:
            return true
        default:
            return false
        }
    }
}
