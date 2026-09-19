//
//  AppColors.swift
//  college-ios-app
//

import SwiftUI

struct AppColors: Equatable, Sendable {
    let primary: Color
    let onPrimary: Color
    let primaryContainer: Color
    let onPrimaryContainer: Color
    let secondary: Color
    let onSecondary: Color
    let tertiary: Color
    let onTertiary: Color
    let background: Color
    let onBackground: Color
    let surface: Color
    let onSurface: Color
    let surfaceVariant: Color
    let onSurfaceVariant: Color
    let outlineVariant: Color
    let success: Color
    let warning: Color
    let danger: Color
    let successFill: Color
    let warningFill: Color
    let dangerFill: Color
    let onStatusFill: Color
    let isDark: Bool
    let hasGlow: Bool

    static let light = AppColors(
        primary: .violet,
        onPrimary: .white,
        primaryContainer: .violetSoft,
        onPrimaryContainer: .ink,
        secondary: .statusGreen,
        onSecondary: .white,
        tertiary: .violet,
        onTertiary: .white,
        background: .lightBackground,
        onBackground: .ink,
        surface: .white,
        onSurface: .ink,
        surfaceVariant: .greyFill,
        onSurfaceVariant: .greyText,
        outlineVariant: .greyFill,
        success: .statusGreen,
        warning: .statusWarning,
        danger: .statusDanger,
        successFill: .statusGreenFill,
        warningFill: .statusWarningFill,
        dangerFill: .statusDangerFill,
        onStatusFill: .ink,
        isDark: false,
        hasGlow: true
    )

    static let dark = AppColors(
        primary: .violet,
        onPrimary: .white,
        primaryContainer: .violetDeep,
        onPrimaryContainer: .white,
        secondary: .statusGreen,
        onSecondary: .white,
        tertiary: .violet,
        onTertiary: .white,
        background: .darkBackground,
        onBackground: .white,
        surface: .darkSurface,
        onSurface: .white,
        surfaceVariant: .darkGreyFill,
        onSurfaceVariant: .darkGreyText,
        outlineVariant: .darkGreyFill,
        success: .statusGreen,
        warning: .statusWarning,
        danger: .statusDanger,
        successFill: .statusGreenFill,
        warningFill: .statusWarningFill,
        dangerFill: .statusDangerFill,
        onStatusFill: .ink,
        isDark: true,
        hasGlow: true
    )

    static let oled = AppColors(
        primary: .violet,
        onPrimary: .white,
        primaryContainer: .violetDeep,
        onPrimaryContainer: .white,
        secondary: .statusGreen,
        onSecondary: .white,
        tertiary: .violet,
        onTertiary: .white,
        background: .oledBackground,
        onBackground: .white,
        surface: .oledSurface,
        onSurface: .white,
        surfaceVariant: .darkGreyFill,
        onSurfaceVariant: .darkGreyText,
        outlineVariant: .darkGreyFill,
        success: .statusGreen,
        warning: .statusWarning,
        danger: .statusDanger,
        successFill: .statusGreenFill,
        warningFill: .statusWarningFill,
        dangerFill: .statusDangerFill,
        onStatusFill: .ink,
        isDark: true,
        hasGlow: false
    )

    static func of(_ scheme: ColorScheme, theme: AppTheme = .system) -> AppColors {
        guard theme != .oled else { return .oled }
        return scheme == .dark ? .dark : .light
    }
}
