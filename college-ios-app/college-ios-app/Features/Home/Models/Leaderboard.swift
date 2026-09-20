//
//  Leaderboard.swift
//  college-ios-app
//

import Foundation

nonisolated struct LeaderboardEntry: Equatable, Sendable {
    let rank: Int
    let alias: String
    let streak: Int
    let isMe: Bool
}

nonisolated struct Leaderboard: Equatable, Sendable {
    let top: [LeaderboardEntry]
    let me: LeaderboardEntry
    let participants: Int

    var isMeInTop: Bool { top.contains { $0.isMe } }
}
