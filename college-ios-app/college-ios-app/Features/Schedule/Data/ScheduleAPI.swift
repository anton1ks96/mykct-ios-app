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
        let endpoint = Endpoint(
            path: ScheduleQuery.path,
            method: .get,
            queryItems: ScheduleQuery.items(selection: selection, start: start, end: end)
        )
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
}
