//
//  ScheduleWidgetLayout.swift
//  CollegeWidget
//

import SwiftUI
import WidgetKit

struct ScheduleWidgetLayout: View {
    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var colorScheme

    let entry: ScheduleEntry

    var body: some View {
        layout
            .dynamicTypeSize(...DynamicTypeSize.large)
            .environment(\.colors, AppColors.of(colorScheme))
            .environment(\.locale, ScheduleCalendar.locale)
            .containerBackground(for: .widget) {
                background
            }
    }

    @ViewBuilder
    private var layout: some View {
        switch family {
        case .systemMedium:
            MediumLayout(entry: entry)
        case .systemLarge:
            LargeLayout(entry: entry)
        default:
            SmallLayout(entry: entry)
        }
    }

    @ViewBuilder
    private var background: some View {
        if family != .systemLarge, case .focus(let focus) = entry.content {
            LessonBackground(symbol: focus.slot.symbol)
        } else {
            WidgetBackdrop()
        }
    }
}
