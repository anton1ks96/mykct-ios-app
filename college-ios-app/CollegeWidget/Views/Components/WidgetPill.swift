//
//  WidgetPill.swift
//  CollegeWidget
//

import SwiftUI
import WidgetKit

struct WidgetPill: View {
    enum Style {
        case time
        case accent
    }

    @Environment(\.colors) private var colors
    @Environment(\.widgetRenderingMode) private var renderingMode

    let text: String
    var style: Style = .time

    private var isFullColor: Bool { renderingMode == .fullColor }

    var body: some View {
        Text(text)
            .textStyle(AppType.labelLarge)
            .fontWeight(style == .time ? .bold : .semibold)
            .monospacedDigit()
            .foregroundStyle(isFullColor && style == .time ? colors.primary : .white)
            .widgetAccentable()
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background { background }
    }

    @ViewBuilder
    private var background: some View {
        if !isFullColor {
            Capsule().fill(.white.opacity(0.2))
        } else if style == .time {
            Capsule().fill(.white)
        } else {
            Capsule().fill(accentGradient)
        }
    }
}
