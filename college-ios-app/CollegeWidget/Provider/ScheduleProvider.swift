//
//  ScheduleProvider.swift
//  CollegeWidget
//

import WidgetKit

nonisolated struct ScheduleProvider: TimelineProvider {

    private let store = WidgetSnapshotStore()

    func placeholder(in context: Context) -> ScheduleEntry {
        WidgetSample.entry(at: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> Void) {
        let now = Date.now
        guard !context.isPreview else {
            completion(WidgetSample.entry(at: now))
            return
        }
        completion(ScheduleEntry(date: now, content: WidgetSchedule.content(at: now, in: store.load())))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<ScheduleEntry>) -> Void
    ) {
        completion(timeline(at: .now, snapshot: store.load()))
    }

    private func timeline(at now: Date, snapshot: WidgetSnapshot?) -> Timeline<ScheduleEntry> {
        let entries = WidgetSchedule.entryDates(from: now, in: snapshot).map { date in
            ScheduleEntry(date: date, content: WidgetSchedule.content(at: date, in: snapshot))
        }
        guard let snapshot else { return Timeline(entries: entries, policy: .never) }

        let reload = WidgetSchedule.reloadDate(
            after: now,
            hasToday: snapshot.lessons(on: now) != nil
        )
        return Timeline(entries: entries, policy: .after(reload))
    }
}
