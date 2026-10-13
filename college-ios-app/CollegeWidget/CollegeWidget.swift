//
//  CollegeWidget.swift
//  CollegeWidget
//
//  Created by pc on 12.10.2026.
//

import WidgetKit
import SwiftUI

struct CollegeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: ScheduleWidgetKey.kind, provider: ScheduleProvider()) { entry in
            ScheduleWidgetLayout(entry: entry)
        }
        .configurationDisplayName("Расписание")
        .description("Текущая пара, аудитория и сколько осталось")
        .supportedFamilies([.systemSmall])
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

#Preview(as: .systemSmall) {
    CollegeWidget()
} timeline: {
    PreviewTimeline.entry(0, 10, 5)
    PreviewTimeline.entry(0, 8, 30)
    PreviewTimeline.entry(0, 10, 32)
    PreviewTimeline.entry(0, 12, 50)
    PreviewTimeline.entry(0, 16)
    PreviewTimeline.entry(1, 15)
    PreviewTimeline.entry(2, 12)
    PreviewTimeline.entry(4, 18)
    PreviewTimeline.setup
    PreviewTimeline.unavailable
}
#endif
