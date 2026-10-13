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
}
