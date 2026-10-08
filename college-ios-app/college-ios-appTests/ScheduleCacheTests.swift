//
//  ScheduleCacheTests.swift
//  college-ios-appTests
//

import Foundation
import Testing
@testable import college_ios_app

private actor StubScheduleRepository: ScheduleRepositoryProtocol {
    private let cached: WeekSchedule?
    private let error: APIError
    private var responses: [WeekSchedule?]
    private(set) var mondays: [Date] = []

    init(
        cached: WeekSchedule?,
        responses: [WeekSchedule?] = [nil],
        error: APIError = .url(URLError(.notConnectedToInternet))
    ) {
        self.cached = cached
        self.responses = responses
        self.error = error
    }

    func weekSchedule(monday: Date, selection: Selection) async throws -> WeekSchedule {
        mondays.append(monday)
        let response = responses.count > 1 ? responses.removeFirst() : responses[0]
        guard let response else { throw error }
        return response
    }

    func cachedWeek(monday: Date, selection: Selection) async -> WeekSchedule? {
        cached
    }

    func classDetails(id: String) async throws -> [DetailRow] {
        []
    }
}

private func makeFileURL() -> URL {
    FileManager.default.temporaryDirectory
        .appending(path: "schedule-cache-tests-\(UUID().uuidString)")
        .appending(path: "schedule-cache.json")
}

private var currentMonday: Date {
    ScheduleCalendar.monday(of: ScheduleCalendar.day(of: .now))
}

private func lesson(on day: Date) -> Lesson {
    Lesson(id: "lesson-\(day.timeIntervalSince1970)", day: day, start: 9 * 60, end: 10 * 60 + 30, title: "Математика")
}

@MainActor
private func makeViewModel(cached: WeekSchedule?) -> ScheduleViewModel {
    makeViewModel(repository: StubScheduleRepository(cached: cached))
}

@MainActor
private func makeViewModel(repository: StubScheduleRepository) -> ScheduleViewModel {
    let defaults = UserDefaults(suiteName: "schedule.cache.tests.\(UUID().uuidString)")!
    return ScheduleViewModel(
        repository: repository,
        selectionStore: SelectionStore(defaults: defaults),
        settingsStore: ScheduleSettingsStore(defaults: defaults)
    )
}

@Suite("Кэш расписания")
struct ScheduleCacheTests {

    @Test("Сохранённая неделя переживает пересоздание кэша")
    func weekSurvivesRestart() async {
        let url = makeFileURL()
        let monday = currentMonday
        let selection = ScheduleMocks.selection
        let fetchedAt = Date(timeIntervalSince1970: 1_780_000_000)

        await ScheduleCache(fileURL: url).save(
            WeekSchedule(lessons: [lesson(on: monday)], fetchedAt: fetchedAt),
            monday: monday,
            selection: selection
        )

        let restored = await ScheduleCache(fileURL: url).week(monday: monday, selection: selection)
        #expect(restored?.lessons == [lesson(on: monday)])
        #expect(restored?.fetchedAt == fetchedAt)
        #expect(await ScheduleCache(fileURL: url).week(monday: monday, selection: Selection(group: "ИТ24-11")) == nil)
    }

    @Test("Прошлые недели не хранятся, текущая остаётся")
    func pastWeeksArePruned() async {
        let cache = ScheduleCache(fileURL: makeFileURL())
        let selection = ScheduleMocks.selection
        let previous = ScheduleCalendar.adding(weeks: -1, to: currentMonday)

        await cache.save(WeekSchedule(lessons: [lesson(on: previous)]), monday: previous, selection: selection)
        await cache.save(WeekSchedule(lessons: [lesson(on: currentMonday)]), monday: currentMonday, selection: selection)

        #expect(await cache.week(monday: previous, selection: selection) == nil)
        #expect(await cache.week(monday: currentMonday, selection: selection) != nil)
    }

    @Test("Битый файл читается как пустой кэш")
    func corruptedFileIsEmpty() async throws {
        let url = makeFileURL()
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("not json".utf8).write(to: url)

        #expect(await ScheduleCache(fileURL: url).week(monday: currentMonday, selection: ScheduleMocks.selection) == nil)
    }
}

@MainActor
@Suite("Расписание без сети")
struct ScheduleOfflineTests {

    @Test("Без сети показывается неделя из кэша с пометкой")
    func offlineShowsCachedWeek() async {
        let today = ScheduleCalendar.day(of: .now)
        let viewModel = makeViewModel(cached: WeekSchedule(lessons: [lesson(on: today)], fetchedAt: .now))

        await viewModel.start()

        #expect(viewModel.state.isOffline)
        #expect(viewModel.state.error == nil)
        #expect(!viewModel.state.isLoading)
        #expect(viewModel.state.days.contains { $0.date == today && $0.lessonCount == 1 })
    }

    @Test("Без сети и без кэша показывается ошибка")
    func offlineWithoutCacheShowsError() async {
        let viewModel = makeViewModel(cached: nil)

        await viewModel.start()

        #expect(viewModel.state.error != nil)
        #expect(!viewModel.state.isOffline)
        #expect(viewModel.state.days.isEmpty)
    }

    @Test("Ошибка сервера при кэше не выдаётся за отсутствие связи")
    func serverErrorWithCacheIsStale() async {
        let today = ScheduleCalendar.day(of: .now)
        let repository = StubScheduleRepository(
            cached: WeekSchedule(lessons: [lesson(on: today)], fetchedAt: .now),
            error: .server(code: 503)
        )
        let viewModel = makeViewModel(repository: repository)

        await viewModel.start()

        #expect(viewModel.state.isStale)
        #expect(!viewModel.state.isOffline)
        #expect(viewModel.state.days.contains { $0.date == today && $0.lessonCount == 1 })
    }

    @Test("После возврата связи плашка снимается и показываются свежие данные")
    func reconnectReplacesCachedWeek() async {
        let tuesday = ScheduleCalendar.adding(days: 1, to: currentMonday)
        let fresh = WeekSchedule(lessons: [lesson(on: currentMonday), lesson(on: tuesday)])
        let repository = StubScheduleRepository(
            cached: WeekSchedule(lessons: [lesson(on: currentMonday)], fetchedAt: .now),
            responses: [nil, fresh]
        )
        let viewModel = makeViewModel(repository: repository)

        await viewModel.start()
        #expect(viewModel.state.isOffline)

        await viewModel.retry()

        #expect(!viewModel.state.isOffline)
        #expect(viewModel.state.days.map(\.lessonCount).reduce(0, +) == 2)
    }

    @Test("Возврат в приложение перезагружает неделю, показанную без связи")
    func returningRefreshesOfflineWeek() async {
        let fresh = WeekSchedule(lessons: [lesson(on: currentMonday)])
        let repository = StubScheduleRepository(
            cached: WeekSchedule(lessons: [], fetchedAt: .now),
            responses: [nil, fresh]
        )
        let viewModel = makeViewModel(repository: repository)

        await viewModel.start()
        await viewModel.refreshIfOutdated()

        #expect(!viewModel.state.isOffline)
        #expect(viewModel.state.days.contains { $0.date == currentMonday && $0.lessonCount == 1 })
    }

    @Test("Возврат в приложение со свежей неделей в сеть не ходит")
    func returningKeepsFreshWeek() async {
        let fresh = WeekSchedule(lessons: [lesson(on: currentMonday)])
        let repository = StubScheduleRepository(cached: nil, responses: [fresh])
        let viewModel = makeViewModel(repository: repository)

        await viewModel.start()
        let requests = await repository.mondays.filter { $0 == currentMonday }.count
        await viewModel.refreshIfOutdated()

        #expect(await repository.mondays.filter { $0 == currentMonday }.count == requests)
    }
}
