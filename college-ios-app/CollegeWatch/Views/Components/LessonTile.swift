//
//  LessonTile.swift
//  CollegeWatch
//

import SwiftUI

private let timeColumnWidth: CGFloat = 44
private let tilePadding: CGFloat = 10
private let pastOpacity: Double = 0.55
private let metaSymbolSize: CGFloat = 10

struct LessonTile: View {
    @Environment(\.colors) private var colors

    let slot: WidgetSlot
    var isPast = false

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
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
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .frame(width: timeColumnWidth, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(slot.title)
                    .textStyle(AppType.bodyLarge)
                    .fontWeight(.semibold)
                    .foregroundStyle(colors.onSurface)
                    .lineLimit(3)

                meta
                    .textStyle(AppType.labelMedium)
                    .foregroundStyle(colors.onSurfaceVariant)
                    .lineLimit(1)
            }
        }
        .padding(tilePadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            colors.surfaceVariant,
            in: RoundedRectangle(cornerRadius: Metrics.rowRadius, style: .continuous)
        )
        .opacity(isPast ? pastOpacity : 1)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var meta: some View {
        if !slot.room.isEmpty {
            HStack(spacing: 3) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: metaSymbolSize))
                    .fontWeight(.semibold)
                Text(slot.room)
            }
        } else if slot.subgroupCount > 0 {
            Text("Подгруппы: \(slot.subgroupCount)")
        }
    }
}
