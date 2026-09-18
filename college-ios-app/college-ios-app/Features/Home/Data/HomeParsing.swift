//
//  HomeParsing.swift
//  college-ios-app
//

import Foundation

nonisolated enum HomeParsing {

    static func records(from dtos: [AttendanceDTO]) -> [AttendanceRecord] {
        dtos
            .compactMap(record(from:))
            .sorted { left, right in
                left.date == right.date
                    ? (left.start ?? 0) < (right.start ?? 0)
                    : left.date < right.date
            }
    }

    static func record(from dto: AttendanceDTO) -> AttendanceRecord? {
        guard let date = ScheduleParsing.date(from: dto.day) else { return nil }

        return AttendanceRecord(
            id: dto.clID.isEmpty ? "\(dto.day)-\(dto.start)-\(dto.title)" : dto.clID,
            date: date,
            start: ScheduleParsing.minutes(from: dto.start),
            end: ScheduleParsing.minutes(from: dto.end),
            title: dto.title,
            topic: dto.topic,
            room: ScheduleParsing.room(dto.room),
            attendance: Attendance.of(status: dto.status)
        )
    }

    static func marks(from records: [AttendanceRecord]) -> [Date: DayMark] {
        Dictionary(grouping: records, by: \.date).mapValues(DayMark.of)
    }

    static func streak(from dto: StreakDTO) -> Streak {
        Streak(
            current: dto.current,
            longest: dto.longest,
            daysAttended: dto.daysAttended,
            schoolDays: dto.schoolDays,
            lastAttended: date(from: dto.lastAttended),
            periodStart: date(from: dto.periodStart),
            periodEnd: date(from: dto.periodEnd)
        )
    }

    static func subjects(from dtos: [SubjectDTO]) -> [Subject] {
        dtos
            .filter { !$0.suID.isEmpty }
            .map { Subject(id: $0.suID, title: $0.title) }
    }

    static func lessons(from response: ScoresResponse) -> [SubjectLesson] {
        guard let subject = response.subjects.sorted(by: { $0.key < $1.key }).first else { return [] }

        return subject.value
            .sorted { $0.key < $1.key }
            .map { title, scores in
                SubjectLesson(
                    title: title,
                    scores: scores.enumerated().map { index, dto in
                        Score(
                            id: "\(title)#\(index)",
                            date: date(from: dto.dateF.isEmpty ? dto.dateP : dto.dateF),
                            value: Int(dto.score.trimmingCharacters(in: .whitespaces)),
                            max: dto.max,
                            details: dto.details
                        )
                    }
                )
            }
    }

    static func date(from value: String) -> Date? {
        guard value.count >= 10 else { return nil }
        return ScheduleParsing.date(from: String(value.prefix(10)))
    }
}
