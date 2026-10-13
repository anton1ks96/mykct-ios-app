//
//  WidgetSchedule.swift
//  college-ios-app
//

import Foundation

nonisolated enum WidgetSchedule {

    static let eveningMinutes = 18 * 60
    static let morningMinutes = 5 * 60
    static let soonInterval: TimeInterval = 60 * 60
    static let staleInterval: TimeInterval = 12 * 60 * 60
    static let retryInterval: TimeInterval = 30 * 60
    static let timelineSpan: TimeInterval = 48 * 60 * 60
    static let lookaheadDays = 3

    static func content(at now: Date, in snapshot: WidgetSnapshot?) -> WidgetContent {
        guard let snapshot else { return .setup }

        let today = ScheduleCalendar.day(of: now)
        guard let lessons = snapshot.lessons(on: today) else { return .unavailable }

        let day = WidgetDay(date: today, slots: slots(of: lessons, on: today))
        let upcoming = nextDay(after: today, in: snapshot)

        if let index = day.slots.firstIndex(where: { now < $0.endDate }) {
            let isOngoing = day.slots[index].startDate <= now
            let next = day.slots.indices.contains(index + 1)
                ? day.slots[index + 1]
                : upcoming?.slots.first
            return .focus(WidgetFocus(
                stage: isOngoing ? .ongoing : .upcoming,
                day: day,
                index: index,
                next: next
            ))
        }

        let tomorrow = ScheduleCalendar.adding(days: 1, to: today)
        let isEvening = ScheduleCalendar.minutes(of: now) >= eveningMinutes
        if let upcoming, upcoming.date == tomorrow, !day.slots.isEmpty || isEvening {
            return .focus(WidgetFocus(
                stage: .tomorrow,
                day: upcoming,
                index: 0,
                next: upcoming.slots.dropFirst().first
            ))
        }

        return .rest(WidgetRest(lessonCount: day.slots.count, upcoming: upcoming))
    }

    static func slots(of lessons: [Lesson], on day: Date) -> [WidgetSlot] {
        Dictionary(grouping: lessons, by: \.slot)
            .map { WidgetSlot(day: day, start: $0.key.start, end: $0.key.end, lessons: $0.value) }
            .sorted { ($0.start, $0.end) < ($1.start, $1.end) }
    }

    static func isSoon(_ slot: WidgetSlot, at now: Date) -> Bool {
        slot.startDate.timeIntervalSince(now) <= soonInterval
    }

    static func dayLabel(of day: Date, focusDay: Date, at now: Date) -> String {
        if day == focusDay { return "Далее" }
        if day == ScheduleCalendar.adding(days: 1, to: ScheduleCalendar.day(of: now)) {
            return "Завтра"
        }
        return ScheduleFormat.weekdayShort(day)
    }

    static func rows(around focus: Int?, count: Int, limit: Int) -> WidgetRows {
        let first = (focus ?? -1) + 1
        let futureCount = count - first

        if futureCount > limit {
            return WidgetRows(
                past: first..<first,
                future: first..<(first + limit - 1),
                hidden: futureCount - limit + 1
            )
        }

        let lastPast = focus ?? 0
        let pastCount = max(0, min(lastPast, limit - futureCount))
        return WidgetRows(past: (lastPast - pastCount)..<lastPast, future: first..<count, hidden: 0)
    }

    static func entryDates(from now: Date, in snapshot: WidgetSnapshot?) -> [Date] {
        let today = ScheduleCalendar.day(of: now)
        let limit = now.addingTimeInterval(timelineSpan)
        var dates: Set<Date> = []

        for offset in 0...2 {
            let day = ScheduleCalendar.adding(days: offset, to: today)
            dates.insert(day)
            dates.insert(ScheduleCalendar.date(day, atMinutes: eveningMinutes))
            for lesson in snapshot?.lessons(on: day) ?? [] {
                let start = ScheduleCalendar.date(day, atMinutes: lesson.start)
                dates.insert(start.addingTimeInterval(-soonInterval))
                dates.insert(start)
                dates.insert(ScheduleCalendar.date(day, atMinutes: lesson.end))
            }
        }

        return [now] + dates.filter { $0 > now && $0 <= limit }.sorted()
    }

    static func weeksToRefresh(at now: Date, in snapshot: WidgetSnapshot) -> [Date] {
        let today = ScheduleCalendar.day(of: now)
        let current = ScheduleCalendar.monday(of: today)
        let ahead = ScheduleCalendar.monday(of: ScheduleCalendar.adding(days: lookaheadDays, to: today))
        let mondays = ahead == current ? [current] : [current, ahead]

        return mondays.filter { monday in
            guard let savedAt = snapshot.savedAt(weekOf: monday) else { return true }
            return now.timeIntervalSince(savedAt) > staleInterval
        }
    }

    static func reloadDate(after now: Date, hasToday: Bool) -> Date {
        guard hasToday else { return now.addingTimeInterval(retryInterval) }

        let morning = ScheduleCalendar.date(ScheduleCalendar.day(of: now), atMinutes: morningMinutes)
        return morning > now ? morning : ScheduleCalendar.adding(days: 1, to: morning)
    }

    private static func nextDay(after today: Date, in snapshot: WidgetSnapshot) -> WidgetDay? {
        var day = ScheduleCalendar.adding(days: 1, to: today)
        while let lessons = snapshot.lessons(on: day) {
            if !lessons.isEmpty {
                return WidgetDay(date: day, slots: slots(of: lessons, on: day))
            }
            day = ScheduleCalendar.adding(days: 1, to: day)
        }
        return nil
    }
}
