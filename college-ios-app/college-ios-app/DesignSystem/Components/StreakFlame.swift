//
//  StreakFlame.swift
//  college-ios-app
//

import SwiftUI

private let shiftPeriod: Double = 3.6
private let glowPeriod: Double = 4.2
private let spreadPeriod: Double = 6.5
private let glowRange: ClosedRange<Double> = 0.3...0.48
private let spreadRange: ClosedRange<Double> = 0.42...0.48

private let flameColors: [Color] = [.flameOrange, .flameRed]
private let idleColors: [Color] = [.flameIdle, .flameIdle.opacity(0.7)]

struct StreakFlame: View {
    var diameter: CGFloat = 48
    var frameRate: Double = 30
    var isAnimated: Bool = true
    var isActive: Bool = true

    var body: some View {
        content
            .frame(width: diameter, height: diameter)
    }

    @ViewBuilder
    private var content: some View {
        if isAnimated {
            TimelineView(.animation(minimumInterval: 1 / frameRate)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate

                shape(
                    glow: wave(time / glowPeriod),
                    spread: wave(time / spreadPeriod),
                    shift: wave(time / shiftPeriod)
                )
            }
        } else {
            flame(shift: 0.5)
        }
    }

    private func shape(glow: Double, spread: Double, shift: Double) -> some View {
        ZStack {
            halo(glow: lerp(glowRange, glow), spread: lerp(spreadRange, spread))

            flame(shift: shift)
        }
    }

    private func halo(glow: Double, spread: Double) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    stops: [
                        .init(color: tint.opacity(glow), location: 0),
                        .init(color: tint.opacity(glow * 0.5), location: 0.4),
                        .init(color: tint.opacity(glow * 0.16), location: 0.75),
                        .init(color: .clear, location: 1),
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: diameter * spread
                )
            )
    }

    private func flame(shift: Double) -> some View {
        Image(systemName: "flame.fill")
            .font(.system(size: diameter * 0.5))
            .foregroundStyle(
                LinearGradient(
                    colors: isActive ? flameColors : idleColors,
                    startPoint: UnitPoint(x: 0.5, y: shift * 0.4 - 0.2),
                    endPoint: UnitPoint(x: 0.5, y: shift * 0.4 + 0.8)
                )
            )
    }

    private var tint: Color {
        isActive ? .flameOrange : .flameIdle
    }

    private func wave(_ value: Double) -> Double {
        (1 - cos(value * 2 * .pi)) / 2
    }

    private func lerp(_ range: ClosedRange<Double>, _ value: Double) -> Double {
        range.lowerBound + (range.upperBound - range.lowerBound) * value
    }
}

#Preview("Тёмная") {
    HStack(spacing: 24) {
        StreakFlame(diameter: 36)
        StreakFlame(diameter: 48)
        StreakFlame(diameter: 132, frameRate: 60)
    }
    .padding(40)
    .appBackground()
    .environment(\.colors, .dark)
}

#Preview("Светлая") {
    StreakFlame(diameter: 132, frameRate: 60)
        .padding(40)
        .appBackground()
        .environment(\.colors, .light)
}
