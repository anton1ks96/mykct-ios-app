//
//  LessonBackground.swift
//  CollegeWidget
//

import SwiftUI

private let watermarkSize: CGFloat = 76

struct LessonBackground: View {
    let symbol: String

    var body: some View {
        accentGradient
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: symbol)
                    .font(.system(size: watermarkSize, weight: .light))
                    .foregroundStyle(.white.opacity(0.13))
                    .offset(x: 8, y: 8)
                    .accessibilityHidden(true)
            }
    }
}
