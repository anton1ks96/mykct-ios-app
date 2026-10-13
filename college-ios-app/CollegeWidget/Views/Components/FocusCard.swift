//
//  FocusCard.swift
//  CollegeWidget
//

import SwiftUI
import WidgetKit

struct FocusCard: View {
    @Environment(\.widgetRenderingMode) private var renderingMode

    let focus: WidgetFocus
    let now: Date

    private var slot: WidgetSlot { focus.slot }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
    }

    private var showsStatus: Bool {
        switch focus.stage {
        case .ongoing: true
        case .upcoming: WidgetSchedule.isSoon(slot, at: now)
        case .tomorrow: false
        }
    }

    @ViewBuilder
    private var background: some View {
        if renderingMode == .fullColor {
            LessonBackground(symbol: slot.symbol)
        } else {
            Color.white.opacity(0.1)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SlotHeader(slot: slot)

            Text(slot.title)
                .textStyle(AppType.titleLarge)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.top, 8)

            if !slot.topic.isEmpty {
                Text(slot.topic)
                    .textStyle(AppType.bodyMedium)
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(1)
                    .padding(.top, 2)
            }

            if showsStatus {
                StatusLine(focus: focus, now: now)
                    .padding(.top, 8)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { background }
        .clipShape(shape)
        .overlay {
            if focus.stage == .ongoing {
                shape.strokeBorder(.white.opacity(0.85), lineWidth: 2)
                    .widgetAccentable()
            } else if renderingMode != .fullColor {
                shape.strokeBorder(.white.opacity(0.25), lineWidth: 1)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
