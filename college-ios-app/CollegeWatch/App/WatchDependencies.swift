//
//  WatchDependencies.swift
//  CollegeWatch
//

import Foundation

enum WatchDependencies {
    static let store = WidgetSnapshotStore()
    static let schedule = WatchScheduleViewModel(store: store)
}
