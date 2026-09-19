//
//  LessonProgress.swift
//  college-ios-app
//

import Foundation

nonisolated enum LessonProgress {

    static func secondsLeft(of lesson: Lesson, at date: Date) -> Int {
        let left = end(of: lesson).timeIntervalSince(date)
        return max(Int(left.rounded(.up)), 0)
    }

    private static func end(of lesson: Lesson) -> Date {
        ScheduleCalendar.date(lesson.day, atMinutes: lesson.end)
    }
}
