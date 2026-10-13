//
//  MockScheduleRepository.swift
//  college-ios-app
//

#if DEBUG
import Foundation

nonisolated final class MockScheduleRepository: ScheduleRepositoryProtocol {

    private let delay: Duration

    init(delay: Duration = .milliseconds(350)) {
        self.delay = delay
    }

    func weekSchedule(monday: Date, selection: Selection) async throws -> WeekSchedule {
        try? await Task.sleep(for: delay)
        return WeekSchedule(lessons: ScheduleMocks.week(monday: monday))
    }

    func cachedWeek(monday: Date, selection: Selection) async -> WeekSchedule? {
        nil
    }

    func classDetails(id: String) async throws -> [DetailRow] {
        try? await Task.sleep(for: delay)
        let subgroup = id.hasPrefix("mock-") ? String(id.dropFirst("mock-".count)) : nil
        return [
            DetailRow(key: "teacher", value: subgroup == nil ? "Иванов И. И." : "Петрова А. С."),
            DetailRow(key: "building", value: "Главный корпус"),
            DetailRow(key: "comment", value: subgroup.map { "Подгруппа \($0)" } ?? "Взять ноутбук"),
        ]
    }
}
#endif
