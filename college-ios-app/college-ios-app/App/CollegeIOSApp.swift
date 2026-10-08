//
//  CollegeIOSApp.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import SwiftUI

@main
struct CollegeIOSApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var sessionViewModel = SessionViewModel(
        authService: AppDependencies.authService,
        authSession: AppDependencies.authSession
    )

    @AppStorage(AppTheme.storageKey) private var selectedTheme: AppTheme = .system
    @Environment(\.scenePhase) private var scenePhase
    @State private var wasInBackground = false

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(selectedTheme.colorScheme)
                .environmentObject(sessionViewModel)
                .environment(AppDependencies.pushService)
                .task {
                    sessionViewModel.bootstrapAutoLogin()
                }
                .onChange(of: scenePhase, initial: true) { _, phase in
                    switch phase {
                    case .background:
                        wasInBackground = true
                    case .active:
                        AppDependencies.pushService.refreshAuthorization()
                        if wasInBackground {
                            sessionViewModel.reconnectIfNeeded()
                        }
                        wasInBackground = false
                    default:
                        break
                    }
                }
        }
    }
}
