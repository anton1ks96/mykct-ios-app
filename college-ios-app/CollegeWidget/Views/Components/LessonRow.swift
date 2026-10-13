//
//  LessonRow.swift
//  CollegeWidget
//

import SwiftUI

private let timeColumnWidth: CGFloat = 44
private let rowHeight: CGFloat = 40
private let pastOpacity: Double = 0.55

struct LessonRow: View {
    @Environment(\.colors) private var colors

    let slot: WidgetSlot
    let isPast: Bool

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 0) {
                Text(ScheduleFormat.time(slot.start))
                    .textStyle(AppType.labelLarge)
                    .fontWeight(.bold)
                    .foregroundStyle(colors.accentText)
                Text(ScheduleFormat.time(slot.end))
                    .textStyle(AppType.labelSmall)
                    .foregroundStyle(colors.onSurfaceVariant)
            }
            .monospacedDigit()
            .frame(width: timeColumnWidth, alignment: .leading)

            VStack(alignment: .leading, spacing: 1) {
                Text(slot.title)
                    .textStyle(AppType.bodyLarge)
                    .fontWeight(.semibold)
                    .foregroundStyle(colors.onBackground)
                if let meta {
                    Text(meta)
                        .textStyle(AppType.bodySmall)
                        .foregroundStyle(colors.onSurfaceVariant)
                }
            }
            .lineLimit(1)
            .layoutPriority(1)

            Spacer(minLength: 8)

            if !slot.room.isEmpty {
                HStack(spacing: 3) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(colors.onSurfaceVariant)
                    Text(slot.room)
                        .textStyle(AppType.labelLarge)
                        .foregroundStyle(colors.onBackground)
                }
                .lineLimit(1)
                .layoutPriority(2)
            }
        }
        .frame(height: rowHeight)
        .opacity(isPast ? pastOpacity : 1)
        .accessibilityElement(children: .combine)
    }

    private var meta: String? {
        if !slot.topic.isEmpty { return slot.topic }
        return slot.subgroupCount > 0 ? "Подгруппы: \(slot.subgroupCount)" : nil
    }
}
