//
//  MediumLayout.swift
//  CollegeWidget
//

import SwiftUI

struct MediumLayout: View {
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
            case .disabled:
                WidgetMessage.disabled
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func focusContent(_ focus: WidgetFocus) -> some View {
        ViewThatFits(in: .vertical) {
            lessonStack(focus, showsTopic: true)
            lessonStack(focus, showsTopic: false)
        }
        .accessibilityElement(children: .combine)
    }

    private func lessonStack(_ focus: WidgetFocus, showsTopic: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            SlotHeader(slot: focus.slot)

            Text(focus.slot.title)
                .textStyle(AppType.titleLarge)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.top, 8)

            if showsTopic && !focus.slot.topic.isEmpty {
                Text(focus.slot.topic)
                    .textStyle(AppType.bodyMedium)
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(1)
                    .padding(.top, 2)
            }

            StatusLine(focus: focus, now: entry.date)
                .padding(.top, 8)

            Spacer(minLength: 6)

            if let next = focus.next {
                NextCapsule(
                    label: dayLabel(of: next.day, focusDay: focus.day.date),
                    slot: next,
                    isOnGradient: true
                )
            }
        }
    }

    private func restContent(_ rest: WidgetRest) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            RestHeader(caption: "Сегодня", lessonCount: rest.lessonCount)

            Spacer(minLength: 8)

            if let day = rest.upcoming, let slot = day.slots.first {
                NextCapsule(
                    label: dayLabel(of: day.date, focusDay: ScheduleCalendar.day(of: entry.date)),
                    slot: slot,
                    isOnGradient: false
                )
            }
        }
    }

    private func dayLabel(of day: Date, focusDay: Date) -> String {
        WidgetSchedule.dayLabel(of: day, focusDay: focusDay, at: entry.date)
    }
}
