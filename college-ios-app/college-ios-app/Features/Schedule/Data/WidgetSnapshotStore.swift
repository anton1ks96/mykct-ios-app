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

    func data() -> Data? {
        defaults?.data(forKey: ScheduleWidgetKey.snapshot)
    }

    func load() -> WidgetSnapshot? {
        guard let data = data() else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }

    @discardableResult
    func receive(_ data: Data, at now: Date = .now) throws -> Bool {
        let incoming = try JSONDecoder().decode(WidgetSnapshot.self, from: data)
        let local = load()
        let snapshot = WidgetSnapshot.combining(incoming, with: local, at: now)
        guard let defaults, snapshot != local else { return false }

        defaults.set(try JSONEncoder().encode(snapshot), forKey: ScheduleWidgetKey.snapshot)
        return true
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

    @discardableResult
    func refresh(
        at now: Date = .now,
        fetch: (Date, Selection) async throws -> [Lesson]
    ) async -> Bool {
        guard let snapshot = load() else { return false }

        var saved = false
        for monday in WidgetSchedule.weeksToRefresh(at: now, in: snapshot) {
            guard let lessons = try? await fetch(monday, snapshot.selection) else { continue }
            let didSave = try? save(
                lessons,
                monday: monday,
                selection: snapshot.selection,
                resetsSelection: false,
                at: now
            )
            saved = didSave == true || saved
        }
        return saved
    }
}
