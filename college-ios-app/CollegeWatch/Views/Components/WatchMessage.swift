//
//  WatchMessage.swift
//  CollegeWatch
//

import SwiftUI

private let badgeSide: CGFloat = 52

struct WatchMessage: View {
    @Environment(\.colors) private var colors
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    static let setup = WatchMessage(
        symbol: "iphone",
        title: "Выбери группу",
        subtitle: "Открой МойКЦТ на iPhone, и расписание появится здесь"
    )

    static let unavailable = WatchMessage(
        symbol: "arrow.trianglehead.2.clockwise.rotate.90.icloud",
        title: "Нет данных",
        subtitle: "Открой МойКЦТ, чтобы обновить"
    )

    let symbol: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: symbol)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .frame(width: badgeSide, height: badgeSide)
                .background { badge }

            Text(title)
                .textStyle(AppType.titleMedium)
                .fontWeight(.bold)
                .foregroundStyle(colors.onBackground)

            Text(subtitle)
                .textStyle(AppType.bodyMedium)
                .foregroundStyle(colors.onSurfaceVariant)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var badge: some View {
        if isLuminanceReduced {
            Circle().strokeBorder(colors.accentText, lineWidth: 1.5)
        } else {
            Circle().fill(accentGradient)
        }
    }
}
