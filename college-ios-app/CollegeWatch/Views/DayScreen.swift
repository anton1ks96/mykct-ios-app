//
//  DayScreen.swift
//  CollegeWatch
//

import SwiftUI

struct DayScreen: View {
    @Environment(\.colors) private var colors

    let date: Date
    let snapshot: WidgetSnapshot?
    let now: Date

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .scenePadding(.horizontal)
        }
        .navigationTitle(ScheduleFormat.dayShort(date))
    }

    @ViewBuilder
    private var content: some View {
        if let day = WidgetSchedule.day(date, in: snapshot) {
            if let first = day.slots.first, let last = day.slots.last {
                Text(summary(of: day, from: first, to: last))
                    .textStyle(AppType.labelMedium)
                    .foregroundStyle(colors.onSurfaceVariant)
                    .lineLimit(1)
                    .padding(.leading, 4)

                ForEach(day.slots.indices, id: \.self) { index in
                    LessonTile(slot: day.slots[index], isPast: day.slots[index].endDate <= now)
                }
            } else {
                RestHeader(caption: ScheduleFormat.dayTitle(date), lessonCount: 0)
            }
        } else {
            WatchMessage.unavailable
        }
    }

    private func summary(of day: WidgetDay, from first: WidgetSlot, to last: WidgetSlot) -> String {
        let count = ScheduleFormat.lessonsCount(day.slots.count)
        return "\(count) · \(ScheduleFormat.time(first.start)) – \(ScheduleFormat.time(last.end))"
    }
}

#if DEBUG
#Preview("Четверг") {
    NavigationStack {
        DayScreen(date: WatchMocks.at(3, 0), snapshot: WatchMocks.snapshot, now: WatchMocks.at(1, 11))
    }
    .watchTheme()
}

#Preview("Свободный день") {
    NavigationStack {
        DayScreen(date: WatchMocks.at(2, 0), snapshot: WatchMocks.snapshot, now: WatchMocks.at(1, 11))
    }
    .watchTheme()
}
#endif
