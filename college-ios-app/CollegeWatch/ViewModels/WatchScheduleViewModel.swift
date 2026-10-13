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
    @ObservationIgnored private let fetcher: WidgetScheduleFetcher?
    @ObservationIgnored private let onSave: @Sendable () -> Void
    @ObservationIgnored private var refreshTask: Task<Void, Never>?

    init(
        store: WidgetSnapshotStore,
        fetcher: WidgetScheduleFetcher? = nil,
        onSave: @escaping @Sendable () -> Void = {}
    ) {
        self.store = store
        self.fetcher = fetcher
        self.onSave = onSave
        snapshot = store.load()
    }

    func reload() {
        let fresh = store.load()
        if fresh != snapshot {
            snapshot = fresh
        }
    }

    func refresh() {
        guard let fetcher else { return }

        refreshTask?.cancel()
        refreshTask = Task {
            if await store.refresh(fetch: fetcher.week) {
                onSave()
            }
            reload()
        }
    }
}
