//
//  PushRoute.swift
//  college-ios-app
//

import Foundation

nonisolated enum PushKind: String, Sendable {
    case published = "schedule_published"
    case changed = "schedule_changed"
}

nonisolated struct PushRoute: Sendable, Equatable {
    let kind: PushKind
    let weekStart: Date

    init(kind: PushKind, weekStart: Date) {
        self.kind = kind
        self.weekStart = weekStart
    }
}
