//
//  MonthSummary.swift
//  college-ios-app
//

import SwiftUI

private let summaryRadius: CGFloat = 24
private let ringSide: CGFloat = 96
private let ringWidth: CGFloat = 10
private let edgeOpacity: Double = 0.14

struct MonthSummary: View {
    @Environment(\.colors) private var colors

    let percent: Int
    let caption: String
    let detail: String
    let hasData: Bool

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: summaryRadius, style: .continuous)
    }

    var body: some View {
        HStack(spacing: 18) {
            PercentRing(percent: percent, hasData: hasData)

            VStack(alignment: .leading, spacing: 4) {
                Text(caption)
                    .textStyle(AppType.labelMedium)
                    .foregroundStyle(colors.onSurfaceVariant)

                Text(detail)
                    .textStyle(AppType.bodyMedium)
                    .foregroundStyle(colors.onSurface)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(alignment: .center) { edges }
        .glassSurface(shape)
        .accessibilityElement(children: .combine)
    }

    private var edges: some View {
        LinearGradient(
            colors: [colors.primary.opacity(edgeOpacity), .clear, colors.primary.opacity(edgeOpacity)],
            startPoint: .leading,
            endPoint: .trailing
        )
        .clipShape(shape)
        .accessibilityHidden(true)
    }
}

private struct PercentRing: View {
    @Environment(\.colors) private var colors

    let percent: Int
    let hasData: Bool

    private var value: Double {
        hasData ? Double(percent) / 100 : 0
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(colors.onSurface.opacity(0.12), lineWidth: ringWidth)

            Circle()
                .trim(from: 0, to: value)
                .stroke(successGradient, style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text(hasData ? "\(percent)%" : "—")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(colors.onSurface)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                .padding(.horizontal, ringWidth * 2)
        }
        .frame(width: ringSide, height: ringSide)
        .padding(ringWidth / 2)
        .animation(.easeInOut(duration: 0.7), value: value)
    }
}

#Preview {
    VStack(spacing: 16) {
        MonthSummary(
            percent: 93,
            caption: "Почти идеальный месяц",
            detail: HomeFormat.attended(present: 82, total: 88),
            hasData: true
        )

        MonthSummary(
            percent: 0,
            caption: HomeFormat.monthCaption(.now),
            detail: "Отметок за месяц нет",
            hasData: false
        )
    }
    .padding(20)
    .appBackground()
    .environment(\.colors, .dark)
}
