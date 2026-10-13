//
//  DayTitleRow.swift
//  CollegeWidget
//

import SwiftUI

struct DayTitleRow: View {
    @Environment(\.colors) private var colors

    let day: WidgetDay
    let now: Date

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(ScheduleFormat.dayTitle(day.date))
                .textStyle(AppType.titleMedium)
                .foregroundStyle(colors.onBackground)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 12)

            Text(detail)
                .textStyle(AppType.labelMedium)
                .foregroundStyle(colors.onSurfaceVariant)
                .lineLimit(1)
        }
        .accessibilityElement(children: .combine)
    }

    private var detail: String {
        let count = ScheduleFormat.lessonsCount(day.slots.count)
        let tomorrow = ScheduleCalendar.adding(days: 1, to: ScheduleCalendar.day(of: now))
        return day.date == tomorrow ? "Завтра · \(count)" : count
    }
}
