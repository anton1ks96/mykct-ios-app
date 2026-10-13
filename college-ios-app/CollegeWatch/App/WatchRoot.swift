//
//  WatchRoot.swift
//  CollegeWatch
//

import SwiftUI

struct WatchRoot: View {
    @Environment(\.scenePhase) private var scenePhase

    let schedule: WatchScheduleViewModel

    var body: some View {
        NavigationStack {
            TimelineView(.everyMinute) { context in
                TodayScreen(snapshot: schedule.snapshot, now: context.date)
            }
        }
        .watchTheme()
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active {
                schedule.reload()
            }
        }
    }
}
