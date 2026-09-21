//
//  APIError.swift
//  college-ios-app
//
//  Created by pc on 18.10.2025.
//

import Foundation

nonisolated struct APIErrorBody: Decodable, Sendable {
    let code: String
    let message: String
}

public enum APIError: LocalizedError, Sendable {
    // Network & Request errors
    case invalidBaseURL
    case requestBuildFailed
    case cancelled
    
    // Response errors
    case decodingFailed
    case unauthorized(message: String?)
    case forbidden
    case notFound
    case server(code: Int)
    case statusCode(Int, Data?)
    case api(code: String, message: String, status: Int)
    
    // Transport errors
    case transport(Error)
    case url(URLError)
    
    // Auth specific errors
    case missingRefreshToken
    case refreshFailed
    case keychainError(status: OSStatus)
    
    public static func from(statusCode: Int, data: Data?) -> APIError {
        let body = data.flatMap { try? JSONDecoder().decode(APIErrorBody.self, from: $0) }

        switch statusCode {
        case 401: return .unauthorized(message: body?.message)
        case 403: return .forbidden
        default: break
        }

        if let body {
            return .api(code: body.code, message: body.message, status: statusCode)
        }

        switch statusCode {
        case 404: return .notFound
        case 500...599: return .server(code: statusCode)
        default: return .statusCode(statusCode, data)
        }
    }

    public var errorDescription: String? {
        switch self {
        case .invalidBaseURL: return "Неверный адрес сервера"
        case .requestBuildFailed: return "Не удалось собрать запрос"
        case .cancelled: return "Запрос отменён"
        case .decodingFailed: return "Не удалось разобрать ответ сервера"
        case .unauthorized(let message): return message ?? "Требуется авторизация"
        case .forbidden: return "Доступ запрещён"
        case .notFound: return "Ресурс не найден"
        case .server(let code): return "Ошибка сервера (\(code))"
        case .statusCode(let code, _): return "Сервер вернул код \(code)"
        case .api(_, let message, _): return message
        case .transport(let err): return "Сетевая ошибка: \(err.localizedDescription)"
        case .url(let err): return err.localizedDescription
        case .missingRefreshToken: return "Refresh-токен отсутствует"
        case .refreshFailed: return "Не удалось обновить токены"
        case .keychainError(let status): return "Ошибка Keychain (status: \(status))"
        }
    }
}
