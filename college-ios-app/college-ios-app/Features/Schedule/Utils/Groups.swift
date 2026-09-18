//
//  Groups.swift
//  college-ios-app
//

import Foundation

nonisolated enum Groups {

    struct Named: Identifiable, Equatable, Sendable {
        let id: String
        let title: String
    }

    static let firstYear = 26

    static let all: [String] = [(26, 4), (25, 4), (24, 4), (23, 3)]
        .flatMap { year, count in (1...count).map { "ИТ\(year)-1\($0)" } }

    static func subgroups(of group: String) -> [Named] {
        course(of: group) == 1 ? numbered(2) : profiles
    }

    static func englishGroups(of group: String) -> [String] {
        course(of: group).flatMap { english[$0] } ?? []
    }

    static func profileSubgroups(of group: String, subgroup: String?) -> [Named] {
        guard let course = course(of: group), course > 1,
              let subgroup, profilesWithSubgroups.contains(subgroup)
        else { return [] }

        return numbered(2)
    }

    private static func numbered(_ count: Int) -> [Named] {
        (1...count).map { Named(id: "Подгр\($0)", title: "Подгруппа \($0)") }
    }

    private static func course(of group: String) -> Int? {
        guard let year = Int(group.dropFirst(2).prefix(2)) else { return nil }
        let course = firstYear - year + 1
        return english.keys.contains(course) ? course : nil
    }

    private static let profiles: [Named] = [
        Named(id: "BE", title: "Backend"),
        Named(id: "FE", title: "Frontend"),
        Named(id: "GD", title: "Game Dev"),
        Named(id: "PM", title: "Project Management"),
        Named(id: "SA", title: "System Administration"),
        Named(id: "CD", title: "UX/UI Design"),
    ]

    private static let profilesWithSubgroups: Set<String> = ["FE", "CD"]

    private static let english: [Int: [String]] = [
        1: ["A0.11", "A0.12", "A1.11", "A1.12", "A2.11", "A2.12", "B1.11", "B1.12"],
        2: ["A0.21", "A0.22", "A1.21", "A1.22", "A2.21", "A2.22", "B1.21", "B1.22"],
        3: ["A1.31", "A2.31", "B1.31", "B2.31"],
        4: ["A1.41", "A2.41", "B1.41"],
    ]
}
