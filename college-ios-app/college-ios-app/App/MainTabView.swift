//
//  MainTabView.swift
//  college-ios-app
//
//  Created by pc on 22.09.2025.
//

import SwiftUI

enum Tab: String {
    case schedule
    case home
    case settings
}

struct MainTabView: View {
    @EnvironmentObject private var sessionViewModel: SessionViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedTab: Tab = .schedule
    @State private var homeViewModel = HomeViewModel()
    @State private var isLoginPresented = false
    @State private var isStreakPresented = false
    @State private var isAccountPresented = false

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ScheduleScreen()
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) { streakButton }
                        ToolbarItem(placement: .topBarTrailing) { accountButton }
                    }
            }
            .tabItem {
                Label("Расписание", systemImage: "calendar")
            }
            .tag(Tab.schedule)

            NavigationStack {
                HomeScreen(
                    viewModel: homeViewModel,
                    onLogin: { isLoginPresented = true }
                )
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) { streakButton }
                    ToolbarItem(placement: .topBarTrailing) { accountButton }
                }
            }
            .tabItem {
                Label("Главная", systemImage: "house")
            }
            .tag(Tab.home)

            NavigationStack {
                SettingsScreen()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) { accountButton }
                    }
            }
            .tabItem {
                Label("Настройки", systemImage: "gearshape")
            }
            .tag(Tab.settings)
        }
        .onChange(of: session, initial: true) { _, updated in
            homeViewModel.sync(user: updated.user, isBootstrapping: updated.isBootstrapping)
        }
        .sheet(isPresented: $isStreakPresented) {
            if let streak = homeViewModel.state.streak {
                StreakSheet(
                    streak: streak,
                    stats: homeViewModel.state.stats,
                    weekStart: homeViewModel.state.weekStart,
                    records: homeViewModel.state.records
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $isAccountPresented) {
            AccountSheet()
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $isLoginPresented) {
            LoginScreen(onClose: { isLoginPresented = false })
        }
        .environment(\.colors, AppColors.of(colorScheme))
    }

    @ViewBuilder
    private var streakButton: some View {
        if let streak = homeViewModel.state.streak {
            Button {
                isStreakPresented = true
            } label: {
                StreakFlame(diameter: 30, isAnimated: false, isActive: streak.current > 0)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Стрик посещений")
        }
    }

    private var accountButton: some View {
        Button {
            if sessionViewModel.isAuthenticated {
                isAccountPresented = true
            } else {
                isLoginPresented = true
            }
        } label: {
            Image(systemName: sessionViewModel.isAuthenticated
                  ? "person.circle.fill"
                  : "rectangle.portrait.and.arrow.forward")
                .imageScale(.medium)
        }
        .accessibilityLabel(sessionViewModel.isAuthenticated ? "Профиль" : "Войти")
    }

    private var session: HomeSession {
        HomeSession(user: sessionViewModel.user, isBootstrapping: sessionViewModel.isBootstrapping)
    }
}
