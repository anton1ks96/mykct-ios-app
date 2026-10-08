//
//  ScheduleRepository.swift
//  college-ios-app
//

import Foundation

nonisolated struct WeekSchedule: Equatable, Sendable {
    let lessons: [Lesson]
    var isStale: Bool = false
    var fetchedAt: Date?
}

nonisolated protocol ScheduleRepositoryProtocol: Sendable {
    func weekSchedule(monday: Date, selection: Selection) async throws -> WeekSchedule
    func cachedWeek(monday: Date, selection: Selection) async -> WeekSchedule?
    func classDetails(id: String) async throws -> [DetailRow]
}

nonisolated final class ScheduleRepository: ScheduleRepositoryProtocol {

    private let api: ScheduleAPIProtocol
    private let cache: ScheduleCacheProtocol

    init(api: ScheduleAPIProtocol, cache: ScheduleCacheProtocol) {
        self.api = api
        self.cache = cache
    }

    func weekSchedule(monday: Date, selection: Selection) async throws -> WeekSchedule {
        let end = ScheduleCalendar.adding(days: 6, to: monday)
        let response = try await api.schedule(selection: selection, start: monday, end: end)
        let week = WeekSchedule(
            lessons: response.events.compactMap { $0.toLesson() },
            isStale: response.stale,
            fetchedAt: response.fetchedAt
        )
        await cache.save(week, monday: monday, selection: selection)
        return week
    }

    func cachedWeek(monday: Date, selection: Selection) async -> WeekSchedule? {
        await cache.week(monday: monday, selection: selection)
    }

    func classDetails(id: String) async throws -> [DetailRow] {
        try await api.classDetails(id: id).detailRows()
    }
}
