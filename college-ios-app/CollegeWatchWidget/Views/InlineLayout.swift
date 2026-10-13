//
//  InlineLayout.swift
//  CollegeWatchWidget
//

import SwiftUI

struct InlineLayout: View {
    let entry: ScheduleEntry

    var body: some View {
        switch entry.content {
        case .focus(let focus):
            focusLine(focus)
        case .rest(let rest):
            if let day = rest.upcoming, let slot = day.slots.first {
                line(slot.symbol, Text(startText(of: slot, on: day.date)))
            } else {
                Text("Пар нет")
            }
        case .setup:
            Text("Выбери группу")
        case .unavailable:
            Text("Нет данных")
        }
    }

    @ViewBuilder
    private func focusLine(_ focus: WidgetFocus) -> some View {
        let slot = focus.slot

        switch focus.stage {
        case .ongoing:
            line("mappin.and.ellipse", countdown("ещё", to: slot.endDate, at: slot))
        case .upcoming where WidgetSchedule.isSoon(slot, at: entry.date):
            line("mappin.and.ellipse", countdown("через", to: slot.startDate, at: slot))
        case .upcoming:
            line(slot.symbol, Text(joined(ScheduleFormat.time(slot.start), place(of: slot))))
        case .tomorrow:
            line(slot.symbol, Text(startText(of: slot, on: focus.day.date)))
        }
    }

    private func line(_ symbol: String, _ text: Text) -> some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
            text
        }
    }

    private func countdown(_ caption: String, to date: Date, at slot: WidgetSlot) -> Text {
        let minutes = Text("\(caption) \(Text.minutes(to: date))")
        let place = place(of: slot)
        return place.isEmpty ? minutes : Text("\(place) · \(minutes)")
    }

    private func startText(of slot: WidgetSlot, on day: Date) -> String {
        let today = ScheduleCalendar.day(of: entry.date)
        let label = WidgetSchedule.dayLabel(of: day, focusDay: today, at: entry.date)
        return joined("\(label) \(ScheduleFormat.time(slot.start))", place(of: slot))
    }

    private func place(of slot: WidgetSlot) -> String {
        slot.room.isEmpty ? slot.title : slot.room
    }

    private func joined(_ first: String, _ second: String) -> String {
        second.isEmpty ? first : "\(first) · \(second)"
    }
}
