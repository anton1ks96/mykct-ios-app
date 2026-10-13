//
//  NowCard.swift
//  CollegeWatch
//

import SwiftUI

private let cardPadding: CGFloat = 12
private let barMinWidth: CGFloat = 36
private let borderWidth: CGFloat = 2
private let dimmedFillOpacity: Double = 0.18

struct NowCard: View {
    @Environment(\.colors) private var colors
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    let focus: WidgetFocus
    let now: Date

    private var slot: WidgetSlot { focus.slot }
    private var isOngoing: Bool { focus.stage == .ongoing }
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            WidgetPill(text: slot.timeRange)

            Text(slot.title)
                .textStyle(AppType.titleMedium)
                .fontWeight(.bold)
                .lineLimit(3)
                .minimumScaleFactor(0.85)
                .padding(.top, 6)

            if !isOngoing && !slot.topic.isEmpty {
                Text(slot.topic)
                    .textStyle(AppType.bodyMedium)
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(1)
                    .padding(.top, 1)
            }

            chipRow
                .padding(.top, 8)

            status
                .padding(.top, 6)
        }
        .foregroundStyle(.white)
        .padding(cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background { background }
        .clipShape(shape)
        .overlay { border }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var chipRow: some View {
        let chip = WidgetChip.room(slot) ?? WidgetChip.subgroups(slot)

        if isOngoing {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    chip
                    LessonProgressBar(slot: slot)
                        .frame(minWidth: barMinWidth)
                }
                chip
            }
        } else {
            chip
        }
    }

    @ViewBuilder
    private var status: some View {
        if isOngoing {
            countdown("Осталось", to: slot.endDate)
        } else if WidgetSchedule.isSoon(slot, at: now) {
            countdown("Через", to: slot.startDate)
        } else {
            Text("Сегодня · \(ScheduleFormat.lessonsCount(focus.day.slots.count))")
                .textStyle(AppType.labelLarge)
                .fontWeight(.semibold)
                .lineLimit(1)
        }
    }

    private func countdown(_ caption: String, to date: Date) -> some View {
        Text("\(caption) \(Text.minutes(to: date))")
            .textStyle(AppType.labelLarge)
            .fontWeight(.semibold)
            .lineLimit(2)
    }

    @ViewBuilder
    private var background: some View {
        if isLuminanceReduced {
            colors.primary.opacity(dimmedFillOpacity)
        } else {
            LessonBackground(symbol: slot.symbol)
        }
    }

    @ViewBuilder
    private var border: some View {
        if isOngoing {
            shape.strokeBorder(
                isLuminanceReduced ? colors.accentText : .white.opacity(0.85),
                lineWidth: borderWidth
            )
        }
    }
}
