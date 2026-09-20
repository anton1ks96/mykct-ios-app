//
//  HomeDTO.swift
//  college-ios-app
//

import Foundation

nonisolated struct AttendanceDTO: Decodable, Sendable {
    let clID: String
    let day: String
    let start: String
    let end: String
    let title: String
    let topic: String
    let room: String
    let status: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let number = try? container.decode(Int.self, forKey: .clID) {
            clID = String(number)
        } else {
            clID = (try? container.decode(String.self, forKey: .clID)) ?? ""
        }
        day = try container.decodeIfPresent(String.self, forKey: .day) ?? ""
        start = try container.decodeIfPresent(String.self, forKey: .start) ?? ""
        end = try container.decodeIfPresent(String.self, forKey: .end) ?? ""
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        topic = try container.decodeIfPresent(String.self, forKey: .topic) ?? ""
        room = try container.decodeIfPresent(String.self, forKey: .room) ?? ""
        status = try container.decodeIfPresent(Int.self, forKey: .status) ?? -1
    }

    enum CodingKeys: String, CodingKey {
        case clID = "ClID"
        case day = "Day"
        case start, end, title, topic, room, status
    }
}

nonisolated struct StreakDTO: Decodable, Sendable {
    let current: Int
    let longest: Int
    let daysAttended: Int
    let schoolDays: Int
    let lastAttended: String
    let periodStart: String
    let periodEnd: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        current = try container.decodeIfPresent(Int.self, forKey: .current) ?? 0
        longest = try container.decodeIfPresent(Int.self, forKey: .longest) ?? 0
        daysAttended = try container.decodeIfPresent(Int.self, forKey: .daysAttended) ?? 0
        schoolDays = try container.decodeIfPresent(Int.self, forKey: .schoolDays) ?? 0
        lastAttended = try container.decodeIfPresent(String.self, forKey: .lastAttended) ?? ""
        periodStart = try container.decodeIfPresent(String.self, forKey: .periodStart) ?? ""
        periodEnd = try container.decodeIfPresent(String.self, forKey: .periodEnd) ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case current = "current_streak"
        case longest = "longest_streak"
        case daysAttended = "total_days_attended"
        case schoolDays = "total_school_days"
        case lastAttended = "last_attended_date"
        case periodStart = "period_start"
        case periodEnd = "period_end"
    }
}

nonisolated struct LeaderboardEntryDTO: Decodable, Sendable {
    let rank: Int
    let alias: String
    let streak: Int
    let isMe: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rank = try container.decodeIfPresent(Int.self, forKey: .rank) ?? 0
        alias = try container.decodeIfPresent(String.self, forKey: .alias) ?? ""
        streak = try container.decodeIfPresent(Int.self, forKey: .streak) ?? 0
        isMe = try container.decodeIfPresent(Bool.self, forKey: .isMe) ?? false
    }

    enum CodingKeys: String, CodingKey {
        case rank, alias
        case streak = "current_streak"
        case isMe = "is_me"
    }
}

nonisolated struct LeaderboardDTO: Decodable, Sendable {
    let top: [LeaderboardEntryDTO]
    let me: LeaderboardEntryDTO?
    let participants: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        top = try container.decodeIfPresent([LeaderboardEntryDTO].self, forKey: .top) ?? []
        me = try container.decodeIfPresent(LeaderboardEntryDTO.self, forKey: .me)
        participants = try container.decodeIfPresent(Int.self, forKey: .participants) ?? 0
    }

    enum CodingKeys: String, CodingKey {
        case top, me, participants
    }
}

nonisolated struct SubjectDTO: Decodable, Sendable {
    let suID: String
    let title: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let number = try? container.decode(Int.self, forKey: .suID) {
            suID = String(number)
        } else {
            suID = (try? container.decode(String.self, forKey: .suID)) ?? ""
        }
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case suID = "SuID"
        case title = "Title"
    }
}

nonisolated struct ScoreDTO: Decodable, Sendable {
    let dateF: String
    let dateP: String
    let score: String
    let max: Int
    let details: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dateF = try container.decodeIfPresent(String.self, forKey: .dateF) ?? ""
        dateP = try container.decodeIfPresent(String.self, forKey: .dateP) ?? ""
        if let number = try? container.decode(Int.self, forKey: .score) {
            score = String(number)
        } else {
            score = (try? container.decode(String.self, forKey: .score)) ?? ""
        }
        max = try container.decodeIfPresent(Int.self, forKey: .max) ?? 0
        details = try container.decodeIfPresent(String.self, forKey: .details) ?? ""
    }

    enum CodingKeys: String, CodingKey {
        case dateF = "DateF"
        case dateP = "DateP"
        case score = "Score"
        case max = "MaxScore"
        case details = "Description"
    }
}

nonisolated struct ScoresResponse: Decodable, Sendable {
    let subjects: [String: [String: [ScoreDTO]]]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)
        var subjects: [String: [String: [ScoreDTO]]] = [:]

        for subjectKey in container.allKeys {
            guard let lessons = try? container.nestedContainer(
                keyedBy: AnyCodingKey.self,
                forKey: subjectKey
            ) else { continue }

            var byLesson: [String: [ScoreDTO]] = [:]
            for lessonKey in lessons.allKeys {
                guard let scores = try? lessons.decode([ScoreDTO].self, forKey: lessonKey) else { continue }
                byLesson[lessonKey.stringValue] = scores
            }
            subjects[subjectKey.stringValue] = byLesson
        }

        self.subjects = subjects
    }
}

nonisolated struct ScoreRequestDTO: Encodable, Sendable {
    let suID: String
    let datastart: String
    let dataend: String

    enum CodingKeys: String, CodingKey {
        case suID = "SuID"
        case datastart, dataend
    }
}
