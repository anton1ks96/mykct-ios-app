//
//  WidgetMessage.swift
//  CollegeWidget
//

import SwiftUI
import WidgetKit

struct WidgetMessage: View {
    @Environment(\.colors) private var colors

    static let setup = WidgetMessage(
        symbol: "calendar.badge.plus",
        title: "Выбери группу",
        subtitle: "Открой МойКЦТ"
    )

    static let unavailable = WidgetMessage(
        symbol: "arrow.trianglehead.2.clockwise.rotate.90.icloud",
        title: "Нет данных",
        subtitle: "Открой МойКЦТ, чтобы обновить"
    )

    static let disabled = WidgetMessage(
        symbol: "pause.circle",
        title: "Расписание отключено",
        subtitle: "Временно, загляни позже"
    )

    let symbol: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: symbol)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(colors.accentText)
                .widgetAccentable()

            Spacer(minLength: 8)

            Text(title)
                .textStyle(AppType.titleLarge)
                .foregroundStyle(colors.onBackground)
                .lineLimit(2)

            Text(subtitle)
                .textStyle(AppType.bodyMedium)
                .foregroundStyle(colors.onSurfaceVariant)
                .lineLimit(2)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
