//
//  AuthAPI.swift
//  college-ios-app
//
//  Created by pc on 18.10.2025.
//

import Foundation

public nonisolated protocol AuthAPIProtocol: Sendable {
    func signIn(username: String, password: String) async throws -> SignInResponse
    func getAccessToken(refreshToken: String) async throws -> AccessTokenResponse
    func refreshRefreshToken(refreshToken: String) async throws -> RefreshTokenResponse
    func signOut(refreshToken: String) async throws
}

public nonisolated final class AuthAPI: AuthAPIProtocol {
    private let client: AFHTTPClient
    
    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }()
    
    public init(client: AFHTTPClient) {
        self.client = client
    }
    
    // MARK: - Public endpoints
    
    public func signIn(username: String, password: String) async throws -> SignInResponse {
        struct Body: Encodable { let username: String; let password: String }
        let bodyData = try Self.encoder.encode(Body(username: username, password: password))
        let endpoint = Endpoint(
            path: "auth/api/v1/app/signin",
            method: .post,
            body: bodyData,
            contentType: "application/json"
        )

        do {
            return try await client.send(endpoint)
        } catch {
            // IMPORTANT: Do NOT log username or password
            CrashlyticsLogger.logAuthError(error, operation: "signin")
            throw error
        }
    }
    
    public func getAccessToken(refreshToken: String) async throws -> AccessTokenResponse {
        struct Body: Encodable { let refreshToken: String }
        let bodyData = try Self.encoder.encode(Body(refreshToken: refreshToken))
        let endpoint = Endpoint(
            path: "auth/api/v1/app/access",
            method: .post,
            body: bodyData,
            contentType: "application/json"
        )

        do {
            return try await client.send(endpoint)
        } catch {
            // IMPORTANT: Do NOT log refresh token
            CrashlyticsLogger.logAuthError(error, operation: "get_access_token")
            throw error
        }
    }
    
    public func refreshRefreshToken(refreshToken: String) async throws -> RefreshTokenResponse {
        struct Body: Encodable { let refreshToken: String }
        let bodyData = try Self.encoder.encode(Body(refreshToken: refreshToken))
        let endpoint = Endpoint(
            path: "auth/api/v1/app/refresh",
            method: .post,
            body: bodyData,
            contentType: "application/json"
        )

        do {
            return try await client.send(endpoint)
        } catch {
            // IMPORTANT: Do NOT log refresh token
            CrashlyticsLogger.logAuthError(error, operation: "refresh_refresh_token")
            throw error
        }
    }
    
    public func signOut(refreshToken: String) async throws {
        struct Body: Encodable { let refreshToken: String }
        struct Empty: Decodable {}
        let bodyData = try Self.encoder.encode(Body(refreshToken: refreshToken))
        let endpoint = Endpoint(
            path: "auth/api/v1/app/signout",
            method: .post,
            body: bodyData,
            contentType: "application/json"
        )

        do {
            let _: Empty = try await client.send(endpoint)
        } catch {
            // IMPORTANT: Do NOT log refresh token
            CrashlyticsLogger.logAuthError(error, operation: "signout")
            throw error
        }
    }
}
