//
//  MonthCalendarTests.swift
//  college-ios-appTests
//

import Testing
import Foundation
@testable import college_ios_app

private func date(_ value: String) -> Date {
    ScheduleParsing.date(from: value)!
}

private func string(_ value: Date) -> String {
    ScheduleParsing.requestString(from: value)
}

@Suite("Границы месяца")
struct MonthBoundsTests {

    @Test("Начало месяца берётся от любого его дня")
    func start() {
        for day in ["2026-09-01", "2026-09-17", "2026-09-30"] {
            #expect(string(ScheduleCalendar.monthStart(of: date(day))) == "2026-09-01")
        }
    }

    @Test("Конец месяца знает про длину месяца")
    func end() {
        #expect(string(ScheduleCalendar.monthEnd(of: date("2026-01-15"))) == "2026-01-31")
        #expect(string(ScheduleCalendar.monthEnd(of: date("2026-09-17"))) == "2026-09-30")
    }

    @Test("Февраль високосного года на день длиннее")
    func february() {
        #expect(ScheduleCalendar.days(inMonth: date("2024-02-10")) == 29)
        #expect(ScheduleCalendar.days(inMonth: date("2026-02-10")) == 28)
        #expect(string(ScheduleCalendar.monthEnd(of: date("2024-02-10"))) == "2024-02-29")
        #expect(string(ScheduleCalendar.monthEnd(of: date("2026-02-10"))) == "2026-02-28")
    }

    @Test("Один месяц отличается от соседнего и от того же месяца другого года")
    func sameMonth() {
        #expect(ScheduleCalendar.isSameMonth(date("2026-09-01"), date("2026-09-30")))
        #expect(!ScheduleCalendar.isSameMonth(date("2026-09-30"), date("2026-10-01")))
        #expect(!ScheduleCalendar.isSameMonth(date("2025-09-17"), date("2026-09-17")))
    }
}

@Suite("Сдвиг между месяцами")
struct MonthShiftTests {

    @Test("Первое число не съезжает на коротком месяце")
    func firstDay() {
        #expect(string(ScheduleCalendar.adding(months: 1, to: date("2026-01-01"))) == "2026-02-01")
        #expect(string(ScheduleCalendar.adding(months: -1, to: date("2026-03-01"))) == "2026-02-01")
    }

    @Test("Год перелистывается вместе с месяцем")
    func year() {
        #expect(string(ScheduleCalendar.adding(months: 1, to: date("2026-12-01"))) == "2027-01-01")
        #expect(string(ScheduleCalendar.adding(months: -1, to: date("2026-01-01"))) == "2025-12-01")
    }
}

@Suite("Сетка месяца")
struct MonthGridTests {

    private func lead(_ month: String) -> Int {
        ScheduleCalendar.weekdayIndex(of: ScheduleCalendar.monthStart(of: date(month))) - 1
    }

    private func rows(_ month: String) -> Int {
        (lead(month) + ScheduleCalendar.days(inMonth: date(month)) + 6) / 7
    }

    @Test("Месяц с понедельника начинается без пустых ячеек")
    func monday() {
        #expect(lead("2026-06-01") == 0)
    }

    @Test("Месяц с воскресенья сдвинут на шесть ячеек")
    func sunday() {
        #expect(lead("2026-02-01") == 6)
    }

    @Test("Февраль с понедельника даёт четыре строки, худший случай - шесть")
    func rowCount() {
        #expect(rows("2027-02-01") == 4)
        #expect(rows("2026-02-01") == 5)
        #expect(rows("2026-09-01") == 5)
        #expect(rows("2026-03-01") == 6)
        #expect(rows("2026-08-01") == 6)
    }
}
