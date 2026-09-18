//
//  HomeScreen.swift
//  college-ios-app
//

import SwiftUI

struct HomeScreen: View {
    @Environment(\.colors) private var colors

    let viewModel: HomeViewModel
    let onLogin: () -> Void

    @State private var tab: HomeTab = .attendance

    private var state: HomeState { viewModel.state }

    var body: some View {
        ScrollView {
            Fade(value: state.gate) { gate in
                body(for: gate)
            }
            .padding(.horizontal, Metrics.screenPadding)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .appBackground()
        .navigationTitle("Главная")
        .toolbar {
            if let username = state.user?.username {
                ToolbarItem(placement: .topBarTrailing) { userPill(username) }
            }
        }
        .refreshable { await viewModel.refresh() }
        .sheet(isPresented: isScoresPresented) {
            if let scores = state.scores {
                ScoresSheet(scores: scores)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var isScoresPresented: Binding<Bool> {
        Binding(
            get: { state.scores != nil },
            set: { presented in if !presented { viewModel.closeSubject() } }
        )
    }

    // MARK: - Sections

    private func userPill(_ username: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "person.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(colors.primary)

            Text(username)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(maxWidth: 150)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Вы вошли как \(username)")
    }

    @ViewBuilder
    private func body(for gate: HomeGate) -> some View {
        switch gate {
        case .loading:
            HomePlaceholder { Swirl().frame(width: 44, height: 44) }

        case .invite:
            SignInInvite(onLogin: onLogin)

        case .content:
            content
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 24) {
            SegmentedSwitch(items: HomeTab.allCases, title: \.title, selection: $tab)

            Fade(value: tab) { tab in
                switch tab {
                case .attendance: attendance
                case .performance: performance
                }
            }
        }
    }

    // MARK: - Посещаемость

    private var attendance: some View {
        VStack(alignment: .leading, spacing: 20) {
            AttendanceCalendar(
                month: state.month,
                selected: state.selected,
                marks: state.marks,
                onToday: viewModel.goToToday,
                onPrevious: { viewModel.shiftMonth(by: -1) },
                onNext: { viewModel.shiftMonth(by: 1) },
                onSelect: viewModel.select(date:)
            )

            MonthSummary(
                percent: state.stats.percent,
                caption: state.motivation ?? HomeFormat.monthCaption(state.month),
                detail: summaryDetail,
                hasData: state.stats.total > 0
            )

            Fade(value: attendancePhase) { phase in
                attendanceBody(for: phase)
            }
        }
    }

    @ViewBuilder
    private func attendanceBody(for phase: Phase) -> some View {
        switch phase {
        case .loading:
            HomePlaceholder { Swirl().frame(width: 44, height: 44) }

        case .error:
            HomePlaceholder {
                Text(state.error ?? "Не удалось загрузить посещаемость")
                    .textStyle(AppType.bodyLarge)
                    .foregroundStyle(colors.onSurfaceVariant)
                    .multilineTextAlignment(.center)

                Button {
                    Task { await viewModel.refresh() }
                } label: {
                    Label("Повторить", systemImage: "arrow.clockwise")
                }
                .glassAction()
                .frame(maxWidth: 240)
                .padding(.top, 12)
            }

        case .empty:
            HomePlaceholder {
                Text("За этот месяц отметок нет")
                    .textStyle(AppType.bodyLarge)
                    .foregroundStyle(colors.onSurfaceVariant)
            }

        case .content:
            days
        }
    }

    @ViewBuilder
    private var days: some View {
        if state.selectedDay.records.isEmpty {
            HomePlaceholder {
                Text("\(ScheduleFormat.dayTitle(state.selected)) - пар не было")
                    .textStyle(AppType.bodyLarge)
                    .foregroundStyle(colors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }
        } else {
            AttendanceDayCard(
                day: state.selectedDay,
                isToday: state.selected == ScheduleCalendar.day(of: .now)
            )
        }
    }

    // MARK: - Успеваемость

    private var performance: some View {
        VStack(alignment: .leading, spacing: 24) {
            HeroSummary(
                caption: "Текущее полугодие",
                value: performanceValue,
                subtitle: "Нажми на предмет — покажем баллы по занятиям"
            )

            Fade(value: performancePhase) { phase in
                performanceBody(for: phase)
            }
        }
    }

    @ViewBuilder
    private func performanceBody(for phase: Phase) -> some View {
        switch phase {
        case .loading:
            HomePlaceholder { Swirl().frame(width: 44, height: 44) }

        case .empty, .error:
            HomePlaceholder {
                Text("Колледж не отдал ни одного предмета")
                    .textStyle(AppType.bodyLarge)
                    .foregroundStyle(colors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }

        case .content:
            GlassGroup(spacing: 8) {
                VStack(spacing: 8) {
                    ForEach(state.subjects) { subject in
                        SubjectRow(subject: subject) { viewModel.openSubject(subject) }
                    }
                }
            }
        }
    }

    // MARK: - Copy

    private var summaryDetail: String {
        if state.isLoading && state.records.isEmpty { return "Загружаем…" }
        if state.error != nil { return "Нет данных" }
        if state.stats.total == 0 { return "Отметок за месяц нет" }
        return HomeFormat.attended(present: state.stats.present, total: state.stats.total)
    }

    private var attendancePhase: Phase {
        phaseOf(
            isLoading: state.isLoading && state.records.isEmpty,
            error: state.error,
            isEmpty: state.records.isEmpty
        )
    }

    private var performancePhase: Phase {
        phaseOf(
            isLoading: state.isLoading && state.subjects.isEmpty,
            error: nil,
            isEmpty: state.subjects.isEmpty
        )
    }

    private var performanceValue: String {
        if state.isLoading && state.subjects.isEmpty { return "Загружаем…" }
        if state.subjects.isEmpty { return "Нет данных" }
        return ScheduleFormat.subjectsCount(state.subjects.count)
    }
}

#Preview("Вошёл") {
    let viewModel = HomeViewModel(repository: MockHomeRepository())
    viewModel.sync(user: HomeMocks.user, isBootstrapping: false)

    return NavigationStack {
        HomeScreen(viewModel: viewModel, onLogin: {})
    }
}

#Preview("Не вошёл") {
    let viewModel = HomeViewModel(repository: MockHomeRepository())
    viewModel.sync(user: nil, isBootstrapping: false)

    return NavigationStack {
        HomeScreen(viewModel: viewModel, onLogin: {})
    }
}
