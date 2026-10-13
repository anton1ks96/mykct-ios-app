//
//  SmallLayout.swift
//  CollegeWidget
//

import SwiftUI

private let barMinWidth: CGFloat = 40

struct SmallLayout: View {
    @Environment(\.colors) private var colors

    let entry: ScheduleEntry

    var body: some View {
        Group {
            switch entry.content {
            case .focus(let focus):
                focusContent(focus)
            case .rest(let rest):
                restContent(rest)
            case .setup:
                WidgetMessage.setup
            case .unavailable:
                WidgetMessage.unavailable
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func focusContent(_ focus: WidgetFocus) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            WidgetPill(text: focus.slot.timeRange)

            Text(focus.slot.title)
                .textStyle(AppType.titleLarge)
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.75)
                .padding(.top, 6)

            Spacer(minLength: 6)

            chipRow(focus)

            StatusLine(focus: focus, now: entry.date, isCompact: true)
                .padding(.top, 8)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func chipRow(_ focus: WidgetFocus) -> some View {
        let chip = WidgetChip.room(focus.slot) ?? WidgetChip.subgroups(focus.slot)

        if focus.stage == .ongoing {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    chip
                    LessonProgressBar(slot: focus.slot)
                        .frame(minWidth: barMinWidth)
                }
                chip
            }
        } else {
            chip
        }
    }

    private func restContent(_ rest: WidgetRest) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            RestHeader(caption: "Сегодня", lessonCount: rest.lessonCount)

            Spacer(minLength: 8)

            if let day = rest.upcoming, let slot = day.slots.first {
                WidgetPill(
                    text: "\(dayLabel(of: day)) · \(ScheduleFormat.time(slot.start))",
                    style: .accent
                )

                Text(slot.title)
                    .textStyle(AppType.bodySmall)
                    .foregroundStyle(colors.onSurfaceVariant)
                    .lineLimit(1)
                    .padding(.top, 4)
            }
        }
    }

    private func dayLabel(of day: WidgetDay) -> String {
        WidgetSchedule.dayLabel(
            of: day.date,
            focusDay: ScheduleCalendar.day(of: entry.date),
            at: entry.date
        )
    }
}
