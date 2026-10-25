//
//  CircularLayout.swift
//  CollegeWatchWidget
//

import SwiftUI
import WidgetKit

private let symbolSize: CGFloat = 12
private let messageSymbolSize: CGFloat = 18

struct CircularLayout: View {
    @Environment(\.colors) private var colors

    let entry: ScheduleEntry

    var body: some View {
        switch entry.content {
        case .focus(let focus) where focus.stage == .ongoing:
            ring(focus.slot)
        case .focus(let focus):
            start(focus.slot)
        case .rest(let rest):
            if let slot = rest.upcoming?.slots.first {
                start(slot)
            } else {
                badge("moon.zzz")
            }
        case .setup:
            badge("iphone")
        case .unavailable:
            badge("arrow.clockwise")
        case .disabled:
            badge("pause")
        }
    }

    private func ring(_ slot: WidgetSlot) -> some View {
        ProgressView(timerInterval: slot.startDate...slot.endDate, countsDown: false) {
            EmptyView()
        } currentValueLabel: {
            Text(timerInterval: slot.startDate...slot.endDate, countsDown: true, showsHours: false)
                .textStyle(AppType.labelMedium)
                .fontWeight(.bold)
                .monospacedDigit()
                .minimumScaleFactor(0.7)
        }
        .progressViewStyle(.circular)
        .tint(colors.accentText)
        .widgetAccentable()
    }

    private func start(_ slot: WidgetSlot) -> some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 0) {
                Image(systemName: slot.symbol)
                    .font(.system(size: symbolSize))
                    .fontWeight(.semibold)
                    .widgetAccentable()

                Text(ScheduleFormat.time(slot.start))
                    .textStyle(AppType.labelLarge)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
            }
            .padding(4)
        }
        .accessibilityElement(children: .combine)
    }

    private func badge(_ symbol: String) -> some View {
        ZStack {
            AccessoryWidgetBackground()

            Image(systemName: symbol)
                .font(.system(size: messageSymbolSize))
                .fontWeight(.semibold)
                .widgetAccentable()
        }
    }
}
