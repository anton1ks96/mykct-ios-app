//
//  ScheduleViewModel.swift
//  college-ios-app
//

import Foundation
import Observation

@Observable
final class ScheduleViewModel {

    private(set) var state: ScheduleState

    private let repository: ScheduleRepositoryProtocol
    private let selectionStore: SelectionStore

    private var weekLessons: [Lesson] = []
    private var loadTask: Task<Void, Never>?
    private var detailsTask: Task<Void, Never>?
    private var didStart = false

    init(
        repository: ScheduleRepositoryProtocol = AppDependencies.scheduleRepository,
        selectionStore: SelectionStore = SelectionStore(),
        settingsStore: ScheduleSettingsStore = ScheduleSettingsStore()
    ) {
        self.repository = repository
        self.selectionStore = selectionStore
        let today = ScheduleCalendar.day(of: .now)
        state = ScheduleState(
            weekStart: ScheduleCalendar.monday(of: today),
            selectedDate: today,
            selection: selectionStore.load(),
            settings: settingsStore.load()
        )
    }

    // MARK: - Intents

    func start() async {
        guard !didStart else { return }
        didStart = true
        await reload()
    }

    func retry() async {
        await reload()
    }

    func select(date: Date) {
        state.selectedDate = date
        applyWeek()
    }

    func shiftWeek(by weeks: Int) {
        let weekStart = ScheduleCalendar.adding(weeks: weeks, to: state.weekStart)
        state.weekStart = weekStart
        state.selectedDate = weekStart
        Task { await reload() }
    }

    func goToToday() {
        let today = ScheduleCalendar.day(of: .now)
        let weekStart = ScheduleCalendar.monday(of: today)
        guard weekStart != state.weekStart else {
            select(date: today)
            return
        }
        state.weekStart = weekStart
        state.selectedDate = today
        Task { await reload() }
    }

    func update(selection: Selection) {
        guard selection != state.selection else { return }
        state.selection = selection
        selectionStore.save(selection)
        Task { await reload() }
    }

    func apply(settings: ScheduleSettings) {
        guard settings != state.settings else { return }
        state.settings = settings
        guard state.error == nil else { return }
        applyWeek()
    }

    func openLesson(_ lesson: Lesson) {
        state.details = LessonDetails(lesson: lesson)
        loadDetails()
    }

    func select(subgroup: LessonSubgroup?) {
        guard let details = state.details, details.selected != subgroup else { return }
        state.details?.selected = subgroup
        state.details?.rows = []
        state.details?.error = nil
        state.details?.isLoading = true
        loadDetails()
    }

    func closeLesson() {
        detailsTask?.cancel()
        state.details = nil
    }

    private func loadDetails() {
        guard let details = state.details else { return }
        let id = details.detailsID

        detailsTask?.cancel()
        detailsTask = Task { [repository] in
            do {
                let rows = try await repository.classDetails(id: id)
                guard state.details?.detailsID == id else { return }
                state.details?.rows = rows
                state.details?.isLoading = false
            } catch {
                guard !ErrorText.isCancellation(error), state.details?.detailsID == id else { return }
                state.details?.isLoading = false
                state.details?.error = ErrorText.message(for: error)
            }
        }
    }

    // MARK: - Loading

    private func reload() async {
        loadTask?.cancel()
        let task = Task { await performLoad() }
        loadTask = task
        _ = await task.value
    }

    private func performLoad() async {
        state.isLoading = true
        do {
            let week = try await repository.weekSchedule(
                monday: state.weekStart,
                selection: state.selection
            )
            try Task.checkCancellation()
            weekLessons = LessonSplitting.split(week.lessons, selection: state.selection)
            state.isStale = week.isStale
            state.fetchedAt = week.fetchedAt
            state.error = nil
            state.isLoading = false
            applyWeek()
        } catch {
            guard !ErrorText.isCancellation(error) else { return }
            weekLessons = []
            state.days = []
            state.visible = []
            state.isStale = false
            state.fetchedAt = nil
            state.isLoading = false
            state.error = ErrorText.message(for: error) ?? "Не удалось загрузить расписание"
        }
    }

    private func applyWeek() {
        let today = ScheduleCalendar.day(of: .now)
        let byDate = Dictionary(grouping: weekLessons, by: \.day)
        let dates = ScheduleDays.week(from: state.weekStart, settings: state.settings)

        state.days = dates.map {
            DayCell(date: $0, lessonCount: byDate[$0]?.slotCount ?? 0, isToday: $0 == today)
        }
        state.visible = ScheduleDays
            .visible(in: dates, selected: state.selectedDate, settings: state.settings)
            .map { DaySchedule(date: $0, lessons: (byDate[$0] ?? []).sorted { $0.start < $1.start }) }
    }
}
