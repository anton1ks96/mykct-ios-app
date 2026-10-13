//
//  LessonTile.swift
//  CollegeWatch
//

import SwiftUI

private let tilePadding: CGFloat = 10
private let pastOpacity: Double = 0.55
private let metaSymbolSize: CGFloat = 10

struct LessonTile: View {
    @Environment(\.colors) private var colors

    let slot: WidgetSlot
    var isPast = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(slot.timeRange)
                .textStyle(AppType.labelLarge)
                .fontWeight(.bold)
                .monospacedDigit()
                .foregroundStyle(colors.accentText)
                .lineLimit(1)

            Text(slot.title)
                .textStyle(AppType.bodyLarge)
                .fontWeight(.semibold)
                .foregroundStyle(colors.onSurface)
                .lineLimit(3)
                .minimumScaleFactor(0.85)

            meta
                .textStyle(AppType.labelMedium)
                .foregroundStyle(colors.onSurfaceVariant)
                .lineLimit(1)
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
