//
//  LeaderboardBoard.swift
//  college-ios-app
//

import SwiftUI

struct LeaderboardBoard: View {
    @Environment(\.colors) private var colors

    let board: Leaderboard

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeroSummary(
                caption: HomeFormat.cohort(participants: board.participants),
                value: HomeFormat.place(board.me.rank),
                subtitle: board.me.alias
            )

            GlassGroup(spacing: 8) {
                VStack(spacing: 8) {
                    ForEach(board.top.indices, id: \.self) { index in
                        LeaderboardRow(entry: board.top[index])
                    }

                    if !board.isMeInTop {
                        gap
                        LeaderboardRow(entry: board.me)
                    }
                }
            }

            Text("Рейтинг анонимный: за псевдонимами не видно ни имён, ни групп")
                .textStyle(AppType.labelMedium)
                .foregroundStyle(colors.onSurfaceVariant)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var gap: some View {
        Image(systemName: "ellipsis")
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(colors.onSurfaceVariant)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 2)
            .accessibilityHidden(true)
    }
}

#Preview {
    ScrollView {
        LeaderboardBoard(board: HomeMocks.leaderboard)
            .padding(20)
    }
    .appBackground()
    .environment(\.colors, .dark)
}
