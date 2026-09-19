//
//  LessonProgressTests.swift
//  college-ios-appTests
//

import Foundation
import Testing
@testable import college_ios_app

private let day = ScheduleParsing.date(from: "2026-08-31")!

private let lesson = Lesson(
    id: "1",
    day: day,
    start: 9 * 60,
    end: 10 * 60 + 30,
    title: "Математика"
)

private func time(_ minutes: Int, seconds: Int = 0) -> Date {
    ScheduleCalendar.date(day, atMinutes: minutes).addingTimeInterval(TimeInterval(seconds))
}

@Suite("Ход пары")
struct LessonProgressTests {

    @Test("Остаток считается по секундам и не уходит в минус")
    func secondsLeft() {
        #expect(LessonProgress.secondsLeft(of: lesson, at: time(9 * 60)) == 90 * 60)
        #expect(LessonProgress.secondsLeft(of: lesson, at: time(10 * 60, seconds: 30)) == 29 * 60 + 30)
        #expect(LessonProgress.secondsLeft(of: lesson, at: time(10 * 60 + 30)) == 0)
        #expect(LessonProgress.secondsLeft(of: lesson, at: time(11 * 60)) == 0)
    }

    @Test("Остаток показывается минутами, в конце - секундами")
    func remainingText() {
        #expect(ScheduleFormat.remaining(seconds: 90 * 60) == "90 мин")
        #expect(ScheduleFormat.remaining(seconds: 61) == "1 мин")
        #expect(ScheduleFormat.remaining(seconds: 59) == "59 с")
        #expect(ScheduleFormat.remaining(seconds: -5) == "0 с")
    }
}
