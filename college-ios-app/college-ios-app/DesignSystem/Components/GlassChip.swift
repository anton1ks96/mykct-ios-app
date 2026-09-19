//
//  GlassChip.swift
//  college-ios-app
//

import SwiftUI

struct GlassChip: View {
    let text: String
    let symbol: String
    var foreground: Color = .white
    var fill: Color = .black.opacity(0.22)

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: symbol)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .textStyle(AppType.labelSmall)
                .fontWeight(.semibold)
                .contentTransition(.numericText())
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Capsule().fill(fill))
        .glassSurface(Capsule(), style: .clear)
        .overlay(Capsule().stroke(foreground.opacity(0.6), lineWidth: 1))
    }
}

#Preview {
    GlassGroup {
        HStack(spacing: 8) {
            GlassChip(text: "301", symbol: "mappin.and.ellipse")
            GlassChip(text: "Подгруппы: 4", symbol: "list.bullet")
        }
    }
    .padding(20)
    .appBackground()
    .environment(\.colors, .dark)
}
