//
//  WidgetPill.swift
//  CollegeWidget
//

import SwiftUI

struct WidgetPill: View {
    @Environment(\.colors) private var colors

    let text: String

    var body: some View {
        Text(text)
            .textStyle(AppType.labelLarge)
            .fontWeight(.bold)
            .monospacedDigit()
            .foregroundStyle(colors.primary)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.white, in: Capsule())
    }
}
