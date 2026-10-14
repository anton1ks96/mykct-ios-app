//
//  WidgetSnapshot.swift
//  college-ios-app
//

import Foundation

nonisolated enum ScheduleWidgetKey {
    static let kind = "CollegeWidget"
    static let appGroup = "group.com.college.MyKCT"
    static let snapshot = "widget.snapshot"
}

nonisolated struct WidgetWeek: Codable, Equatable, Sendable {
    let savedAt: Date
    let days: [[Lesson]]

    init(lessons: [Lesson], monday: Date, savedAt: Date) {
        self.savedAt = savedAt
        days = (0..<7).map { offset in
            let day = ScheduleCalendar.adding(days: offset, to: monday)
            return lessons
                .filter { ScheduleCalendar.calendar.isDate($0.day, inSameDayAs: day) }
                .sorted { ($0.start, $0.end) < ($1.start, $1.end) }
        }
    }
}

nonisolated struct WidgetSnapshot: Codable, Equatable, Sendable {
    let selection: Selection
    let weeks: [String: WidgetWeek]

    func lessons(on day: Date) -> [Lesson]? {
        guard let week = weeks[Self.key(of: day)] else { return nil }
        let index = ScheduleCalendar.weekdayIndex(of: day) - 1
        return week.days.indices.contains(index) ? week.days[index] : []
    }

    func savedAt(weekOf day: Date) -> Date? {
        weeks[Self.key(of: day)]?.savedAt
    }

    static func merging(
        _ snapshot: WidgetSnapshot?,
        lessons: [Lesson],
        monday: Date,
        selection: Selection,
        resetsSelection: Bool,
        at now: Date
    ) -> WidgetSnapshot? {
        let window = windowKeys(at: now)
        let week = key(of: monday)
        guard window.contains(week) else { return nil }

        let sameSelection = snapshot?.selection == selection
        guard sameSelection || resetsSelection else { return nil }

        var weeks = (sameSelection ? snapshot?.weeks ?? [:] : [:])
            .filter { window.contains($0.key) }
        weeks[week] = WidgetWeek(
            lessons: LessonSplitting.split(lessons, selection: selection),
            monday: ScheduleCalendar.monday(of: monday),
            savedAt: now
        )
        return WidgetSnapshot(selection: selection, weeks: weeks)
    }

    static func combining(
        _ incoming: WidgetSnapshot,
        with local: WidgetSnapshot?,
        at now: Date
    ) -> WidgetSnapshot {
        let window = windowKeys(at: now)
        guard let local, local.selection == incoming.selection else {
            return WidgetSnapshot(
                selection: incoming.selection,
                weeks: incoming.weeks.filter { window.contains($0.key) }
            )
        }

        var weeks = local.weeks
        for (key, week) in incoming.weeks where week.savedAt > weeks[key]?.savedAt ?? .distantPast {
            weeks[key] = week
        }
        return WidgetSnapshot(
            selection: local.selection,
            weeks: weeks.filter { window.contains($0.key) }
        )
    }

    private static func windowKeys(at now: Date) -> [String] {
        let current = ScheduleCalendar.monday(of: now)
        return [current, ScheduleCalendar.adding(weeks: 1, to: current)].map(key(of:))
    }

    private static func key(of day: Date) -> String {
        ScheduleParsing.requestString(from: ScheduleCalendar.monday(of: day))
    }
}
