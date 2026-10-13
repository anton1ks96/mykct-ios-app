//
//  RectangularLayout.swift
//  CollegeWatchWidget
//

import SwiftUI
import WidgetKit

private let barMinWidth: CGFloat = 24

struct RectangularLayout: View {
    @Environment(\.colors) private var colors
    @Environment(\.widgetRenderingMode) private var renderingMode
    @Environment(\.showsWidgetContainerBackground) private var showsBackground

    let entry: ScheduleEntry

    private var isOnGradient: Bool { showsBackground && renderingMode == .fullColor }
    private var today: Date { ScheduleCalendar.day(of: entry.date) }

    var body: some View {
        Group {
            switch entry.content {
            case .focus(let focus):
                focusContent(focus)
            case .rest(let rest):
                restContent(rest)
            case .setup:
                message("Выбери группу", "Открой МойКЦТ на iPhone")
            case .unavailable:
                message("Нет данных", "Открой МойКЦТ, чтобы обновить")
            }
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func focusContent(_ focus: WidgetFocus) -> some View {
        let next = isOnGradient ? focus.next : nil

        return VStack(alignment: .leading, spacing: next == nil ? 1 : 0) {
            accentLine(symbol: focus.slot.symbol, text: header(focus))

            Text(focus.slot.title)
                .textStyle(next == nil ? AppType.titleMedium : AppType.labelLarge)
                .fontWeight(.bold)
                .foregroundStyle(colors.onSurface)

            HStack(spacing: 6) {
                detail(focus)
                    .layoutPriority(1)

                if focus.stage == .ongoing {
                    LessonProgressBar(slot: focus.slot)
                        .frame(minWidth: barMinWidth)
                }
            }
            .textStyle(AppType.labelMedium)
            .foregroundStyle(secondary)

            if let next {
                nextLine(next, after: focus)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func nextLine(_ slot: WidgetSlot, after focus: WidgetFocus) -> some View {
        let label = WidgetSchedule.dayLabel(of: slot.day, focusDay: focus.day.date, at: entry.date)
        let detail = [slot.room, slot.title].filter { !$0.isEmpty }.joined(separator: " · ")

        return HStack(spacing: 4) {
            Text(label.uppercased())
                .textStyle(AppType.caps)

            Text(ScheduleFormat.time(slot.start))
                .fontWeight(.bold)
                .monospacedDigit()

            Text(detail)
        }
        .textStyle(AppType.labelMedium)
        .foregroundStyle(secondary)
    }

    private func restContent(_ rest: WidgetRest) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(rest.lessonCount == 0 ? "Пар нет" : "Пары закончились")
                .textStyle(AppType.titleMedium)
                .foregroundStyle(colors.onSurface)

            if let day = rest.upcoming, let slot = day.slots.first {
                accentLine(symbol: slot.symbol, text: start(of: slot, on: day.date))

                Text(slot.title)
                    .textStyle(AppType.labelMedium)
                    .foregroundStyle(secondary)
            } else {
                Text("Отдыхай")
                    .textStyle(AppType.labelMedium)
                    .foregroundStyle(secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func message(_ title: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
                .textStyle(AppType.titleMedium)
                .foregroundStyle(colors.onSurface)

            Text(subtitle)
                .textStyle(AppType.labelMedium)
                .foregroundStyle(secondary)
        }
        .accessibilityElement(children: .combine)
    }

    private func accentLine(symbol: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
            Text(text)
                .monospacedDigit()
        }
        .textStyle(AppType.labelLarge)
        .fontWeight(.bold)
        .foregroundStyle(isOnGradient ? .white : colors.accentText)
        .widgetAccentable()
    }

    private var secondary: Color {
        isOnGradient ? .white.opacity(0.85) : colors.onSurfaceVariant
    }

    private func header(_ focus: WidgetFocus) -> String {
        focus.stage == .tomorrow ? start(of: focus.slot, on: focus.day.date) : focus.slot.timeRange
    }

    private func start(of slot: WidgetSlot, on day: Date) -> String {
        let label = WidgetSchedule.dayLabel(of: day, focusDay: today, at: entry.date)
        return "\(label) · \(ScheduleFormat.time(slot.start))"
    }

    private func detail(_ focus: WidgetFocus) -> Text {
        let slot = focus.slot
        let place = slot.room.isEmpty && slot.subgroupCount > 0
            ? "Подгруппы: \(slot.subgroupCount)"
            : slot.room

        let minutes: Text
        switch focus.stage {
        case .ongoing:
            minutes = Text.minutes(to: slot.endDate)
        case .upcoming where WidgetSchedule.isSoon(slot, at: entry.date):
            minutes = Text("через \(Text.minutes(to: slot.startDate))")
        default:
            return Text(place)
        }
        return place.isEmpty ? minutes : Text("\(place) · \(minutes)")
    }
}
