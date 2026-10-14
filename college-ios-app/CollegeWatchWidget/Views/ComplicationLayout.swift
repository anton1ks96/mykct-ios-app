//
//  ComplicationLayout.swift
//  CollegeWatchWidget
//

import SwiftUI
import WidgetKit

struct ComplicationLayout: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.colors) private var colors

    let entry: ScheduleEntry

    var body: some View {
        layout
            .environment(\.colors, .oled)
            .environment(\.locale, ScheduleCalendar.locale)
            .containerBackground(for: .widget) {
                background
            }
    }

    @ViewBuilder
    private var layout: some View {
        switch family {
        case .accessoryInline:
            InlineLayout(entry: entry)
        case .accessoryCircular:
            CircularLayout(entry: entry)
        default:
            RectangularLayout(entry: entry)
        }
    }

    @ViewBuilder
    private var background: some View {
        if case .focus(let focus) = entry.content {
            LessonBackground(symbol: focus.slot.symbol)
        } else {
            colors.surfaceVariant
        }
    }
}
