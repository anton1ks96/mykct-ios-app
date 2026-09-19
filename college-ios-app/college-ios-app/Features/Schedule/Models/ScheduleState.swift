//
//  ScheduleState.swift
//  college-ios-app
//

import Foundation

nonisolated struct DayCell: Identifiable, Equatable, Sendable {
    let date: Date
    let lessonCount: Int
    let isToday: Bool

    var id: Date { date }
}

nonisolated struct DaySchedule: Identifiable, Equatable, Sendable {
    let date: Date
    let lessons: [Lesson]

    var id: Date { date }
}

nonisolated struct LessonDetails: Equatable, Sendable {
    let lesson: Lesson
    var selected: LessonSubgroup?
    var rows: [DetailRow] = []
    var isLoading: Bool = true
    var error: String?

    var detailsID: String { selected?.classID ?? lesson.id }
}

nonisolated struct ScheduleState: Equatable, Sendable {
    var weekStart: Date
    var selectedDate: Date
    var selection: Selection
    var settings: ScheduleSettings
    var days: [DayCell] = []
    var visible: [DaySchedule] = []
    var isLoading: Bool = true
    var error: String?
    var details: LessonDetails?
    var isStale: Bool = false
    var fetchedAt: Date?

    var lessonCount: Int {
        visible.reduce(0) { $0 + $1.lessons.slotCount }
    }
}
