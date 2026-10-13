//
//  WidgetContent.swift
//  college-ios-app
//

import Foundation

nonisolated struct WidgetSlot: Equatable, Sendable {
    let day: Date
    let start: Int
    let end: Int
    let lessons: [Lesson]

    var startDate: Date { ScheduleCalendar.date(day, atMinutes: start) }
    var endDate: Date { ScheduleCalendar.date(day, atMinutes: end) }

    var title: String { Self.joined(lessons.map(\.title)) }
    var room: String { Self.joined(lessons.map(\.room)) }
    var topic: String { lessons.count == 1 ? lessons[0].topic : "" }
    var subgroupCount: Int { lessons.count == 1 ? lessons[0].subgroups.count : 0 }
    var symbol: String { SubjectIcon.symbol(for: lessons.first?.title ?? "") }

    var timeRange: String {
        "\(ScheduleFormat.time(start)) - \(ScheduleFormat.time(end))"
    }

    private static func joined(_ values: [String]) -> String {
        var unique: [String] = []
        for value in values where !value.isEmpty && !unique.contains(value) {
            unique.append(value)
        }
        return unique.joined(separator: " · ")
    }
}

nonisolated struct WidgetDay: Equatable, Sendable {
    let date: Date
    let slots: [WidgetSlot]
}

nonisolated enum WidgetStage: Equatable, Sendable {
    case ongoing
    case upcoming
    case tomorrow
}

nonisolated struct WidgetFocus: Equatable, Sendable {
    let stage: WidgetStage
    let day: WidgetDay
    let index: Int
    let next: WidgetSlot?

    var slot: WidgetSlot { day.slots[index] }
}

nonisolated struct WidgetRest: Equatable, Sendable {
    let lessonCount: Int
    let upcoming: WidgetDay?
}

nonisolated enum WidgetContent: Equatable, Sendable {
    case setup
    case unavailable
    case focus(WidgetFocus)
    case rest(WidgetRest)
}

nonisolated struct WidgetRows: Equatable, Sendable {
    let past: Range<Int>
    let future: Range<Int>
    let hidden: Int
}
