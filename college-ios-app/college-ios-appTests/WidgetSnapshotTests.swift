//
//  WidgetSnapshotTests.swift
//  college-ios-appTests
//

import Foundation
import Testing
@testable import college_ios_app

private let monday = ScheduleParsing.date(from: "2026-10-12")!
private let now = ScheduleCalendar.date(monday, atMinutes: 10 * 60)
private let nextMonday = ScheduleCalendar.adding(weeks: 1, to: monday)

private let selection = Selection(group: "ИТ26-11", subgroup: "Подгр1", englishGroup: "A0.11")

private func lesson(_ id: String, on day: Date, start: Int, subgroups: [LessonSubgroup] = []) -> Lesson {
    Lesson(id: id, day: day, start: start, end: start + 90, title: id, subgroups: subgroups)
}

private func merge(
    _ snapshot: WidgetSnapshot?,
    _ lessons: [Lesson],
    monday week: Date = monday,
    selection chosen: Selection = selection,
    resetsSelection: Bool = true
) -> WidgetSnapshot? {
    WidgetSnapshot.merging(
        snapshot,
        lessons: lessons,
        monday: week,
        selection: chosen,
        resetsSelection: resetsSelection,
        at: now
    )
}

@Suite("Снимок расписания для виджета")
struct WidgetSnapshotTests {

    @Test("Неделя раскладывается по дням, а своя пара делится на подгруппы")
    func splitsWeekByDays() throws {
        let tuesday = ScheduleCalendar.adding(days: 1, to: monday)
        let english = lesson("Английский", on: tuesday, start: 9 * 60, subgroups: [
            LessonSubgroup(id: "A0.11", title: "Английский A0.11", topic: "", room: "210"),
            LessonSubgroup(id: "Подгр1", title: "Английский Подгр1", topic: "", room: "211"),
        ])
        let lessons = [
            lesson("Поздняя", on: monday, start: 12 * 60),
            lesson("Ранняя", on: monday, start: 9 * 60),
            english,
        ]

        let snapshot = try #require(merge(nil, lessons))

        #expect(snapshot.lessons(on: monday)?.map(\.title) == ["Ранняя", "Поздняя"])
        #expect(snapshot.lessons(on: tuesday)?.map(\.room) == ["210", "211"])
        #expect(snapshot.lessons(on: ScheduleCalendar.adding(days: 6, to: monday)) == [])
    }

    @Test("Непокрытый день отличается от дня без пар")
    func uncoveredDayIsNil() throws {
        let snapshot = try #require(merge(nil, [lesson("Математика", on: monday, start: 9 * 60)]))

        #expect(snapshot.lessons(on: ScheduleCalendar.adding(days: 2, to: monday)) == [])
        #expect(snapshot.lessons(on: nextMonday) == nil)
        #expect(snapshot.savedAt(weekOf: monday) == now)
    }

    @Test("Сохраняются только текущая и следующая неделя")
    func keepsOnlyCurrentAndNextWeek() throws {
        let previous = ScheduleCalendar.adding(weeks: -1, to: monday)
        let later = ScheduleCalendar.adding(weeks: 2, to: monday)
        let snapshot = try #require(merge(nil, []))

        #expect(merge(snapshot, [], monday: previous) == nil)
        #expect(merge(snapshot, [], monday: later) == nil)

        let both = try #require(merge(snapshot, [], monday: nextMonday))
        #expect(both.weeks.count == 2)
    }

    @Test("Смена группы от приложения сбрасывает старые недели")
    func newSelectionFromAppResetsWeeks() throws {
        let first = try #require(merge(nil, [lesson("Математика", on: monday, start: 9 * 60)]))
        let both = try #require(merge(first, [], monday: nextMonday))
        let other = Selection(group: "ИТ25-11")

        let reset = try #require(merge(both, [], selection: other))

        #expect(reset.selection == other)
        #expect(reset.weeks.count == 1)
        #expect(reset.lessons(on: nextMonday) == nil)
    }

    @Test("Запись виджета со старой группой не затирает новую")
    func staleSelectionFromWidgetIsIgnored() throws {
        let snapshot = try #require(merge(nil, []))
        let other = Selection(group: "ИТ25-11")

        #expect(merge(snapshot, [], selection: other, resetsSelection: false) == nil)
        #expect(merge(snapshot, [], monday: nextMonday, resetsSelection: false) != nil)
    }

    @Test("Снимок переживает запись и чтение")
    func storeRoundTrip() throws {
        let store = WidgetSnapshotStore(suiteName: "widget.snapshot.tests.\(UUID().uuidString)")

        let saved = try store.save(
            [lesson("Математика", on: monday, start: 9 * 60)],
            monday: monday,
            selection: selection,
            at: now
        )

        #expect(saved)
        #expect(store.load()?.lessons(on: monday)?.map(\.title) == ["Математика"])
        #expect(store.load()?.selection == selection)
    }

    @Test("Повреждённые данные читаются как отсутствие снимка")
    func brokenDataIsNoSnapshot() {
        let suiteName = "widget.snapshot.tests.\(UUID().uuidString)"
        UserDefaults(suiteName: suiteName)!.set(Data("{".utf8), forKey: ScheduleWidgetKey.snapshot)

        #expect(WidgetSnapshotStore(suiteName: suiteName).load() == nil)
        #expect(WidgetSnapshotStore(suiteName: nil).load() == nil)
    }

    @Test("Догружаются только недостающие и устаревшие недели")
    func refreshFetchesMissingAndStaleWeeks() async throws {
        let store = WidgetSnapshotStore(suiteName: "widget.snapshot.tests.\(UUID().uuidString)")
        try store.save([], monday: monday, selection: selection, at: now)
        let friday = ScheduleCalendar.date(
            ScheduleCalendar.adding(days: 4, to: monday),
            atMinutes: 10 * 60
        )
        var requested: [Date] = []

        let saved = await store.refresh(at: friday) { week, chosen in
            requested.append(week)
            #expect(chosen == selection)
            return [lesson("Математика", on: week, start: 9 * 60)]
        }

        #expect(saved)
        #expect(requested == [monday, nextMonday])
        #expect(store.load()?.lessons(on: nextMonday)?.map(\.title) == ["Математика"])

        requested = []
        let again = await store.refresh(at: friday) { week, _ in
            requested.append(week)
            return []
        }

        #expect(!again)
        #expect(requested.isEmpty)
    }

    @Test("Ошибка загрузки не трогает снимок, а без снимка сеть не нужна")
    func refreshKeepsSnapshotOnError() async throws {
        let store = WidgetSnapshotStore(suiteName: "widget.snapshot.tests.\(UUID().uuidString)")
        var calls = 0

        let empty = await store.refresh(at: now) { _, _ in
            calls += 1
            return []
        }

        #expect(!empty)
        #expect(calls == 0)

        try store.save(
            [lesson("Математика", on: monday, start: 9 * 60)],
            monday: monday,
            selection: selection,
            at: now
        )
        let before = store.load()

        let failed = await store.refresh(at: now.addingTimeInterval(13 * 60 * 60)) { _, _ in
            throw URLError(.notConnectedToInternet)
        }

        #expect(!failed)
        #expect(store.load() == before)
    }

    @Test("Снимок с iPhone другой группы целиком заменяет снимок на часах")
    func receiveTakesOtherSelection() throws {
        let phone = WidgetSnapshotStore(suiteName: "widget.snapshot.tests.\(UUID().uuidString)")
        let watch = WidgetSnapshotStore(suiteName: "widget.snapshot.tests.\(UUID().uuidString)")
        try phone.save(
            [lesson("Математика", on: monday, start: 9 * 60)],
            monday: monday,
            selection: selection,
            at: now
        )
        try watch.save([], monday: nextMonday, selection: Selection(group: "ИТ25-11"), at: now)
        let data = try #require(phone.data())

        #expect(try watch.receive(data, at: now))
        #expect(watch.load() == phone.load())
        #expect(try !watch.receive(data, at: now))
    }

    @Test("Неделя, скачанная часами позже, переживает приём старого снимка с iPhone")
    func receiveKeepsNewerWatchWeeks() throws {
        let phone = WidgetSnapshotStore(suiteName: "widget.snapshot.tests.\(UUID().uuidString)")
        let watch = WidgetSnapshotStore(suiteName: "widget.snapshot.tests.\(UUID().uuidString)")
        let later = now.addingTimeInterval(60 * 60)
        try phone.save(
            [lesson("Старая", on: monday, start: 9 * 60)],
            monday: monday,
            selection: selection,
            at: now
        )
        let stale = try #require(phone.data())

        #expect(try watch.receive(stale, at: now))
        try watch.save(
            [lesson("Свежая", on: monday, start: 9 * 60)],
            monday: monday,
            selection: selection,
            resetsSelection: false,
            at: later
        )

        #expect(try !watch.receive(stale, at: later))
        #expect(watch.load()?.lessons(on: monday)?.map(\.title) == ["Свежая"])

        try phone.save(
            [lesson("Новейшая", on: monday, start: 9 * 60)],
            monday: monday,
            selection: selection,
            at: later.addingTimeInterval(60)
        )
        let fresh = try #require(phone.data())
        #expect(try watch.receive(fresh, at: later))
        #expect(watch.load()?.lessons(on: monday)?.map(\.title) == ["Новейшая"])
    }

    @Test("Повреждённые данные с iPhone не трогают снимок")
    func brokenDataIsNotReceived() throws {
        let store = WidgetSnapshotStore(suiteName: "widget.snapshot.tests.\(UUID().uuidString)")
        try store.save([], monday: monday, selection: selection, at: now)
        let before = store.load()

        #expect(throws: DecodingError.self) { try store.receive(Data("{".utf8), at: now) }
        #expect(store.load() == before)

        let data = try #require(store.data())
        #expect(try !WidgetSnapshotStore(suiteName: nil).receive(data, at: now))
    }

    @Test("Отключённое расписание сбрасывает недели, а первая скачанная неделя снимает отметку")
    func disabledUntilWeekLoads() async throws {
        let store = WidgetSnapshotStore(suiteName: "widget.snapshot.tests.\(UUID().uuidString)")
        try store.save([lesson("Математика", on: monday, start: 9 * 60)], monday: monday, selection: selection, at: now)

        let disabled = await store.refresh(at: now.addingTimeInterval(13 * 60 * 60)) { _, _ in
            throw ScheduleDisabledError()
        }

        #expect(disabled)
        #expect(store.load()?.isDisabled == true)
        #expect(store.load()?.lessons(on: monday) == nil)
        #expect(try !store.disable(at: now))

        let enabled = await store.refresh(at: now.addingTimeInterval(14 * 60 * 60)) { _, _ in [] }

        #expect(enabled)
        #expect(store.load()?.isDisabled == false)
        #expect(store.load()?.selection == selection)
    }

    @Test("Отметка отключения доходит до часов и снимается неделей, скачанной позже")
    func receiveCarriesDisabled() throws {
        let phone = WidgetSnapshotStore(suiteName: "widget.snapshot.tests.\(UUID().uuidString)")
        let watch = WidgetSnapshotStore(suiteName: "widget.snapshot.tests.\(UUID().uuidString)")
        try phone.save([lesson("Математика", on: monday, start: 9 * 60)], monday: monday, selection: selection, at: now)
        #expect(try watch.receive(try #require(phone.data()), at: now))

        try phone.disable(at: now.addingTimeInterval(60))
        let disabled = try #require(phone.data())
        #expect(try watch.receive(disabled, at: now))
        #expect(watch.load()?.isDisabled == true)
        #expect(watch.load()?.lessons(on: monday) == nil)

        try watch.save(
            [lesson("Свежая", on: monday, start: 9 * 60)],
            monday: monday,
            selection: selection,
            resetsSelection: false,
            at: now.addingTimeInterval(120)
        )
        #expect(try !watch.receive(disabled, at: now))
        #expect(watch.load()?.isDisabled == false)
    }
}
