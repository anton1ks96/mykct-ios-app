//
//  ScheduleCache.swift
//  college-ios-app
//

import Foundation

nonisolated protocol ScheduleCacheProtocol: Sendable {
    func week(monday: Date, selection: Selection) async -> WeekSchedule?
    func save(_ week: WeekSchedule, monday: Date, selection: Selection) async
}

actor ScheduleCache: ScheduleCacheProtocol {

    nonisolated static let defaultURL = URL.applicationSupportDirectory
        .appending(path: "schedule-cache.json")

    private nonisolated struct Entry: Codable, Sendable {
        let monday: Date
        let lessons: [Lesson]
        let fetchedAt: Date?
    }

    private let fileURL: URL
    private var entries: [String: Entry]?

    init(fileURL: URL = ScheduleCache.defaultURL) {
        self.fileURL = fileURL
    }

    func week(monday: Date, selection: Selection) -> WeekSchedule? {
        guard let entry = loaded()[Self.key(monday: monday, selection: selection)] else { return nil }
        return WeekSchedule(lessons: entry.lessons, fetchedAt: entry.fetchedAt)
    }

    func save(_ week: WeekSchedule, monday: Date, selection: Selection) {
        let currentMonday = ScheduleCalendar.monday(of: ScheduleCalendar.day(of: .now))
        guard monday >= currentMonday else { return }

        var updated = loaded().filter { $0.value.monday >= currentMonday }
        updated[Self.key(monday: monday, selection: selection)] = Entry(
            monday: monday,
            lessons: week.lessons,
            fetchedAt: week.fetchedAt ?? .now
        )
        entries = updated
        persist(updated)
    }

    // MARK: - Storage

    private func loaded() -> [String: Entry] {
        if let entries { return entries }
        let decoded = (try? Data(contentsOf: fileURL))
            .flatMap { try? JSONDecoder().decode([String: Entry].self, from: $0) } ?? [:]
        entries = decoded
        return decoded
    }

    private func persist(_ entries: [String: Entry]) {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try JSONEncoder().encode(entries).write(to: fileURL, options: .atomic)
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            var url = fileURL
            try url.setResourceValues(values)
        } catch {
            CrashlyticsLogger.logDataError(error, operation: "save_schedule_cache", dataType: "ScheduleCache")
        }
    }

    private nonisolated static func key(monday: Date, selection: Selection) -> String {
        [
            selection.group,
            selection.subgroup ?? "",
            selection.englishGroup ?? "",
            selection.profileSubgroup ?? "",
            ScheduleParsing.requestString(from: monday),
        ].joined(separator: "|")
    }
}
