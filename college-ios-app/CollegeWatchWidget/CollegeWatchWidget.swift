//
//  CollegeWatchWidget.swift
//  CollegeWatchWidget
//

import SwiftUI
import WidgetKit

struct CollegeWatchWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: ScheduleWidgetKey.kind, provider: ScheduleProvider()) { entry in
            Text(entry.date, style: .time)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Расписание")
        .description("Текущая пара, аудитория и сколько осталось")
        .supportedFamilies([.accessoryRectangular])
    }
}
