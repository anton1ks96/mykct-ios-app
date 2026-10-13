//
//  AppTypography.swift
//  college-ios-app
//

import SwiftUI

struct AppTextStyle {
    let font: Font
    var tracking: CGFloat = 0
}

enum AppType {
    static let headlineMedium = AppTextStyle(font: .system(.title2).weight(.bold))
    static let headlineSmall = AppTextStyle(font: .system(.title2).weight(.bold))
    static let displayLarge = AppTextStyle(font: .system(size: 56).weight(.bold))
    static let displayMedium = AppTextStyle(font: .system(size: 48).weight(.bold))
    static let heroValue = AppTextStyle(font: .system(.largeTitle).weight(.bold))
    static let titleLarge = AppTextStyle(font: .system(.title3).weight(.bold))
    static let titleMedium = AppTextStyle(font: .system(.headline))
    static let bodyLarge = AppTextStyle(font: .system(.subheadline))
    static let bodyMedium = AppTextStyle(font: .system(.footnote))
    static let bodySmall = AppTextStyle(font: .system(.caption))
    static let labelLarge = AppTextStyle(font: .system(.footnote).weight(.semibold))
    static let labelMedium = AppTextStyle(font: .system(.caption))
    static let labelSmall = AppTextStyle(font: .system(.caption2))
    static let caps = AppTextStyle(font: .system(.caption2), tracking: 1)
}

extension View {
    func textStyle(_ style: AppTextStyle) -> some View {
        font(style.font).tracking(style.tracking)
    }
}
