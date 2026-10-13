//
//  WidgetSyncRepository.swift
//  college-ios-app
//

import Foundation
import WidgetKit

nonisolated final class WidgetSyncRepository: ScheduleRepositoryProtocol {

    static let reloadWidget: @Sendable () -> Void = {
        Task { @MainActor in
            WidgetCenter.shared.reloadTimelines(ofKind: ScheduleWidgetKey.kind)
        }
    }

    private let base: ScheduleRepositoryProtocol
    private let store: WidgetSnapshotStore
    private let onChange: @Sendable () -> Void

    init(
        base: ScheduleRepositoryProtocol,
        store: WidgetSnapshotStore = WidgetSnapshotStore(),
        onChange: @escaping @Sendable () -> Void = WidgetSyncRepository.reloadWidget
    ) {
        self.base = base
        self.store = store
        self.onChange = onChange
    }

    func weekSchedule(monday: Date, selection: Selection) async throws -> WeekSchedule {
        let week = try await base.weekSchedule(monday: monday, selection: selection)
        do {
            if try store.save(week.lessons, monday: monday, selection: selection) {
                onChange()
            }
        } catch {
            CrashlyticsLogger.logDataError(
                error,
                operation: "save_widget_snapshot",
                dataType: "WidgetSnapshot"
            )
        }
        return week
    }

    func cachedWeek(monday: Date, selection: Selection) async -> WeekSchedule? {
        await base.cachedWeek(monday: monday, selection: selection)
    }

    func classDetails(id: String) async throws -> [DetailRow] {
        try await base.classDetails(id: id)
    }
}
