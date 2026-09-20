//
//  HomeFormat.swift
//  college-ios-app
//

import Foundation

nonisolated enum HomeFormat {

    static func daysInRow(_ count: Int, schoolDays: Int) -> String {
        guard schoolDays > 0 else { return "Стрик ещё не начался" }
        return count == 0 ? "Стрик прервался" : "\(ScheduleFormat.daysCount(count)) подряд"
    }

    static func status(rate: Double, schoolDays: Int) -> String {
        guard schoolDays > 0 else { return "Учебных дней пока не было" }

        return switch rate {
        case 90...: "Ходишь почти без пропусков — так держать"
        case 75..<90: "Крепкая посещаемость, всё под контролем"
        case 50..<75: "Бывает по-разному — можно лучше"
        default: "Пропусков много, пора возвращаться"
        }
    }

    static func place(_ rank: Int) -> String {
        "\(rank) место"
    }

    static func cohort(participants: Int) -> String {
        "Твоё место среди \(ScheduleFormat.studentsCount(participants)) курса"
    }

    static func average(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(1)).locale(ScheduleCalendar.locale))
    }

    static func date(_ date: Date) -> String {
        let parts = ScheduleCalendar.calendar.dateComponents([.day, .month, .year], from: date)
        return String(format: "%d.%02d.%d", parts.day ?? 0, parts.month ?? 0, parts.year ?? 0)
    }

    static func attended(present: Int, total: Int) -> String {
        "Был на \(present) из \(ScheduleFormat.lessonsCount(total))"
    }

    static func motivation(percent: Int) -> String {
        switch percent {
        case 95...: "Ни одного пропуска"
        case 85..<95: "Почти идеальный месяц"
        case 70..<85: "Хорошо идёшь, не сбавляй"
        case 50..<70: "Половина есть, подтянись"
        default: "Пора возвращаться на пары"
        }
    }

    static func monthCaption(_ month: Date) -> String {
        "Посещаемость за \(ScheduleFormat.monthName(month).lowercased())"
    }
}
