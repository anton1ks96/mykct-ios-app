//
//  Palette.swift
//  college-ios-app
//

import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }

    static let violet = Color(hex: 0x6C5CE7)
    static let violetTint = Color(hex: 0xC3B6FF)
    static let violetLight = Color(hex: 0x9B8CFF)
    static let violetDeep = Color(hex: 0x4B3FBF)
    static let violetMagenta = Color(hex: 0xA347E0)
    static let violetIndigo = Color(hex: 0x4A54C9)
    static let violetSoft = Color(hex: 0xE8E5FF)
    static let violetInk = Color(hex: 0x3F1FD6)

    static let flameOrange = Color.orange
    static let flameRed = Color.red
    static let flameIdle = Color.gray

    static let statusGreen = Color(hex: 0x30D97C)
    static let statusWarning = Color(hex: 0xFFAE1A)
    static let statusDanger = Color(hex: 0xFF5A63)

    static let statusGreenFill = Color(hex: 0x46A758)
    static let statusWarningFill = Color(hex: 0xFFC53D)
    static let statusDangerFill = Color(hex: 0xE5484D)
    static let greenLime = Color(hex: 0xC3F26B)

    static let lightBackground = Color(hex: 0xF4F4F8)
    static let greyFill = Color(hex: 0xE7E7EE)
    static let greyText = Color(hex: 0x6E6E7A)
    static let ink = Color(hex: 0x16161D)

    static let darkBackground = Color(hex: 0x0C0C11)
    static let darkSurface = Color(hex: 0x16161D)
    static let darkGreyFill = Color(hex: 0x23232D)
    static let darkGreyText = Color(hex: 0x8A8A99)
}

let accentGradient = LinearGradient(
    colors: [.violet, .violetDeep],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

let successGradient = LinearGradient(
    colors: [.greenLime, .statusGreen],
    startPoint: .top,
    endPoint: .bottom
)
