//
//  ScheduleAPI.swift
//  college-ios-app
//

import Foundation

nonisolated protocol ScheduleAPIProtocol: Sendable {
    func schedule(selection: Selection, start: Date, end: Date) async throws -> ScheduleResponse
    func classDetails(id: String) async throws -> JSONValue
}

nonisolated final class ScheduleAPI: ScheduleAPIProtocol {

    private let client: HTTPClientProtocol

    init(client: HTTPClientProtocol) {
        self.client = client
    }

    func schedule(selection: Selection, start: Date, end: Date) async throws -> ScheduleResponse {
        var queryItems = [
            URLQueryItem(name: "group", value: selection.group),
            URLQueryItem(name: "start", value: ScheduleParsing.requestString(from: start)),
            URLQueryItem(name: "end", value: ScheduleParsing.requestString(from: end)),
        ]
        appendIfPresent("subgroup", selection.subgroup, to: &queryItems)
        appendIfPresent("english_group", selection.englishGroup, to: &queryItems)
        appendIfPresent("profile_subgroup", selection.profileSubgroup, to: &queryItems)

        let endpoint = Endpoint(path: "/api/mykct/v1/schedule", method: .get, queryItems: queryItems)
        return try await client.send(endpoint, as: ScheduleResponse.self)
    }

    func classDetails(id: String) async throws -> JSONValue {
        let endpoint = Endpoint(
            path: "/api/mykct/v1/classdetails",
            method: .get,
            queryItems: [URLQueryItem(name: "id", value: id)]
        )
        return try await client.send(endpoint, as: JSONValue.self)
    }

    private func appendIfPresent(_ name: String, _ value: String?, to items: inout [URLQueryItem]) {
        guard let value, !value.isEmpty, value != "*" else { return }
        items.append(URLQueryItem(name: name, value: value))
    }
}
