//
//  HomeState.swift
//  college-ios-app
//

import Foundation

nonisolated enum HomeTab: String, CaseIterable, Identifiable, Sendable {
    case attendance
    case performance

    var id: String { rawValue }

    var title: String {
        switch self {
        case .attendance: "Посещаемость"
        case .performance: "Успеваемость"
        }
    }
}

nonisolated enum StreakTab: String, CaseIterable, Identifiable, Sendable {
    case streak
    case leaderboard

    var id: String { rawValue }

    var title: String {
        switch self {
        case .streak: "Стрик"
        case .leaderboard: "Рейтинг"
        }
    }
}

nonisolated enum HomeGate: Equatable, Sendable {
    case loading
    case invite
    case content
}

nonisolated struct SubjectScores: Equatable, Sendable {
    let subject: Subject
    var lessons: [SubjectLesson] = []
    var isLoading: Bool = true
    var error: String?

    var graded: [Int] {
        lessons.flatMap(\.scores).compactMap(\.value)
    }

    var average: Double? {
        let graded = graded
        guard !graded.isEmpty else { return nil }
        return Double(graded.reduce(0, +)) / Double(graded.count)
    }
}

nonisolated enum LeaderboardFeed: Equatable, Sendable {
    case idle
    case loading
    case loaded(Leaderboard)
    case unavailable
    case failed(String)

    var board: Leaderboard? {
        guard case let .loaded(board) = self else { return nil }
        return board
    }

    var message: String? {
        guard case let .failed(message) = self else { return nil }
        return message
    }
}

nonisolated struct HomeState: Equatable, Sendable {
    var user: User?
    var isBootstrapping: Bool = true
    var month: Date
    var selected: Date
    var records: [AttendanceRecord] = []
    var marks: [Date: DayMark] = [:]
    var stats: AttendanceStats = .empty
    var motivation: String?
    var streak: Streak?
    var leaderboard: LeaderboardFeed = .idle
    var subjects: [Subject] = []
    var isLoading: Bool = false
    var error: String?
    var scores: SubjectScores?

    var isAuthenticated: Bool { user != nil }

    var canSeeLeaderboard: Bool {
        user?.role == "student" && user?.academicGroup?.isEmpty == false
    }

    var weekStart: Date { ScheduleCalendar.monday(of: .now) }

    var selectedDay: AttendanceDay {
        AttendanceDay(date: selected, records: records.filter { $0.date == selected })
    }

    var gate: HomeGate {
        if isBootstrapping { return .loading }
        return isAuthenticated ? .content : .invite
    }
}

nonisolated struct HomeSession: Equatable, Sendable {
    let user: User?
    let isBootstrapping: Bool
}
