//
//  RootView.swift
//  college-ios-app
//
//  Created by pc on 18.10.2025.
//

import SwiftUI

private enum RootPhase: Hashable {
    case welcome
    case splash
    case main
}

struct RootView: View {
    @EnvironmentObject private var sessionViewModel: SessionViewModel
    @Environment(\.colorScheme) private var colorScheme

    @AppStorage(AuthDefaultsKey.welcomePassed) private var welcomePassed = false
    @AppStorage(AppTheme.storageKey) private var theme: AppTheme = .system

    private var phase: RootPhase {
        if !welcomePassed && !sessionViewModel.hasStoredSession { return .welcome }
        return sessionViewModel.isBootstrapping ? .splash : .main
    }

    var body: some View {
        Group {
            switch phase {
            case .welcome:
                WelcomeScreen(onEnter: { welcomePassed = true })
                    .environment(\.colors, AppColors.of(colorScheme, theme: theme))

            case .splash:
                SplashView()

            case .main:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: phase)
        .onChange(of: sessionViewModel.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated { welcomePassed = true }
        }
        .alert("Сессия истекла", isPresented: $sessionViewModel.didSessionExpire) {
            Button("Понятно", role: .cancel) {}
        } message: {
            Text("Войдите в аккаунт заново, чтобы видеть пропуски и отметки.")
        }
    }
}
