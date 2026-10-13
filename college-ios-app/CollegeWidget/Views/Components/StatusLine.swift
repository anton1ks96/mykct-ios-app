//
//  StatusLine.swift
//  CollegeWidget
//

import SwiftUI

private let barWidth: CGFloat = 96

struct StatusLine: View {
    let focus: WidgetFocus
    let now: Date
    var isCompact = false

    private var slot: WidgetSlot { focus.slot }

    var body: some View {
        HStack(spacing: 10) {
            label
                .lineLimit(1)
                .layoutPriority(1)

            if focus.stage == .ongoing && !isCompact {
                LessonProgressBar(slot: slot)
                    .frame(width: barWidth)
            }
        }
        .font(AppType.bodyLarge.font)
        .fontWeight(.semibold)
        .foregroundStyle(.white)
    }

    @ViewBuilder
    private var label: some View {
        switch focus.stage {
        case .ongoing:
            if isCompact {
                minutes(to: slot.endDate)
            } else {
                HStack(spacing: 4) {
                    Text("Осталось")
                    minutes(to: slot.endDate)
                }
            }
        case .upcoming:
            if WidgetSchedule.isSoon(slot, at: now) {
                HStack(spacing: 4) {
                    Text("Через")
                    minutes(to: slot.startDate)
                }
            } else {
                Text("Сегодня · \(ScheduleFormat.lessonsCount(focus.day.slots.count))")
            }
        case .tomorrow:
            Text("Завтра · \(ScheduleFormat.lessonsCount(focus.day.slots.count))")
        }
    }

    private func minutes(to date: Date) -> Text {
        Text(
            .currentDate,
            format: .offset(to: date, allowedFields: [.minute], maxFieldCount: 1, sign: .never)
        )
    }
}
