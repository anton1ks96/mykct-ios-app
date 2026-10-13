//
//  WatchMocks.swift
//  CollegeWatch
//

#if DEBUG
import Foundation

nonisolated enum WatchMocks {

    static let monday = ScheduleCalendar.monday(of: .now)
    static let snapshot = ScheduleMocks.widgetSnapshot(monday: monday)

    static func at(_ dayOffset: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        ScheduleCalendar.date(
            ScheduleCalendar.adding(days: dayOffset, to: monday),
            atMinutes: hour * 60 + minute
        )
    }
}
#endif
