//
//  StreakSheet.swift
//  college-ios-app
//

import SwiftUI

struct StreakSheet: View {
    @Environment(\.colors) private var colors

    let viewModel: HomeViewModel

    @State private var tab: StreakTab = .streak

    private var state: HomeState { viewModel.state }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if state.canSeeLeaderboard {
                    SegmentedSwitch(items: StreakTab.allCases, title: \.title, selection: $tab)
                        .padding(.bottom, 24)
                }

                Fade(value: tab) { tab in
                    body(for: tab)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 24)
            .padding(.horizontal, Metrics.screenPadding)
            .padding(.bottom, 32)
        }
        .appBackground()
        .task(id: tab) {
            guard tab == .leaderboard else { return }
            await viewModel.loadLeaderboard()
        }
        .onChange(of: state.canSeeLeaderboard) { _, canSee in
            if !canSee { tab = .streak }
        }
    }

    @ViewBuilder
    private func body(for tab: StreakTab) -> some View {
        switch tab {
        case .streak: streak
        case .leaderboard: leaderboard
        }
    }

    // MARK: - Стрик

    @ViewBuilder
    private var streak: some View {
        if let streak = state.streak {
            content(for: streak)
        } else {
            HomePlaceholder { Swirl().frame(width: 44, height: 44) }
        }
    }

    private func content(for streak: Streak) -> some View {
        VStack(spacing: 0) {
            StreakFlame(diameter: 132, frameRate: 60, isActive: streak.current > 0)

            Text("\(streak.current)")
                .textStyle(AppType.displayLarge)
                .foregroundStyle(colors.onSurface)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Text(HomeFormat.daysInRow(streak.current, schoolDays: streak.schoolDays))
                .textStyle(AppType.titleMedium)
                .foregroundStyle(colors.onSurface)

            Text(HomeFormat.status(rate: streak.rate, schoolDays: streak.schoolDays))
                .textStyle(AppType.bodyMedium)
                .foregroundStyle(colors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.top, 4)

            WeekChecks(weekStart: state.weekStart, records: state.records)
                .padding(.top, 24)

            numbers(for: streak)
                .padding(.top, 24)

            if let period = period(for: streak) {
                Text(period)
                    .textStyle(AppType.labelMedium)
                    .foregroundStyle(colors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
            }
        }
    }

    private func numbers(for streak: Streak) -> some View {
        HStack(spacing: 0) {
            number("Дней", "\(streak.daysAttended)")
            number("Пар", "\(state.stats.total)")
            number("Посещал", "\(Int(streak.rate))%")
            number("Лучший", "\(streak.longest)")
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .glassSurface(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
    }

    private func number(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .textStyle(AppType.labelMedium)
                .foregroundStyle(colors.onSurfaceVariant)

            Text(value)
                .textStyle(AppType.titleMedium)
                .fontWeight(.bold)
                .foregroundStyle(colors.onSurface)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private func period(for streak: Streak) -> String? {
        guard let start = streak.periodStart, streak.schoolDays > 0 else { return nil }
        let days = "\(streak.daysAttended) из \(streak.schoolDays) учебных дней"
        return "С \(ScheduleFormat.dayMonth(start)) · \(days)"
    }

    // MARK: - Рейтинг

    private var leaderboard: some View {
        Fade(value: leaderboardPhase) { phase in
            leaderboard(for: phase)
        }
    }

    @ViewBuilder
    private func leaderboard(for phase: Phase) -> some View {
        switch phase {
        case .loading:
            HomePlaceholder { Swirl().frame(width: 44, height: 44) }

        case .error:
            HomeFailure(
                message: state.leaderboard.message ?? "Не удалось загрузить рейтинг",
                retry: "Обновить"
            ) {
                Task { await viewModel.reloadLeaderboard() }
            }

        case .empty:
            HomePlaceholder {
                Text("Рейтинг пока недоступен")
                    .textStyle(AppType.bodyLarge)
                    .foregroundStyle(colors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }

        case .content:
            if let board = state.leaderboard.board {
                LeaderboardBoard(board: board)
            }
        }
    }

    private var leaderboardPhase: Phase {
        switch state.leaderboard {
        case .idle, .loading: .loading
        case .failed: .error
        case .unavailable: .empty
        case .loaded: .content
        }
    }
}

#Preview {
    let viewModel = HomeViewModel(repository: MockHomeRepository())
    viewModel.sync(user: HomeMocks.user, isBootstrapping: false)

    return StreakSheet(viewModel: viewModel)
        .environment(\.colors, .dark)
}
