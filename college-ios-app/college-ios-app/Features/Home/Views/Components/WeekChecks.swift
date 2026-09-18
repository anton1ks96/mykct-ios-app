//
//  WeekChecks.swift
//  college-ios-app
//

import SwiftUI

private let checkSide: CGFloat = 36

struct WeekChecks: View {
    @Environment(\.colors) private var colors

    let weekStart: Date
    let records: [AttendanceRecord]

    private var attended: Set<Date> {
        Set(records.filter { $0.attendance == .present }.map(\.date))
    }

    var body: some View {
        GlassGroup(spacing: 8) {
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { offset in
                    column(ScheduleCalendar.adding(days: offset, to: weekStart))
                }
            }
        }
    }

    private func column(_ date: Date) -> some View {
        let today = ScheduleCalendar.day(of: .now)
        let isToday = date == today
        let wasHere = attended.contains(date)

        return VStack(spacing: 8) {
            Text(ScheduleFormat.weekdayShort(date))
                .textStyle(AppType.labelMedium)
                .foregroundStyle(isToday ? colors.primary : colors.onSurfaceVariant)
                .fontWeight(isToday ? .bold : .regular)

            check(date, wasHere: wasHere, isToday: isToday, isFuture: date > today)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityValue(wasHere ? "Был" : "Отметок нет")
    }

    @ViewBuilder
    private func check(_ date: Date, wasHere: Bool, isToday: Bool, isFuture: Bool) -> some View {
        if wasHere {
            Image(systemName: "checkmark")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(colors.onTertiary)
                .frame(width: checkSide, height: checkSide)
                .glassSurface(Circle(), tint: colors.primary)
        } else {
            Text(date, format: .dateTime.day())
                .textStyle(AppType.bodyMedium)
                .foregroundStyle(isFuture ? colors.onSurfaceVariant : colors.onSurface)
                .fontWeight(isToday ? .bold : .regular)
                .frame(width: checkSide, height: checkSide)
        }
    }
}

#Preview {
    let monday = ScheduleCalendar.monday(of: .now)

    return WeekChecks(weekStart: monday, records: HomeMocks.records(month: .now))
        .padding(20)
        .appBackground()
        .environment(\.colors, .dark)
}
