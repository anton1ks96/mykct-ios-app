//
//  WatchScheduleViewModel.swift
//  CollegeWatch
//

import Foundation
import Observation

@Observable
final class WatchScheduleViewModel {
    private(set) var snapshot: WidgetSnapshot?

    @ObservationIgnored private let store: WidgetSnapshotStore

    init(store: WidgetSnapshotStore) {
        self.store = store
        snapshot = store.load()
    }

    func reload() {
        let fresh = store.load()
        if fresh != snapshot {
            snapshot = fresh
        }
    }
}
