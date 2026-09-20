//
//  HomeAPI.swift
//  college-ios-app
//

import Foundation

nonisolated protocol HomeAPIProtocol: Sendable {
    func attendance(start: Date, end: Date) async throws -> [AttendanceDTO]
    func streak() async throws -> StreakDTO
    func leaderboard() async throws -> LeaderboardDTO
    func subjects() async throws -> [SubjectDTO]
    func scores(subjectID: String, start: Date, end: Date) async throws -> ScoresResponse
}

nonisolated final class HomeAPI: HomeAPIProtocol {

    private let client: HTTPClientProtocol
    private let encoder: JSONEncoder

    init(client: HTTPClientProtocol, encoder: JSONEncoder = JSONEncoder()) {
        self.client = client
        self.encoder = encoder
    }

    func attendance(start: Date, end: Date) async throws -> [AttendanceDTO] {
        let endpoint = Endpoint(
            path: "/api/mykct/v1/attendance",
            method: .get,
            queryItems: [
                URLQueryItem(name: "start", value: ScheduleParsing.requestString(from: start)),
                URLQueryItem(name: "end", value: ScheduleParsing.requestString(from: end)),
            ]
        )
        return try await client.send(endpoint, as: [AttendanceDTO]?.self) ?? []
    }

    func streak() async throws -> StreakDTO {
        let endpoint = Endpoint(path: "/api/mykct/v1/attendance/streak", method: .get)
        return try await client.send(endpoint, as: StreakDTO.self)
    }

    func leaderboard() async throws -> LeaderboardDTO {
        let endpoint = Endpoint(path: "/api/mykct/v1/attendance/leaderboard", method: .get)
        return try await client.send(endpoint, as: LeaderboardDTO.self)
    }

    func subjects() async throws -> [SubjectDTO] {
        let endpoint = Endpoint(path: "/api/mykct/v1/performance/subjects", method: .get)
        return try await client.send(endpoint, as: [SubjectDTO]?.self) ?? []
    }

    func scores(subjectID: String, start: Date, end: Date) async throws -> ScoresResponse {
        let request = ScoreRequestDTO(
            suID: subjectID,
            datastart: ScheduleParsing.requestString(from: start),
            dataend: ScheduleParsing.requestString(from: end)
        )
        let endpoint = Endpoint(
            path: "/api/mykct/v1/performance/score",
            method: .post,
            body: try encoder.encode(request),
            contentType: "application/json"
        )
        return try await client.send(endpoint, as: ScoresResponse.self)
    }
}
