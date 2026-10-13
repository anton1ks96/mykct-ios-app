//
//  WatchDependencies.swift
//  CollegeWatch
//

import Foundation
import WidgetKit

enum WatchDependencies {
    static let store = WidgetSnapshotStore()

    static let reloadComplications: @Sendable () -> Void = {
        Task { @MainActor in
            WidgetCenter.shared.reloadTimelines(ofKind: ScheduleWidgetKey.kind)
        }
    }

    static let schedule = WatchScheduleViewModel(
        store: store,
        fetcher: .live,
        onSave: reloadComplications
    )

    static let receiver: WatchSnapshotReceiver = {
        let model = schedule
        let reload = reloadComplications
        return WatchSnapshotReceiver(store: store) {
            reload()
            Task { @MainActor in
                model.reload()
            }
        }
    }()
}
