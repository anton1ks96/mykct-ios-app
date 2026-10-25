//
//  LargeLayout.swift
//  CollegeWidget
//

import SwiftUI

private let rowLimits = [4, 3, 2, 1]
private let overflowInset: CGFloat = 56

struct LargeLayout: View {
    @Environment(\.colors) private var colors

    let entry: ScheduleEntry

    var body: some View {
        Group {
            switch entry.content {
            case .focus(let focus):
                fitting { focusContent(focus, limit: $0) }
            case .rest(let rest):
                fitting { restContent(rest, limit: $0) }
            case .setup:
                WidgetMessage.setup.frame(maxHeight: 138)
            case .unavailable:
                WidgetMessage.unavailable.frame(maxHeight: 138)
            case .disabled:
                WidgetMessage.disabled.frame(maxHeight: 138)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func fitting<Content: View>(
        @ViewBuilder _ content: @escaping (Int) -> Content
    ) -> some View {
        ViewThatFits(in: .vertical) {
            ForEach(rowLimits, id: \.self) { limit in
                content(limit)
            }
        }
    }

    private func focusContent(_ focus: WidgetFocus, limit: Int) -> some View {
        let slots = focus.day.slots
        let rows = WidgetSchedule.rows(around: focus.index, count: slots.count, limit: limit)

        return VStack(alignment: .leading, spacing: 0) {
            DayTitleRow(day: focus.day, now: entry.date)

            VStack(alignment: .leading, spacing: 6) {
                ForEach(rows.past, id: \.self) { index in
                    LessonRow(slot: slots[index], isPast: true)
                }
                FocusCard(focus: focus, now: entry.date)
                ForEach(rows.future, id: \.self) { index in
                    LessonRow(slot: slots[index], isPast: false)
                }
                if rows.hidden > 0 {
                    overflow(rows.hidden, slots: slots)
                }
            }
            .padding(.top, 10)
        }
    }

    private func restContent(_ rest: WidgetRest, limit: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            RestHeader(
                caption: ScheduleFormat.dayTitle(ScheduleCalendar.day(of: entry.date)),
                lessonCount: rest.lessonCount
            )

            if let day = rest.upcoming {
                let rows = WidgetSchedule.rows(around: nil, count: day.slots.count, limit: limit)

                DayTitleRow(day: day, now: entry.date)
                    .padding(.top, 24)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(rows.future, id: \.self) { index in
                        LessonRow(slot: day.slots[index], isPast: false)
                    }
                    if rows.hidden > 0 {
                        overflow(rows.hidden, slots: day.slots)
                    }
                }
                .padding(.top, 10)
            }
        }
    }

    private func overflow(_ hidden: Int, slots: [WidgetSlot]) -> some View {
        let end = slots.last.map { ScheduleFormat.time($0.end) } ?? ""

        return Text("Ещё \(ScheduleFormat.lessonsCount(hidden)) · до \(end)")
            .textStyle(AppType.labelMedium)
            .foregroundStyle(colors.onSurfaceVariant)
            .padding(.leading, overflowInset)
    }
}
