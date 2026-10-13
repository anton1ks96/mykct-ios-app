//
//  Selection.swift
//  college-ios-app
//

import Foundation

nonisolated struct Selection: Equatable, Codable, Sendable {
    var group: String
    var subgroup: String?
    var englishGroup: String?
    var profileSubgroup: String?

    init(
        group: String,
        subgroup: String? = nil,
        englishGroup: String? = nil,
        profileSubgroup: String? = nil
    ) {
        self.group = group
        self.subgroup = subgroup
        self.englishGroup = englishGroup
        self.profileSubgroup = profileSubgroup
    }

    var label: String {
        [group, subgroup, profileSubgroup, englishGroup]
            .compactMap { $0 }
            .joined(separator: " · ")
    }
}

nonisolated extension Selection {

    static let fallback = Selection(group: Groups.all[0])

    func withGroup(_ group: String) -> Selection {
        Selection(group: group)
    }

    func withSubgroup(_ subgroup: String?) -> Selection {
        Selection(
            group: group,
            subgroup: subgroup,
            englishGroup: englishGroup,
            profileSubgroup: Groups.profileSubgroups(of: group, subgroup: subgroup).isEmpty
                ? nil
                : profileSubgroup
        )
    }
}
