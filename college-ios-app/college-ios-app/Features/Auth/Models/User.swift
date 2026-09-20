//
//  User.swift
//  college-ios-app
//
//  Created by pc on 17.10.2025.
//

import Foundation

public nonisolated enum UserRole: String, Sendable {
    case student
    case teacher
    case admin
}

public nonisolated struct User: Codable, Equatable, Sendable {
    public let id: String
    public let username: String
    public let role: String?
    public let academicGroup: String?
    public let profile: String?
    public let subgroup: String?
    public let englishGroup: String?

    public var isStudent: Bool {
        role?.lowercased() == UserRole.student.rawValue
    }

    enum CodingKeys: String, CodingKey {
        case id, username, role
        case academicGroup = "academic_group"
        case profile
        case subgroup
        case englishGroup = "english_group"
    }
}
