//
//  WidgetSyncRepositoryTests.swift
//  college-ios-appTests
//

import Foundation
import Synchronization
import Testing
@testable import college_ios_app

private struct FixedScheduleRepository: ScheduleRepositoryProtocol {
    let week: WeekSchedule?

    func weekSchedule(monday: Date, selection: Selection) async throws -> WeekSchedule {
        guard let week else { throw APIError.url(URLError(.notConnectedToInternet)) }
        return week
    }

    func cachedWeek(monday: Date, selection: Selection) async -> WeekSchedule? {
        week
    }

    func classDetails(id: String) async throws -> [DetailRow] {
        []
    }
}

private final class ReloadCounter: Sendable {
    private let value = Mutex(0)

    var count: Int { value.withLock { $0 } }

    func increment() {
        value.withLock { $0 += 1 }
    }
}

private let selection = Selection(group: "ИТ26-11")

private var currentMonday: Date {
    ScheduleCalendar.monday(of: ScheduleCalendar.day(of: .now))
}

private func week(on day: Date) -> WeekSchedule {
    WeekSchedule(lessons: [
        Lesson(id: "math", day: day, start: 9 * 60, end: 10 * 60 + 30, title: "Математика"),
    ])
}

private func makeRepository(
    _ week: WeekSchedule?,
    reloads: ReloadCounter
) -> (WidgetSyncRepository, WidgetSnapshotStore) {
    let store = WidgetSnapshotStore(suiteName: "widget.sync.tests.\(UUID().uuidString)")
    let repository = WidgetSyncRepository(
        base: FixedScheduleRepository(week: week),
        store: store,
        onChange: { reloads.increment() }
    )
    return (repository, store)
}

@Suite("Связка расписания с виджетом")
struct WidgetSyncRepositoryTests {

    @Test("Загруженная текущая неделя попадает в снимок и обновляет виджет")
    func loadedWeekUpdatesWidget() async throws {
        let reloads = ReloadCounter()
        let (repository, store) = makeRepository(week(on: currentMonday), reloads: reloads)

        _ = try await repository.weekSchedule(monday: currentMonday, selection: selection)

        #expect(store.load()?.lessons(on: currentMonday)?.map(\.title) == ["Математика"])
        #expect(reloads.count > 0)
    }

    @Test("Ошибка загрузки той же группы не трогает снимок и виджет")
    func failedLoadKeepsWidget() async throws {
        let reloads = ReloadCounter()
        let (repository, store) = makeRepository(nil, reloads: reloads)
        try store.save(week(on: currentMonday).lessons, monday: currentMonday, selection: selection)

        _ = try? await repository.weekSchedule(monday: currentMonday, selection: selection)

        #expect(store.load()?.lessons(on: currentMonday)?.map(\.title) == ["Математика"])
        #expect(reloads.count == 0)
    }

    @Test("Дальняя неделя и кэш в снимок не пишутся")
    func farWeekAndCacheAreSkipped() async throws {
        let reloads = ReloadCounter()
        let far = ScheduleCalendar.adding(weeks: 3, to: currentMonday)
        let (repository, store) = makeRepository(week(on: far), reloads: reloads)
        try store.save(week(on: currentMonday).lessons, monday: currentMonday, selection: selection)

        _ = try await repository.weekSchedule(monday: far, selection: selection)
        _ = await repository.cachedWeek(monday: currentMonday, selection: selection)

        #expect(store.load()?.lessons(on: far) == nil)
        #expect(store.load()?.lessons(on: currentMonday)?.count == 1)
        #expect(reloads.count == 0)
    }

    @Test("Новая группа попадает в снимок, даже если неделя не загрузилась")
    func newSelectionSurvivesFailedLoad() async throws {
        let reloads = ReloadCounter()
        let (repository, store) = makeRepository(nil, reloads: reloads)
        try store.save(week(on: currentMonday).lessons, monday: currentMonday, selection: selection)
        let other = Selection(group: "ИТ25-11")

        _ = try? await repository.weekSchedule(monday: currentMonday, selection: other)

        #expect(store.load()?.selection == other)
        #expect(store.load()?.lessons(on: currentMonday) == nil)
        #expect(reloads.count == 1)
    }

    @Test("Новая группа на дальней неделе тоже сбрасывает снимок")
    func newSelectionOnFarWeekResetsSnapshot() async throws {
        let reloads = ReloadCounter()
        let far = ScheduleCalendar.adding(weeks: 3, to: currentMonday)
        let (repository, store) = makeRepository(week(on: far), reloads: reloads)
        try store.save(week(on: currentMonday).lessons, monday: currentMonday, selection: selection)
        let other = Selection(group: "ИТ25-11")

        _ = try await repository.weekSchedule(monday: far, selection: other)

        #expect(store.load()?.selection == other)
        #expect(store.load()?.lessons(on: currentMonday) == nil)
        #expect(reloads.count == 1)
    }
}
