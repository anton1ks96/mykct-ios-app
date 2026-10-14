//
//  CollegeWatchWidget.swift
//  CollegeWatchWidget
//

import SwiftUI
import WidgetKit

struct CollegeWatchWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: ScheduleWidgetKey.kind, provider: ScheduleProvider()) { entry in
            ComplicationLayout(entry: entry)
        }
        .configurationDisplayName("Расписание")
        .description("Текущая пара, аудитория и сколько осталось")
        .supportedFamilies([.accessoryInline, .accessoryRectangular, .accessoryCircular])
    }
}

#if DEBUG
private enum PreviewTimeline {
    static let monday = ScheduleCalendar.monday(of: .now)
    static let snapshot = ScheduleMocks.widgetSnapshot(monday: monday)

    static func entry(_ dayOffset: Int, _ hour: Int, _ minute: Int = 0) -> ScheduleEntry {
        let date = ScheduleCalendar.date(
            ScheduleCalendar.adding(days: dayOffset, to: monday),
            atMinutes: hour * 60 + minute
        )
        return ScheduleEntry(date: date, content: WidgetSchedule.content(at: date, in: snapshot))
    }

    static let setup = ScheduleEntry(date: .now, content: .setup)
    static let unavailable = ScheduleEntry(date: .now, content: .unavailable)
}

#Preview(as: .accessoryRectangular) {
    CollegeWatchWidget()
} timeline: {
    PreviewTimeline.entry(1, 10, 58)
    PreviewTimeline.entry(1, 12, 22)
    PreviewTimeline.entry(1, 19, 40)
    PreviewTimeline.entry(2, 12)
    PreviewTimeline.setup
    PreviewTimeline.unavailable
}

#Preview(as: .accessoryCircular) {
    CollegeWatchWidget()
} timeline: {
    PreviewTimeline.entry(1, 10, 58)
    PreviewTimeline.entry(1, 12, 22)
    PreviewTimeline.entry(1, 19, 40)
    PreviewTimeline.setup
}

#Preview(as: .accessoryInline) {
    CollegeWatchWidget()
} timeline: {
    PreviewTimeline.entry(1, 10, 58)
    PreviewTimeline.entry(1, 12, 22)
    PreviewTimeline.entry(1, 7, 30)
    PreviewTimeline.entry(1, 19, 40)
    PreviewTimeline.setup
}
#endif
