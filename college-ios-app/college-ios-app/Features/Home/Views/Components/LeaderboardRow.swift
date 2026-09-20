//
//  LeaderboardRow.swift
//  college-ios-app
//

import SwiftUI

private let rowRadius: CGFloat = 18
private let rankSide: CGFloat = 36

struct LeaderboardRow: View {
    @Environment(\.colors) private var colors

    let entry: LeaderboardEntry

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: rowRadius, style: .continuous)
    }

    private var foreground: Color {
        entry.isMe ? colors.onTertiary : colors.onSurface
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("\(entry.rank)")
                .textStyle(AppType.labelLarge)
                .fontWeight(.bold)
                .foregroundStyle(entry.isMe ? colors.onTertiary : colors.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(width: rankSide, height: rankSide)
                .background(
                    entry.isMe ? colors.onTertiary.opacity(0.22) : colors.primary.opacity(0.14),
                    in: Circle()
                )

            Text(entry.alias)
                .textStyle(AppType.bodyLarge)
                .foregroundStyle(foreground)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 2) {
                Text("\(entry.streak)")
                    .textStyle(AppType.titleMedium)
                    .fontWeight(.bold)
                    .foregroundStyle(foreground)

                StreakFlame(diameter: 22, isAnimated: false, isActive: entry.streak > 0)
            }
        }
        .padding(16)
        .glassSurface(shape, tint: entry.isMe ? colors.primary : nil)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
    }

    private var label: String {
        let streak = "\(ScheduleFormat.daysCount(entry.streak)) подряд"
        let place = "\(HomeFormat.place(entry.rank)), \(entry.alias), \(streak)"
        return entry.isMe ? "Ты: \(place)" : place
    }
}

#Preview {
    GlassGroup(spacing: 8) {
        VStack(spacing: 8) {
            ForEach(HomeMocks.leaderboard.top.indices, id: \.self) { index in
                LeaderboardRow(entry: HomeMocks.leaderboard.top[index])
            }

            LeaderboardRow(entry: HomeMocks.leaderboard.me)
        }
    }
    .padding(20)
    .appBackground()
    .environment(\.colors, .dark)
}
