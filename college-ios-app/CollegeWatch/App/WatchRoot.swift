//
//  WatchRoot.swift
//  CollegeWatch
//

import SwiftUI

private enum WatchRoute: Hashable {
    case week
    case day(Date)
}

struct WatchRoot: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var path: [WatchRoute] = []

    let schedule: WatchScheduleViewModel

    var body: some View {
        NavigationStack(path: $path) {
            TimelineView(.everyMinute) { context in
                TodayScreen(
                    snapshot: schedule.snapshot,
                    now: context.date,
                    onWeek: { path.append(.week) },
                    onDay: open
                )
            }
            .navigationDestination(for: WatchRoute.self) { route in
                TimelineView(.everyMinute) { context in
                    destination(route, now: context.date)
                }
            }
        }
        .watchTheme()
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active {
                schedule.reload()
            }
        }
    }

    @ViewBuilder
    private func destination(_ route: WatchRoute, now: Date) -> some View {
        switch route {
        case .week:
            WeekScreen(snapshot: schedule.snapshot, now: now, onDay: open)
        case .day(let date):
            DayScreen(date: date, snapshot: schedule.snapshot, now: now)
        }
    }

    private func open(_ day: Date) {
        if day == ScheduleCalendar.day(of: .now) {
            path = []
        } else {
            path.append(.day(day))
        }
    }
}
