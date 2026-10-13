//
//  ScheduleProvider.swift
//  CollegeWidget
//

import WidgetKit

nonisolated struct ScheduleProvider: TimelineProvider {

    private static let reloadSpread: TimeInterval = 60 * 60

    private let store = WidgetSnapshotStore()

    func placeholder(in context: Context) -> ScheduleEntry {
        WidgetSample.entry(at: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping @Sendable (ScheduleEntry) -> Void) {
        let now = Date.now
        guard !context.isPreview else {
            completion(WidgetSample.entry(at: now))
            return
        }
        completion(ScheduleEntry(date: now, content: WidgetSchedule.content(at: now, in: store.load())))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping @Sendable (Timeline<ScheduleEntry>) -> Void
    ) {
        Task {
            let now = Date.now
            await refreshWeeks(at: now)
            completion(timeline(at: now, snapshot: store.load()))
        }
    }

    private func refreshWeeks(at now: Date) async {
        guard let fetcher = WidgetScheduleFetcher.live, let snapshot = store.load() else { return }

        for monday in WidgetSchedule.weeksToRefresh(at: now, in: snapshot) {
            guard let lessons = try? await fetcher.week(monday: monday, selection: snapshot.selection)
            else { continue }
            try? store.save(
                lessons,
                monday: monday,
                selection: snapshot.selection,
                resetsSelection: false,
                at: now
            )
        }
    }

    private func timeline(at now: Date, snapshot: WidgetSnapshot?) -> Timeline<ScheduleEntry> {
        let entries = WidgetSchedule.entryDates(from: now, in: snapshot).map { date in
            ScheduleEntry(date: date, content: WidgetSchedule.content(at: date, in: snapshot))
        }
        guard let snapshot else { return Timeline(entries: entries, policy: .never) }

        let hasToday = snapshot.lessons(on: now) != nil
        var reload = WidgetSchedule.reloadDate(after: now, hasToday: hasToday)
        if hasToday {
            reload.addTimeInterval(.random(in: 0...Self.reloadSpread))
        }
        return Timeline(entries: entries, policy: .after(reload))
    }
}
