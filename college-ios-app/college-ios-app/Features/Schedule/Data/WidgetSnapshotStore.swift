//
//  WidgetSnapshotStore.swift
//  college-ios-app
//

import Foundation

nonisolated struct WidgetSnapshotStore: Sendable {

    private let suiteName: String?

    init(suiteName: String? = ScheduleWidgetKey.appGroup) {
        self.suiteName = suiteName
    }

    private var defaults: UserDefaults? {
        suiteName.flatMap(UserDefaults.init(suiteName:))
    }

    func load() -> WidgetSnapshot? {
        guard let data = defaults?.data(forKey: ScheduleWidgetKey.snapshot) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }

    @discardableResult
    func adopt(_ selection: Selection) throws -> Bool {
        guard let defaults, load()?.selection != selection else { return false }

        let snapshot = WidgetSnapshot(selection: selection, weeks: [:])
        defaults.set(try JSONEncoder().encode(snapshot), forKey: ScheduleWidgetKey.snapshot)
        return true
    }

    @discardableResult
    func save(
        _ lessons: [Lesson],
        monday: Date,
        selection: Selection,
        resetsSelection: Bool = true,
        at now: Date = .now
    ) throws -> Bool {
        guard let defaults,
              let snapshot = WidgetSnapshot.merging(
                load(),
                lessons: lessons,
                monday: monday,
                selection: selection,
                resetsSelection: resetsSelection,
                at: now
              )
        else { return false }

        defaults.set(try JSONEncoder().encode(snapshot), forKey: ScheduleWidgetKey.snapshot)
        return true
    }
}
