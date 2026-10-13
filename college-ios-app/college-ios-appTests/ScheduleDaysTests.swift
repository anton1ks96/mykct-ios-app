//
//  ScheduleDaysTests.swift
//  college-ios-appTests
//

import Foundation
import Testing
@testable import college_ios_app

private let monday = ScheduleParsing.date(from: "2026-08-24")!

private func day(_ offset: Int) -> Date {
    ScheduleCalendar.adding(days: offset, to: monday)
}

private func offsets(_ dates: [Date]) -> [Int] {
    dates.map { ScheduleCalendar.calendar.dateComponents([.day], from: monday, to: $0).day ?? -1 }
}

@Suite("Дни недели расписания")
struct ScheduleDaysTests {

    @Test("Время пары считается по настенным часам дня, а не прибавкой минут")
    func lessonTimeIsWallClock() {
        let start = ScheduleCalendar.date(day(1), atMinutes: 14 * 60 + 45)

        #expect(ScheduleCalendar.day(of: start) == day(1))
        #expect(ScheduleCalendar.minutes(of: start) == 14 * 60 + 45)
        #expect(ScheduleCalendar.date(day(1), atMinutes: 24 * 60) == day(2))
    }

    @Test("Понедельник считается началом недели")
    func mondayIsWeekStart() {
        #expect(ScheduleCalendar.monday(of: day(6)) == monday)
        #expect(ScheduleCalendar.weekdayIndex(of: monday) == 1)
        #expect(ScheduleCalendar.weekdayIndex(of: day(6)) == 7)
    }

    @Test("Неделя целиком или без выходных")
    func weekDays() {
        let full = ScheduleDays.week(from: monday, settings: ScheduleSettings())
        #expect(offsets(full) == [0, 1, 2, 3, 4, 5, 6])

        let workdays = ScheduleDays.week(
            from: monday,
            settings: ScheduleSettings(view: .threeDays, skipWeekends: true)
        )
        #expect(offsets(workdays) == [0, 1, 2, 3, 4])
    }

    @Test("Вид «Неделя» показывает все дни независимо от выбранного")
    func weekViewShowsEverything() {
        let settings = ScheduleSettings(view: .week, skipWeekends: false)
        let days = ScheduleDays.week(from: monday, settings: settings)
        let visible = ScheduleDays.visible(in: days, selected: day(3), settings: settings)
        #expect(offsets(visible) == [0, 1, 2, 3, 4, 5, 6])
    }

    @Test("Вид «Сегодня» показывает один выбранный день")
    func todayViewShowsSingleDay() {
        let settings = ScheduleSettings(view: .today, skipWeekends: false)
        let days = ScheduleDays.week(from: monday, settings: settings)
        let visible = ScheduleDays.visible(in: days, selected: day(2), settings: settings)
        #expect(offsets(visible) == [2])
    }

    @Test("Диапазон «3 дня» не вылезает за неделю")
    func threeDaysStopsAtWeekEnd() {
        let settings = ScheduleSettings(view: .threeDays, skipWeekends: false)
        let days = ScheduleDays.week(from: monday, settings: settings)

        #expect(offsets(ScheduleDays.visible(in: days, selected: monday, settings: settings)) == [0, 1, 2])
        #expect(offsets(ScheduleDays.visible(in: days, selected: day(5), settings: settings)) == [5, 6])
        #expect(offsets(ScheduleDays.visible(in: days, selected: day(6), settings: settings)) == [6])
    }

    @Test("Выбран скрытый выходной - показывается хвост рабочей недели")
    func hiddenWeekendFallsBackToWorkweekTail() {
        let settings = ScheduleSettings(view: .threeDays, skipWeekends: true)
        let days = ScheduleDays.week(from: monday, settings: settings)
        let visible = ScheduleDays.visible(in: days, selected: day(5), settings: settings)
        #expect(offsets(visible) == [2, 3, 4])
    }
}
