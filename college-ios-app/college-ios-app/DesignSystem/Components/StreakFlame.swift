//
//  StreakFlame.swift
//  college-ios-app
//

import SwiftUI

private let shiftPeriod: Double = 2.4
private let glowPeriod: Double = 1.5
private let spreadPeriod: Double = 2.1
private let glowRange: ClosedRange<Double> = 0.22...0.6
private let spreadRange: ClosedRange<Double> = 0.38...0.5

private let flameColors: [Color] = [
    .flameTint, .flameLight, .flame, .flameDeep, .flame, .flameLight, .flameTint,
]

struct StreakFlame: View {
    var diameter: CGFloat = 48
    var frameRate: Double = 30

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / frameRate)) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate

            ZStack {
                halo(
                    glow: lerp(glowRange, ease(triangle(time / glowPeriod))),
                    spread: lerp(spreadRange, ease(triangle(time / spreadPeriod)))
                )

                flame(shift: triangle(time / shiftPeriod))
            }
        }
        .frame(width: diameter, height: diameter)
    }

    private func halo(glow: Double, spread: Double) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    stops: [
                        .init(color: .flameLight.opacity(glow), location: 0),
                        .init(color: .flameLight.opacity(glow * 0.5), location: 0.4),
                        .init(color: .flameLight.opacity(glow * 0.16), location: 0.75),
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
                    colors: flameColors,
                    startPoint: UnitPoint(x: 0.5, y: shift - 1),
                    endPoint: UnitPoint(x: 0.5, y: shift + 0.6)
                )
            )
    }

    private func triangle(_ value: Double) -> Double {
        let phase = value.truncatingRemainder(dividingBy: 2)
        return phase < 1 ? phase : 2 - phase
    }

    private func ease(_ value: Double) -> Double {
        value * value * (3 - 2 * value)
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
