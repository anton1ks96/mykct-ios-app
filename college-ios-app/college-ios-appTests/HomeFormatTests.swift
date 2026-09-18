//
//  HomeFormatTests.swift
//  college-ios-appTests
//

import Testing
import Foundation
@testable import college_ios_app

private func record(_ attendance: Attendance) -> AttendanceRecord {
    AttendanceRecord(
        id: UUID().uuidString,
        date: ScheduleParsing.date(from: "2026-08-24")!,
        start: 540,
        end: 630,
        title: "Математика",
        topic: "",
        room: "210",
        attendance: attendance
    )
}

private func date(_ value: String) -> Date {
    ScheduleParsing.date(from: value)!
}

@Suite("Русские склонения")
struct PluralTests {

    @Test("Дни склоняются по последней цифре, кроме 11-14")
    func days() {
        #expect(ScheduleFormat.daysCount(0) == "0 дней")
        #expect(ScheduleFormat.daysCount(1) == "1 день")
        #expect(ScheduleFormat.daysCount(2) == "2 дня")
        #expect(ScheduleFormat.daysCount(4) == "4 дня")
        #expect(ScheduleFormat.daysCount(5) == "5 дней")
        #expect(ScheduleFormat.daysCount(11) == "11 дней")
        #expect(ScheduleFormat.daysCount(14) == "14 дней")
        #expect(ScheduleFormat.daysCount(21) == "21 день")
        #expect(ScheduleFormat.daysCount(22) == "22 дня")
        #expect(ScheduleFormat.daysCount(111) == "111 дней")
    }

    @Test("Предметы и оценки склоняются по тому же правилу")
    func subjectsAndScores() {
        #expect(ScheduleFormat.subjectsCount(1) == "1 предмет")
        #expect(ScheduleFormat.subjectsCount(3) == "3 предмета")
        #expect(ScheduleFormat.subjectsCount(12) == "12 предметов")
        #expect(ScheduleFormat.scoresCount(1) == "1 оценка")
        #expect(ScheduleFormat.scoresCount(4) == "4 оценки")
        #expect(ScheduleFormat.scoresCount(11) == "11 оценок")
    }

    @Test("Счёт пар не изменился после общего правила")
    func lessons() {
        #expect(ScheduleFormat.lessonsCount(1) == "1 пара")
        #expect(ScheduleFormat.lessonsCount(4) == "4 пары")
        #expect(ScheduleFormat.lessonsCount(11) == "11 пар")
    }
}

@Suite("Статистика посещаемости")
struct AttendanceStatsTests {

    @Test("Записи считаются по статусам")
    func counts() {
        let records = [record(.present), record(.present), record(.excused), record(.absent), record(.unknown)]
        let stats = AttendanceStats.of(records)

        #expect(stats.total == 4)
        #expect(stats.present == 2)
        #expect(stats.excused == 1)
        #expect(stats.absent == 1)
    }

    @Test("Процент считается от общего числа пар")
    func percent() {
        let records = Array(repeating: record(.present), count: 12) + Array(repeating: record(.absent), count: 4)
        #expect(AttendanceStats.of(records).percent == 75)
    }

    @Test("Пустая неделя не делит на ноль")
    func emptyWeek() {
        #expect(AttendanceStats.empty.percent == 0)
        #expect(AttendanceStats.of([]).percent == 0)
    }

    @Test("Будущие пары не тянут процент вниз")
    func futureLessons() {
        let records = Array(repeating: record(.present), count: 3)
            + Array(repeating: record(.unknown), count: 17)
        let stats = AttendanceStats.of(records)

        #expect(stats.total == 3)
        #expect(stats.percent == 100)
    }

    @Test("Статусы приходят числами")
    func statuses() {
        #expect(Attendance.of(status: 2) == .present)
        #expect(Attendance.of(status: 1) == .excused)
        #expect(Attendance.of(status: 0) == .absent)
        #expect(Attendance.of(status: 7) == .unknown)
        #expect(Attendance.of(status: -1) == .unknown)
    }
}

@Suite("Границы полугодия")
struct HomeSemesterTests {

    @Test("Первое полугодие - с января по июнь")
    func firstHalf() {
        for month in ["2026-01-15", "2026-06-30"] {
            let bounds = HomeSemester.bounds(for: date(month))
            #expect(ScheduleParsing.requestString(from: bounds.start) == "2026-01-01")
            #expect(ScheduleParsing.requestString(from: bounds.end) == "2026-06-30")
        }
    }

    @Test("Лето относится ко второму полугодию")
    func secondHalf() {
        for month in ["2026-07-01", "2026-08-29", "2026-09-01", "2026-12-31"] {
            let bounds = HomeSemester.bounds(for: date(month))
            #expect(ScheduleParsing.requestString(from: bounds.start) == "2026-09-01")
            #expect(ScheduleParsing.requestString(from: bounds.end) == "2026-12-31")
        }
    }
}

@Suite("Штрихи кольца")
struct RingScaleTests {

    @Test("Пустая статистика не даёт ни одного штриха")
    func empty() {
        #expect(RingScale.bounds(for: .empty) == RingScale.Bounds(present: 0, excused: 0, absent: 0))
    }

    @Test("Границы считаются нарастающим итогом")
    func cumulative() {
        let stats = AttendanceStats(total: 16, present: 12, absent: 2, excused: 2)
        #expect(RingScale.bounds(for: stats) == RingScale.Bounds(present: 36, excused: 42, absent: 48))
    }

    @Test("Неизвестные отметки оставляют хвост в треке")
    func withUnknown() {
        let stats = AttendanceStats(total: 8, present: 4, absent: 1, excused: 1)
        let bounds = RingScale.bounds(for: stats)

        #expect(bounds.present <= bounds.excused)
        #expect(bounds.excused <= bounds.absent)
        #expect(bounds.absent < RingScale.tickCount)
    }
}

@Suite("Стрик")
struct StreakTests {

    private func streak(daysAttended: Int, schoolDays: Int) -> Streak {
        Streak(
            current: 5,
            longest: 9,
            daysAttended: daysAttended,
            schoolDays: schoolDays,
            lastAttended: nil,
            periodStart: nil,
            periodEnd: nil
        )
    }

    @Test("Процент посещений считается на клиенте")
    func rate() {
        #expect(Int(streak(daysAttended: 40, schoolDays: 45).rate) == 88)
        #expect(streak(daysAttended: 0, schoolDays: 0).rate == 0)
    }

    @Test("Фраза о посещаемости меняется на границах")
    func status() {
        #expect(HomeFormat.status(rate: 90) == "Ходишь почти без пропусков — так держать")
        #expect(HomeFormat.status(rate: 89.9) == "Крепкая посещаемость, всё под контролем")
        #expect(HomeFormat.status(rate: 75) == "Крепкая посещаемость, всё под контролем")
        #expect(HomeFormat.status(rate: 74.9) == "Бывает по-разному — можно лучше")
        #expect(HomeFormat.status(rate: 50) == "Бывает по-разному — можно лучше")
        #expect(HomeFormat.status(rate: 49.9) == "Пропусков много, пора возвращаться")
    }

    @Test("Прерванный стрик пишется словами")
    func daysInRow() {
        #expect(HomeFormat.daysInRow(0) == "Стрик прервался")
        #expect(HomeFormat.daysInRow(1) == "1 день подряд")
        #expect(HomeFormat.daysInRow(22) == "22 дня подряд")
    }
}
