//
//  PushAPI.swift
//  college-ios-app
//

import Foundation

nonisolated protocol PushAPIProtocol: Sendable {
    func registerDevice(token: String, deviceID: String) async throws
    func unregisterDevice(token: String) async throws
}

nonisolated final class PushAPI: PushAPIProtocol {
    private let authenticatedClient: HTTPClientProtocol
    private let publicClient: HTTPClientProtocol

    private static let path = "api/mykct/v1/notifications/devices"

    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }()

    init(authenticatedClient: HTTPClientProtocol, publicClient: HTTPClientProtocol) {
        self.authenticatedClient = authenticatedClient
        self.publicClient = publicClient
    }

    // MARK: - Public endpoints

    func registerDevice(token: String, deviceID: String) async throws {
        struct Body: Encodable { let token: String; let deviceID: String; let platform: String }
        let bodyData = try Self.encoder.encode(
            Body(token: token, deviceID: deviceID, platform: "ios")
        )
        let endpoint = Endpoint(
            path: Self.path,
            method: .post,
            body: bodyData,
            contentType: "application/json"
        )

        do {
            _ = try await authenticatedClient.sendRaw(endpoint)
        } catch {
            CrashlyticsLogger.recordBreadcrumb("Push device registration failed")
            throw error
        }
    }

    func unregisterDevice(token: String) async throws {
        struct Body: Encodable { let token: String }
        let bodyData = try Self.encoder.encode(Body(token: token))
        let endpoint = Endpoint(
            path: Self.path,
            method: .delete,
            body: bodyData,
            contentType: "application/json"
        )

        do {
            _ = try await publicClient.sendRaw(endpoint)
        } catch {
            CrashlyticsLogger.recordBreadcrumb("Push device removal failed")
            throw error
        }
    }
}
