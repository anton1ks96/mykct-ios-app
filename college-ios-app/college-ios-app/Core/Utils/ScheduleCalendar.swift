//
//  ScheduleCalendar.swift
//  college-ios-app
//

import Foundation

nonisolated enum ScheduleCalendar {

    static let locale = Locale(identifier: "ru_RU")

    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = locale
        calendar.firstWeekday = 2
        return calendar
    }()

    static func day(of date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    static func monday(of date: Date) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? day(of: date)
    }

    static func adding(days: Int, to date: Date) -> Date {
        calendar.date(byAdding: .day, value: days, to: date) ?? date
    }

    static func adding(weeks: Int, to date: Date) -> Date {
        calendar.date(byAdding: .weekOfYear, value: weeks, to: date) ?? date
    }

    static func adding(months: Int, to date: Date) -> Date {
        calendar.date(byAdding: .month, value: months, to: date) ?? date
    }

    static func monthStart(of date: Date) -> Date {
        calendar.dateInterval(of: .month, for: date)?.start ?? day(of: date)
    }

    static func monthEnd(of date: Date) -> Date {
        adding(days: days(inMonth: date) - 1, to: monthStart(of: date))
    }

    static func days(inMonth date: Date) -> Int {
        calendar.range(of: .day, in: .month, for: date)?.count ?? 30
    }

    static func isSameMonth(_ left: Date, _ right: Date) -> Bool {
        calendar.isDate(left, equalTo: right, toGranularity: .month)
    }

    static func weekdayIndex(of date: Date) -> Int {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 ? 7 : weekday - 1
    }

    static func date(_ day: Date, atMinutes minutes: Int) -> Date {
        calendar.date(byAdding: .minute, value: minutes, to: day) ?? day
    }

    static func minutes(of date: Date) -> Int {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        return (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
    }
}
