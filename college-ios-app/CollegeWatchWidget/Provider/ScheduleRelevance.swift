//
//  ScheduleRelevance.swift
//  CollegeWatchWidget
//

import Foundation
import RelevanceKit
import WidgetKit

nonisolated extension ScheduleProvider {

    func relevance() async -> WidgetRelevance<Void> {
        let snapshot = WidgetSnapshotStore().load()
        let attributes = WidgetSchedule.relevantIntervals(from: .now, in: snapshot).map { interval in
            WidgetRelevanceAttribute<Void>(context: .date(interval: interval, kind: .scheduled))
        }
        return WidgetRelevance(attributes)
    }
}
