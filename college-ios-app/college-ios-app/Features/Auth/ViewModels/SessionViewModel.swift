//
//  SessionViewModel.swift
//  college-ios-app
//
//  Created by pc on 17.10.2025.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
final class SessionViewModel: ObservableObject {
    
    @Published private(set) var user: User?
    @Published private(set) var isAuthenticated: Bool = false
    @Published var isBootstrapping: Bool = true
    @Published var didSessionExpire: Bool = false
    @Published private(set) var hasStoredSession: Bool = false

    let authService: AuthService
    private let authSession: AuthSession
    private let refreshStorage: RefreshTokenStorage
    private var eventsTask: Task<Void, Never>?
    private var bootstrapTask: Task<Void, Never>?

    init(
        authService: AuthService,
        authSession: AuthSession,
        refreshStorage: RefreshTokenStorage = AppDependencies.refreshStorage
    ) {
        self.authService = authService
        self.authSession = authSession
        self.refreshStorage = refreshStorage
        hasStoredSession = Self.storedSessionExists(in: refreshStorage)
        observeAuthEvents()
    }

    deinit {
        eventsTask?.cancel()
    }

    private func observeAuthEvents() {
        eventsTask = Task { [weak self, events = authService.events] in
            for await event in events {
                guard let self else { return }
                await self.syncFromSession()
                if case .signedOut(.sessionExpired) = event {
                    self.didSessionExpire = true
                }
            }
        }
    }
    
    func bootstrapAutoLogin() {
        guard bootstrapTask == nil else { return }
        isBootstrapping = true
        bootstrapTask = Task {
            await authService.bootstrapAutoLogin()
            await syncFromSession()
            isBootstrapping = false
            bootstrapTask = nil
        }
    }

    func reconnectIfNeeded() {
        guard hasStoredSession, !isAuthenticated else { return }
        bootstrapAutoLogin()
    }
    
    func syncFromSession() async {
        let currentUser = await authSession.currentUser
        let access = await authSession.accessToken
        self.user = currentUser
        self.isAuthenticated = (currentUser != nil) && (access != nil)
        self.hasStoredSession = Self.storedSessionExists(in: refreshStorage)
    }

    private nonisolated static func storedSessionExists(in storage: RefreshTokenStorage) -> Bool {
        ((try? storage.load()) ?? nil) != nil
    }
    
    func signOut() {
        Task {
            await authService.signOut()
            await syncFromSession()
        }
    }
}

