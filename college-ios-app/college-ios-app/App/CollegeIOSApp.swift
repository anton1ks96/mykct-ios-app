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
                    guard phase == .active else { return }
                    AppDependencies.pushService.refreshAuthorization()
                }
        }
    }
}
