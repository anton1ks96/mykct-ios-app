//
//  WidgetBackdrop.swift
//  CollegeWidget
//

import SwiftUI

struct WidgetBackdrop: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let colors = AppColors.of(colorScheme)
        let strength = colors.isDark ? 1.0 : 0.5

        GeometryReader { proxy in
            let width = proxy.size.width

            ZStack {
                colors.background
                glow(
                    colors.primary, opacity: 0.50 * strength,
                    center: CGPoint(x: width, y: -width * 0.05),
                    radius: width * 0.80, in: proxy.size
                )
                glow(
                    .violetLight, opacity: 0.26 * strength,
                    center: CGPoint(x: width * 1.22, y: width * 0.12),
                    radius: width * 0.55, in: proxy.size
                )
                glow(
                    colors.isDark ? .violetIndigo : colors.primary,
                    opacity: (colors.isDark ? 0.35 : 0.30) * strength,
                    center: CGPoint(x: width * 0.1, y: proxy.size.height),
                    radius: width * 0.60, in: proxy.size
                )
            }
        }
    }

    private func glow(
        _ color: Color,
        opacity: Double,
        center: CGPoint,
        radius: CGFloat,
        in size: CGSize
    ) -> some View {
        RadialGradient(
            colors: [color.opacity(opacity), color.opacity(0)],
            center: UnitPoint(x: center.x / size.width, y: center.y / size.height),
            startRadius: 0,
            endRadius: radius
        )
    }
}
