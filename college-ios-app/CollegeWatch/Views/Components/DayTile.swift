//
//  DayTile.swift
//  CollegeWatch
//

import SwiftUI

private let pastOpacity: Double = 0.55
private let dimmedFillOpacity: Double = 0.18

struct DayTile: View {
    @Environment(\.colors) private var colors
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    let day: WidgetDay
    let today: Date
    let onTap: () -> Void

    private var isToday: Bool { day.date == today }
    private var isPast: Bool { day.date < today }
    private var isEmpty: Bool { day.slots.isEmpty }
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Metrics.rowRadius, style: .continuous)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text(title)
                    .textStyle(AppType.bodyLarge)
                    .fontWeight(.semibold)
                    .foregroundStyle(isEmpty && !isToday ? colors.onSurfaceVariant : colors.onSurface)

                Spacer(minLength: 4)

                Text(detail)
                    .textStyle(AppType.labelMedium)
                    .foregroundStyle(isToday ? colors.onSurface : colors.onSurfaceVariant)
            }
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background { background }
        }
        .buttonStyle(.plain)
        .disabled(isEmpty)
        .opacity(isPast ? pastOpacity : 1)
        .accessibilityElement(children: .combine)
    }

    private var title: String {
        guard !isToday else { return "Сегодня" }
        let number = ScheduleCalendar.calendar.component(.day, from: day.date)
        return "\(ScheduleFormat.weekdayShort(day.date)) \(number)"
    }

    private var detail: String {
        isEmpty ? "Пар нет" : ScheduleFormat.lessonsCount(day.slots.count)
    }

    @ViewBuilder
    private var background: some View {
        if !isToday {
            shape.fill(colors.surfaceVariant)
        } else if isLuminanceReduced {
            shape
                .fill(colors.primary.opacity(dimmedFillOpacity))
                .overlay(shape.strokeBorder(colors.accentText, lineWidth: 1))
        } else {
            shape.fill(accentGradient)
        }
    }
}
