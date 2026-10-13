//
//  NextCapsule.swift
//  CollegeWidget
//

import SwiftUI
import WidgetKit

struct NextCapsule: View {
    @Environment(\.widgetRenderingMode) private var renderingMode

    let label: String
    let slot: WidgetSlot
    let isOnGradient: Bool

    var body: some View {
        HStack(spacing: 8) {
            Text(label.uppercased())
                .textStyle(AppType.caps)
                .foregroundStyle(.white.opacity(isOnGradient ? 0.7 : 0.8))

            Text(ScheduleFormat.time(slot.start))
                .textStyle(AppType.labelLarge)
                .fontWeight(.bold)
                .monospacedDigit()
                .widgetAccentable()

            Text(detail)
                .textStyle(AppType.bodyMedium)
                .foregroundStyle(.white.opacity(isOnGradient ? 0.8 : 1))
        }
        .lineLimit(1)
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background { background }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var background: some View {
        if isOnGradient {
            Capsule()
                .fill(.black.opacity(0.18))
                .overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 1))
        } else if renderingMode == .fullColor {
            Capsule().fill(accentGradient)
        } else {
            Capsule().fill(.white.opacity(0.2))
        }
    }

    private var detail: String {
        [slot.room, slot.title].filter { !$0.isEmpty }.joined(separator: " · ")
    }
}
