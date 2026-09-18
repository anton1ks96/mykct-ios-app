//
//  Attendance.swift
//  college-ios-app
//

import Foundation

nonisolated enum Attendance: Equatable, Sendable {
    case present
    case excused
    case absent
    case unknown

    static func of(status: Int) -> Attendance {
        switch status {
        case 2: .present
        case 1: .excused
        case 0: .absent
        default: .unknown
        }
    }

    var short: String {
        switch self {
        case .present: "Был"
        case .excused: "Ув."
        case .absent: "Н/У"
        case .unknown: "—"
        }
    }

    var title: String {
        switch self {
        case .present: "Был"
        case .excused: "Не был (Ув.)"
        case .absent: "Не был (Н/У)"
        case .unknown: "Неизвестно"
        }
    }
}

nonisolated struct AttendanceRecord: Identifiable, Equatable, Sendable {
    let id: String
    let date: Date
    let start: Int?
    let end: Int?
    let title: String
    let topic: String
    let room: String
    let attendance: Attendance
}

nonisolated struct AttendanceStats: Equatable, Sendable {
    let total: Int
    let present: Int
    let absent: Int
    let excused: Int

    static let empty = AttendanceStats(total: 0, present: 0, absent: 0, excused: 0)

    var percent: Int {
        total > 0 ? present * 100 / total : 0
    }

    static func of(_ records: [AttendanceRecord]) -> AttendanceStats {
        let marked = records.filter { $0.attendance != .unknown }

        return AttendanceStats(
            total: marked.count,
            present: marked.count(where: { $0.attendance == .present }),
            absent: marked.count(where: { $0.attendance == .absent }),
            excused: marked.count(where: { $0.attendance == .excused })
        )
    }
}

nonisolated struct AttendanceDay: Identifiable, Equatable, Sendable {
    let date: Date
    let records: [AttendanceRecord]

    var id: Date { date }

    var present: Int {
        records.count(where: { $0.attendance == .present })
    }
}
