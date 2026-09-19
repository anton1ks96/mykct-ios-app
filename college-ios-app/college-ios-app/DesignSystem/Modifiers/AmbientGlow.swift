//
//  AmbientGlow.swift
//  college-ios-app
//

import SwiftUI

private let driftPeriod: Double = 90
private let topTravel: ClosedRange<CGFloat> = 0.0...1.0
private let bottomTravel: ClosedRange<CGFloat> = 0.1...1.0
private let frameRate: Double = 8

struct AmbientGlow: View {
    @Environment(\.colors) private var colors

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / frameRate)) { timeline in
            canvas(drift: wave(timeline.date.timeIntervalSinceReferenceDate / driftPeriod))
        }
        .allowsHitTesting(false)
    }

    private func canvas(drift: Double) -> some View {
        Canvas { context, size in
            let width = size.width
            let strength = colors.isDark ? 1.0 : 0.5

            glow(
                in: context, color: colors.primary, opacity: 0.50 * strength,
                center: CGPoint(x: width * lerp(topTravel, 1 - drift), y: -width * 0.05),
                radius: width * 0.80
            )
            glow(
                in: context, color: .violetLight, opacity: 0.26 * strength,
                center: CGPoint(x: width * (lerp(topTravel, 1 - drift) + 0.22), y: width * 0.12),
                radius: width * 0.55
            )
            glow(
                in: context, color: colors.isDark ? .violetIndigo : colors.primary,
                opacity: (colors.isDark ? 0.35 : 0.30) * strength,
                center: CGPoint(x: width * lerp(bottomTravel, drift), y: size.height),
                radius: width * 0.60
            )
        }
    }

    private func lerp(_ range: ClosedRange<CGFloat>, _ value: Double) -> CGFloat {
        range.lowerBound + (range.upperBound - range.lowerBound) * CGFloat(value)
    }

    private func wave(_ value: Double) -> Double {
        (1 - cos(value * 2 * .pi)) / 2
    }

    private func glow(
        in context: GraphicsContext,
        color: Color,
        opacity: Double,
        center: CGPoint,
        radius: CGFloat
    ) {
        let rect = CGRect(
            x: center.x - radius, y: center.y - radius,
            width: radius * 2, height: radius * 2
        )
        context.fill(
            Path(ellipseIn: rect),
            with: .radialGradient(
                Gradient(colors: [color.opacity(opacity), color.opacity(0)]),
                center: center,
                startRadius: 0,
                endRadius: radius
            )
        )
    }
}
