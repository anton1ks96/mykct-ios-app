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
        let week: String
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
        let key = Self.key(monday: monday, selection: selection)
        guard let entry = loaded()[key] else { return nil }
        return WeekSchedule(
            lessons: entry.lessons.map { Self.move($0, from: entry.monday, to: monday) },
            fetchedAt: entry.fetchedAt
        )
    }

    func save(_ week: WeekSchedule, monday: Date, selection: Selection) {
        let currentMonday = ScheduleCalendar.monday(of: ScheduleCalendar.day(of: .now))
        guard monday >= currentMonday else { return }

        let currentWeek = ScheduleParsing.requestString(from: currentMonday)
        var updated = loaded().filter { $0.value.week >= currentWeek }
        updated[Self.key(monday: monday, selection: selection)] = Entry(
            week: ScheduleParsing.requestString(from: monday),
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
            CrashlyticsLogger.logDataError(
                error,
                operation: "save_schedule_cache",
                dataType: "ScheduleCache"
            )
        }
    }

    private nonisolated static func move(
        _ lesson: Lesson,
        from old: Date,
        to monday: Date
    ) -> Lesson {
        let offset = Int((lesson.day.timeIntervalSince(old) / 86_400).rounded())
        return Lesson(
            id: lesson.id,
            day: ScheduleCalendar.adding(days: offset, to: monday),
            start: lesson.start,
            end: lesson.end,
            title: lesson.title,
            topic: lesson.topic,
            room: lesson.room,
            subgroups: lesson.subgroups
        )
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
