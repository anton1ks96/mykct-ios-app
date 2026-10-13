//
//  NextDayCard.swift
//  CollegeWatch
//

import SwiftUI

private let cardPadding: CGFloat = 12
private let dimmedFillOpacity: Double = 0.18

struct NextDayCard: View {
    @Environment(\.colors) private var colors
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    let label: String
    let slot: WidgetSlot

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .textStyle(AppType.caps)
                .foregroundStyle(.white.opacity(0.75))
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(ScheduleFormat.time(slot.start))
                    .textStyle(AppType.labelLarge)
                    .fontWeight(.bold)
                    .monospacedDigit()

                Text(slot.title)
                    .textStyle(AppType.bodyMedium)
                    .lineLimit(2)
            }
        }
        .foregroundStyle(.white)
        .padding(cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { background }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var background: some View {
        if isLuminanceReduced {
            shape
                .fill(colors.primary.opacity(dimmedFillOpacity))
                .overlay(shape.strokeBorder(colors.accentText, lineWidth: 1))
        } else {
            shape.fill(accentGradient)
        }
    }
}
