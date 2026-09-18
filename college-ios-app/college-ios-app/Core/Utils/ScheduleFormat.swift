//
//  ScheduleFormat.swift
//  college-ios-app
//

import Foundation

nonisolated enum ScheduleFormat {

    static func time(_ minutes: Int) -> String {
        String(format: "%d:%02d", minutes / 60, minutes % 60)
    }

    static func weekdayShort(_ date: Date) -> String {
        shortWeekdays[ScheduleCalendar.weekdayIndex(of: date) - 1]
    }

    static func dayMonth(_ date: Date) -> String {
        let parts = ScheduleCalendar.calendar.dateComponents([.day, .month], from: date)
        return "\(parts.day ?? 0) \(genitiveMonths[(parts.month ?? 1) - 1])"
    }

    static func dayTitle(_ date: Date) -> String {
        "\(fullWeekdays[ScheduleCalendar.weekdayIndex(of: date) - 1]), \(dayMonth(date))"
    }

    static func monthName(_ date: Date) -> String {
        nominativeMonths[ScheduleCalendar.calendar.component(.month, from: date) - 1]
    }

    static func monthYear(_ date: Date) -> String {
        let parts = ScheduleCalendar.calendar.dateComponents([.month, .year], from: date)
        return "\(nominativeMonths[(parts.month ?? 1) - 1]) \(parts.year ?? 0)"
    }

    static func dateRange(from: Date, to: Date) -> String {
        let calendar = ScheduleCalendar.calendar
        let sameMonth = calendar.component(.month, from: from) == calendar.component(.month, from: to)
        let start = sameMonth ? "\(calendar.component(.day, from: from))" : dayMonth(from)
        return "\(start) – \(dayMonth(to))"
    }

    static func remaining(seconds: Int) -> String {
        let left = max(seconds, 0)
        return left < 60 ? "\(left) с" : "\(left / 60) мин"
    }

    static func lessonsCount(_ count: Int) -> String {
        plural(count, one: "пара", few: "пары", many: "пар")
    }

    static func daysCount(_ count: Int) -> String {
        plural(count, one: "день", few: "дня", many: "дней")
    }

    static func subjectsCount(_ count: Int) -> String {
        plural(count, one: "предмет", few: "предмета", many: "предметов")
    }

    static func scoresCount(_ count: Int) -> String {
        plural(count, one: "оценка", few: "оценки", many: "оценок")
    }

    private static func plural(_ count: Int, one: String, few: String, many: String) -> String {
        let word: String
        switch (count % 100, count % 10) {
        case (11...14, _): word = many
        case (_, 1): word = one
        case (_, 2...4): word = few
        default: word = many
        }
        return "\(count) \(word)"
    }

    private static let nominativeMonths = [
        "Январь", "Февраль", "Март", "Апрель", "Май", "Июнь",
        "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь",
    ]

    private static let genitiveMonths = [
        "января", "февраля", "марта", "апреля", "мая", "июня",
        "июля", "августа", "сентября", "октября", "ноября", "декабря",
    ]

    private static let fullWeekdays = [
        "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье",
    ]

    static let shortWeekdays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
}
