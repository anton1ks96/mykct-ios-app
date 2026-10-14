//
//  WidgetScheduleTests.swift
//  college-ios-appTests
//

import Foundation
import Testing
@testable import college_ios_app

private let monday = ScheduleParsing.date(from: "2026-10-12")!
private let nextMonday = ScheduleCalendar.adding(weeks: 1, to: monday)

private func at(_ dayOffset: Int, _ hour: Int, _ minute: Int = 0) -> Date {
    ScheduleCalendar.date(
        ScheduleCalendar.adding(days: dayOffset, to: monday),
        atMinutes: hour * 60 + minute
    )
}

private func mockWeek(_ week: Date) -> [Lesson] {
    (0..<7).flatMap { offset in
        ScheduleMocks.lessons(day: ScheduleCalendar.adding(days: offset, to: week), weekday: offset)
    }
}

private func merge(_ snapshot: WidgetSnapshot?, week: Date) -> WidgetSnapshot? {
    WidgetSnapshot.merging(
        snapshot,
        lessons: mockWeek(week),
        monday: week,
        selection: ScheduleMocks.selection,
        resetsSelection: true,
        at: at(0, 8)
    )
}

private let currentWeek = merge(nil, week: monday)!
private let bothWeeks = merge(currentWeek, week: nextMonday)!

private func focus(_ content: WidgetContent) -> WidgetFocus? {
    if case .focus(let focus) = content { return focus }
    return nil
}

private func rest(_ content: WidgetContent) -> WidgetRest? {
    if case .rest(let rest) = content { return rest }
    return nil
}

@Suite("Расписание виджета")
struct WidgetScheduleTests {

    @Test("Без снимка виджет просит выбрать группу, без недели - нет данных")
    func setupAndUnavailable() {
        #expect(WidgetSchedule.content(at: at(0, 10), in: nil) == .setup)
        #expect(WidgetSchedule.content(at: at(8, 10), in: currentWeek) == .unavailable)
    }

    @Test("До первой пары фокус на ней, статус по сегодняшнему дню")
    func morningFocusesFirstLesson() throws {
        let focus = try #require(focus(WidgetSchedule.content(at: at(0, 7, 30), in: bothWeeks)))

        #expect(focus.stage == .upcoming)
        #expect(focus.slot.title == "Математика")
        #expect(focus.day.slots.count == 4)
        #expect(!WidgetSchedule.isSoon(focus.slot, at: at(0, 7, 30)))
        #expect(WidgetSchedule.isSoon(focus.slot, at: at(0, 8)))
    }

    @Test("Во время пары фокус на ней, в перемену - на следующей")
    func ongoingAndBreak() throws {
        let ongoing = try #require(focus(WidgetSchedule.content(at: at(0, 10, 5), in: bothWeeks)))
        #expect(ongoing.stage == .ongoing)
        #expect(ongoing.slot.title == "Математика")
        #expect(ongoing.next?.title == "Основы алгоритмизации")

        let pause = try #require(focus(WidgetSchedule.content(at: at(0, 10, 32), in: bothWeeks)))
        #expect(pause.stage == .upcoming)
        #expect(pause.slot.title == "Основы алгоритмизации")
        #expect(pause.next?.title == "Английский A0.11 · Английский A0.12")
    }

    @Test("На последней паре дальше показывается следующий учебный день")
    func lastLessonPointsToNextDay() throws {
        let focus = try #require(focus(WidgetSchedule.content(at: at(0, 15), in: bothWeeks)))

        #expect(focus.slot.title == "Физическая культура")
        #expect(focus.next?.title == "Базы данных")
        #expect(focus.next?.day == ScheduleCalendar.adding(days: 1, to: monday))
    }

    @Test("После последней пары сразу показывается завтрашний день")
    func afterLessonsShowsTomorrow() throws {
        let focus = try #require(focus(WidgetSchedule.content(at: at(0, 16), in: bothWeeks)))

        #expect(focus.stage == .tomorrow)
        #expect(focus.slot.title == "Базы данных")
        #expect(focus.next?.title == "Разработка мобильных приложений")
    }

    @Test("Свободный день до 18:00 - отдых с превью, с 18:00 - завтрашняя пара")
    func freeDaySwitchesInEvening() throws {
        let day = try #require(rest(WidgetSchedule.content(at: at(2, 12), in: bothWeeks)))
        #expect(day.lessonCount == 0)
        #expect(day.upcoming?.date == ScheduleCalendar.adding(days: 3, to: monday))

        let evening = try #require(focus(WidgetSchedule.content(at: at(2, 18), in: bothWeeks)))
        #expect(evening.stage == .tomorrow)
        #expect(evening.slot.title == "Английский A0.11 · Английский A0.12")
    }

    @Test("Пары кончились, а завтра свободно - отдых до ближайшего учебного дня")
    func finishedDayBeforeFreeDay() throws {
        let day = try #require(rest(WidgetSchedule.content(at: at(1, 15), in: bothWeeks)))

        #expect(day.lessonCount == 3)
        #expect(day.upcoming?.date == ScheduleCalendar.adding(days: 3, to: monday))
    }

    @Test("Пятница вечером ведёт на понедельник, только если следующая неделя в снимке")
    func fridayEveningPointsToMonday() throws {
        let full = try #require(rest(WidgetSchedule.content(at: at(4, 18), in: bothWeeks)))
        #expect(full.lessonCount == 5)
        #expect(full.upcoming?.date == nextMonday)

        let partial = try #require(rest(WidgetSchedule.content(at: at(4, 18), in: currentWeek)))
        #expect(partial.upcoming == nil)

        let sunday = try #require(focus(WidgetSchedule.content(at: at(6, 18), in: bothWeeks)))
        #expect(sunday.stage == .tomorrow)
        #expect(sunday.day.date == nextMonday)
    }

    @Test("Параллельные пары собираются в один слот")
    func parallelLessonsShareSlot() {
        let lessons = [
            Lesson(id: "a", day: monday, start: 540, end: 630, title: "React", topic: "Хуки", room: "2-5"),
            Lesson(id: "b", day: monday, start: 540, end: 630, title: "УчПроект.FE", room: "3-2"),
            Lesson(id: "c", day: monday, start: 400, end: 490, title: "Математика", room: "301"),
        ]

        let slots = WidgetSchedule.slots(of: lessons, on: monday)

        #expect(slots.map(\.title) == ["Математика", "React · УчПроект.FE"])
        #expect(slots[1].room == "2-5 · 3-2")
        #expect(slots[1].topic.isEmpty)
        #expect(slots[1].timeRange == "9:00 - 10:30")
    }

    @Test("Неразделённая пара называется подгруппами, как карточка в приложении")
    func unsplitLessonUsesDisplayTitle() throws {
        let focus = try #require(focus(WidgetSchedule.content(at: at(0, 12, 50), in: bothWeeks)))

        #expect(focus.slot.title == "Английский A0.11 · Английский A0.12")
        #expect(focus.slot.symbol == SubjectIcon.symbol(for: "Английский язык"))
        #expect(focus.slot.subgroupCount == 2)
        #expect(focus.slot.room.isEmpty)
    }

    @Test("Ряды большого виджета: лишние прошедшие отбрасываются, будущие уходят в «Ещё»")
    func largeRows() {
        #expect(WidgetSchedule.rows(around: 2, count: 5, limit: 4)
            == WidgetRows(past: 0..<2, future: 3..<5, hidden: 0))
        #expect(WidgetSchedule.rows(around: 4, count: 5, limit: 3)
            == WidgetRows(past: 1..<4, future: 5..<5, hidden: 0))
        #expect(WidgetSchedule.rows(around: 0, count: 6, limit: 4)
            == WidgetRows(past: 1..<1, future: 1..<4, hidden: 2))
        #expect(WidgetSchedule.rows(around: nil, count: 5, limit: 4)
            == WidgetRows(past: 0..<0, future: 0..<3, hidden: 2))
        #expect(WidgetSchedule.rows(around: nil, count: 3, limit: 4)
            == WidgetRows(past: 0..<0, future: 0..<3, hidden: 0))
    }

    @Test("Метка дня: Далее, Завтра или день недели")
    func dayLabels() {
        let tuesday = ScheduleCalendar.adding(days: 1, to: monday)
        let thursday = ScheduleCalendar.adding(days: 3, to: monday)

        #expect(WidgetSchedule.dayLabel(of: monday, focusDay: monday, at: at(0, 10)) == "Далее")
        #expect(WidgetSchedule.dayLabel(of: tuesday, focusDay: monday, at: at(0, 10)) == "Завтра")
        #expect(WidgetSchedule.dayLabel(of: thursday, focusDay: monday, at: at(0, 10)) == "Чт")
    }

    @Test("Точки таймлайна - границы пар, вечер и полночи на двое суток")
    func entryDates() {
        let now = at(0, 10, 5)
        let dates = WidgetSchedule.entryDates(from: now, in: bothWeeks)

        #expect(dates.first == now)
        #expect(dates == dates.sorted())
        #expect(dates.contains(at(0, 10, 30)))
        #expect(dates.contains(at(0, 11, 40)))
        #expect(dates.contains(at(0, 18)))
        #expect(dates.contains(at(1, 0)))
        #expect(dates.contains(at(1, 8)))
        #expect(!dates.contains(at(0, 9)))
        #expect(dates.allSatisfy { $0 <= now.addingTimeInterval(WidgetSchedule.timelineSpan) })
    }

    @Test("Дозагружаются отсутствующие и устаревшие недели, с пятницы - и следующая")
    func weeksToRefresh() {
        #expect(WidgetSchedule.weeksToRefresh(at: at(0, 12), in: currentWeek).isEmpty)
        #expect(WidgetSchedule.weeksToRefresh(at: at(1, 9), in: currentWeek) == [monday])
        #expect(WidgetSchedule.weeksToRefresh(at: at(4, 9), in: currentWeek) == [monday, nextMonday])
    }

    @Test("Перезагрузка в 5 утра, без сегодняшней недели - через полчаса")
    func reloadDate() {
        #expect(WidgetSchedule.reloadDate(after: at(0, 10), hasToday: true) == at(1, 5))
        #expect(WidgetSchedule.reloadDate(after: at(0, 4), hasToday: true) == at(0, 5))
        #expect(WidgetSchedule.reloadDate(after: at(0, 10), hasToday: false) == at(0, 10, 30))
    }

    @Test("День и неделя для часов: без недели пусто, свободный день без пар")
    func dayAndWeek() {
        let days = (0..<7).map { ScheduleCalendar.adding(days: $0, to: monday) }

        #expect(WidgetSchedule.day(at(1, 15), in: currentWeek)?.slots.count == 3)
        #expect(WidgetSchedule.day(at(2, 12), in: currentWeek)?.slots == [])
        #expect(WidgetSchedule.day(at(7, 10), in: currentWeek) == nil)
        #expect(WidgetSchedule.week(of: at(3, 10), in: currentWeek).map(\.date) == days)
        #expect(WidgetSchedule.week(of: nextMonday, in: currentWeek).isEmpty)
        #expect(WidgetSchedule.week(of: nextMonday, in: bothWeeks).count == 7)
    }

    @Test("Smart Stack поднимает расписание за 15 минут до пары на двое суток вперёд")
    func relevantIntervals() {
        let intervals = WidgetSchedule.relevantIntervals(from: at(0, 10, 5), in: bothWeeks)

        #expect(intervals.count == 7)
        #expect(intervals.first == DateInterval(start: at(0, 8, 45), end: at(0, 10, 30)))
        #expect(WidgetSchedule.relevantIntervals(from: at(0, 10, 5), in: nil).isEmpty)
    }

    @Test("Короткая дата дня для часов")
    func dayShort() throws {
        let mayDay = try #require(ScheduleParsing.date(from: "2026-05-01"))

        #expect(ScheduleFormat.dayShort(at(3, 10)) == "Чт, 15 окт")
        #expect(ScheduleFormat.dayShort(mayDay) == "Пт, 1 мая")
    }
}
