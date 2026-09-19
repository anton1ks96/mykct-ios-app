//
//  ScheduleScreen.swift
//  college-ios-app
//

import SwiftUI

struct ScheduleScreen: View {
    @Environment(\.colors) private var colors
    @State private var viewModel: ScheduleViewModel
    @State private var isGroupSheetPresented = false

    @AppStorage(ScheduleDefaultsKey.view) private var scheduleView: ScheduleView = .threeDays
    @AppStorage(ScheduleDefaultsKey.skipWeekends) private var skipWeekends: Bool = false
    @AppStorage(ScheduleDefaultsKey.group) private var storedGroup: String = Selection.fallback.group
    @AppStorage(ScheduleDefaultsKey.subgroup) private var storedSubgroup: String?
    @AppStorage(ScheduleDefaultsKey.englishGroup) private var storedEnglishGroup: String?
    @AppStorage(ScheduleDefaultsKey.profileSubgroup) private var storedProfileSubgroup: String?

    init(viewModel: ScheduleViewModel = ScheduleViewModel()) {
        _viewModel = State(wrappedValue: viewModel)
    }

    private var settings: ScheduleSettings {
        ScheduleSettings(view: scheduleView, skipWeekends: skipWeekends)
    }

    private var storedSelection: Selection {
        Selection(
            group: Groups.all.contains(storedGroup) ? storedGroup : Selection.fallback.group,
            subgroup: storedSubgroup,
            englishGroup: storedEnglishGroup,
            profileSubgroup: storedProfileSubgroup
        )
    }

    private var state: ScheduleState { viewModel.state }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                WeekStrip(
                    days: state.days,
                    selected: Set(state.visible.map(\.date)),
                    onSelect: viewModel.select(date:)
                )
                .padding(.horizontal, 16)

                Fade(value: phase) { phase in
                    body(for: phase)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
            .animation(.snappy(duration: 0.28), value: state.visible)
        }
        .appBackground()
        .navigationTitle("Расписание")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { groupPill }
        }
        .sheet(isPresented: $isGroupSheetPresented) {
            GroupSheet(selection: state.selection, onSelect: viewModel.update(selection:))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: isLessonSheetPresented) {
            if let details = state.details {
                LessonSheet(
                    details: details,
                    selection: state.selection,
                    onSelect: viewModel.select(subgroup:)
                )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .refreshable { await viewModel.retry() }
        .task { await viewModel.start() }
        .onChange(of: settings, initial: true) { _, updated in viewModel.apply(settings: updated) }
        .onChange(of: storedSelection) { _, updated in viewModel.update(selection: updated) }
    }

    // MARK: - Sections

    private var groupPill: some View {
        Button {
            isGroupSheetPresented = true
        } label: {
            HStack(spacing: 4) {
                Text(state.selection.label)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
            }
            .frame(maxWidth: 190)
        }
        .accessibilityLabel("Выбрать группу и подгруппы")
        .accessibilityValue(state.selection.label)
    }

    private var isLessonSheetPresented: Binding<Bool> {
        Binding(
            get: { state.details != nil },
            set: { presented in if !presented { viewModel.closeLesson() } }
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 20) {
            HeroSummary(caption: caption, value: value, subtitle: subtitle)

            if state.isStale {
                staleNote
            }

            WeekNav(
                onToday: viewModel.goToToday,
                onPrevious: { viewModel.shiftWeek(by: -1) },
                onNext: { viewModel.shiftWeek(by: 1) }
            )
        }
        .padding(.horizontal, Metrics.screenPadding)
    }

    private var staleNote: some View {
        HStack(spacing: 6) {
            Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.icloud")
                .font(.system(size: 12, weight: .semibold))

            Text(
                state.fetchedAt.map { "Портал недоступен, расписание от \(ScheduleFormat.dayMonth($0))" }
                    ?? "Портал недоступен, показано сохранённое расписание"
            )
            .textStyle(AppType.labelMedium)
        }
        .foregroundStyle(colors.onSurfaceVariant)
        .accessibilityElement(children: .combine)
    }

    private var phase: Phase {
        phaseOf(
            isLoading: state.isLoading,
            error: state.error,
            isEmpty: state.visible.allSatisfy { $0.lessons.isEmpty }
        )
    }

    @ViewBuilder
    private func body(for phase: Phase) -> some View {
        switch phase {
        case .loading:
            placeholder { Swirl().frame(width: 44, height: 44) }

        case .error:
            placeholder {
                Text(state.error ?? "Не удалось загрузить расписание")
                    .textStyle(AppType.bodyLarge)
                    .foregroundStyle(colors.onSurfaceVariant)
                    .multilineTextAlignment(.center)

                Button {
                    Task { await viewModel.retry() }
                } label: {
                    Label("Повторить", systemImage: "arrow.clockwise")
                }
                .glassAction()
                .frame(maxWidth: 240)
                .padding(.top, 12)
            }

        case .empty:
            placeholder {
                Text("Пар нет")
                    .textStyle(AppType.titleMedium)
                    .foregroundStyle(colors.onSurface)

                Text("Отдыхай")
                    .textStyle(AppType.bodyMedium)
                    .foregroundStyle(colors.onSurfaceVariant)
            }

        case .content:
            days
        }
    }

    private var days: some View {
        TimelineView(.everyMinute) { context in
            days(at: context.date)
        }
    }

    private func days(at now: Date) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(state.visible.enumerated()), id: \.element.id) { index, day in
                if state.visible.count > 1 {
                    DayHeader(
                        date: day.date,
                        detail: day.lessons.isEmpty
                            ? "Пар нет"
                            : ScheduleFormat.lessonsCount(day.lessons.slotCount),
                        isToday: day.date == ScheduleCalendar.day(of: now)
                    )
                    .padding(.horizontal, 16)
                    .padding(.top, index == 0 ? 0 : 28)
                    .padding(.bottom, 14)
                }

                if !day.lessons.isEmpty {
                    DayTimeline(
                        lessons: day.lessons,
                        now: dayTime(on: day.date, at: now),
                        onSelect: viewModel.openLesson
                    )
                    .padding(.horizontal, 16)
                }
            }
        }
    }

    private func placeholder<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, Metrics.screenPadding)
        .padding(.vertical, 48)
    }

    // MARK: - Copy

    private var caption: String {
        let end = ScheduleCalendar.adding(days: 6, to: state.weekStart)
        return "Неделя \(ScheduleFormat.dateRange(from: state.weekStart, to: end))"
    }

    private var value: String {
        if state.isLoading { return "Загружаем…" }
        if state.error != nil { return "Нет данных" }
        return state.lessonCount == 0 ? "Пар нет" : ScheduleFormat.lessonsCount(state.lessonCount)
    }

    private var subtitle: String {
        guard let first = state.visible.first, let last = state.visible.last else { return "" }
        guard state.visible.count == 1 else {
            return ScheduleFormat.dateRange(from: first.date, to: last.date)
        }
        return ScheduleFormat.dayTitle(first.date) + dayHours(first.lessons)
    }

    private func dayHours(_ lessons: [Lesson]) -> String {
        guard let first = lessons.first, let last = lessons.last else { return "" }
        return " · \(ScheduleFormat.time(first.start)) – \(ScheduleFormat.time(last.end))"
    }

    private func dayTime(on date: Date, at now: Date) -> Date? {
        date == ScheduleCalendar.day(of: now) ? now : nil
    }

}

#Preview {
    NavigationStack {
        ScheduleScreen(viewModel: ScheduleViewModel(repository: MockScheduleRepository()))
    }
}
