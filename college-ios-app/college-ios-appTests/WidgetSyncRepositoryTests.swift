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
        #expect(reloads.count == 1)
    }

    @Test("Ошибка загрузки не трогает снимок и виджет")
    func failedLoadKeepsWidget() async {
        let reloads = ReloadCounter()
        let (repository, store) = makeRepository(nil, reloads: reloads)

        _ = try? await repository.weekSchedule(monday: currentMonday, selection: selection)

        #expect(store.load() == nil)
        #expect(reloads.count == 0)
    }

    @Test("Дальняя неделя и кэш в снимок не пишутся")
    func farWeekAndCacheAreSkipped() async throws {
        let reloads = ReloadCounter()
        let far = ScheduleCalendar.adding(weeks: 3, to: currentMonday)
        let (repository, store) = makeRepository(week(on: far), reloads: reloads)

        _ = try await repository.weekSchedule(monday: far, selection: selection)
        _ = await repository.cachedWeek(monday: currentMonday, selection: selection)

        #expect(store.load() == nil)
        #expect(reloads.count == 0)
    }
}
