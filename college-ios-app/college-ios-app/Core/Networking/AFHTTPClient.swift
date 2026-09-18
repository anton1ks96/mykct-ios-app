//
//  AFHTTPClient.swift
//  college-ios-app
//
//  Created by pc on 21.09.2025.
//

import Foundation
import Alamofire

// MARK: - CrashlyticsLogger Availability Check

#if canImport(FirebaseCrashlytics)
// CrashlyticsLogger is available from Utils/CrashlyticsLogger.swift
#else
nonisolated enum CrashlyticsLogger {
    static func logError(_ error: Error, context: String? = nil, customKeys: [String: Any]? = nil) {}
    static func logFatalError(_ message: String, customKeys: [String: Any]? = nil) {}
    static func logNetworkError(_ error: Error, endpoint: String, method: String = "GET", statusCode: Int? = nil) {}
    static func logAuthError(_ error: Error, operation: String, userId: String? = nil) {}
    static func logKeychainError(operation: String, status: OSStatus, key: String) {}
    static func logDataError(_ error: Error, operation: String, dataType: String) {}
    static func setCustomKeys(_ keys: [String: Any]) {}
    static func recordBreadcrumb(_ message: String) {}
    static func setUserIdentifier(_ userId: String?) {}
    static func setAppState(appVersion: String, buildNumber: String, environment: String) {}
}
#endif

// MARK: - HTTP Method
public nonisolated enum HTTPMethod: String, Sendable {
    case get = "GET", post = "POST", put = "PUT", delete = "DELETE"
}

// MARK: - Endpoint
public nonisolated struct Endpoint: Sendable {
    public var path: String
    public var method: HTTPMethod
    public var queryItems: [URLQueryItem] = []
    public var headers: [String: String] = [:]
    public var body: Data? = nil
    public var contentType: String? = nil
    
    public init(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil,
        contentType: String? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
        self.contentType = contentType
    }
}

// MARK: - Protocol
public nonisolated protocol HTTPClientProtocol: Sendable {
    func send<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T
    func sendRaw(_ endpoint: Endpoint) async throws -> (Data, HTTPURLResponse)
}

// MARK: - build URL
private struct AFEndpointRequest: URLRequestConvertible {
    let baseURL: URL
    let endpoint: Endpoint
    let timeout: TimeInterval
    let combinedHeaders: [String: String]
    
    func asURLRequest() throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidBaseURL
        }
        let cleanPath = endpoint.path.hasPrefix("/") ? String(endpoint.path.dropFirst()) : endpoint.path
        components.path = components.path.appending("/").appending(cleanPath)
        if !endpoint.queryItems.isEmpty { components.queryItems = endpoint.queryItems }
        guard let url = components.url else { throw APIError.invalidBaseURL }
        
        var req = URLRequest(url: url, timeoutInterval: timeout)
        req.httpMethod = endpoint.method.rawValue
        endpoint.body.map { req.httpBody = $0 }
        if let ct = endpoint.contentType { req.setValue(ct, forHTTPHeaderField: "Content-Type") }
        combinedHeaders.forEach { key, value in req.setValue(value, forHTTPHeaderField: key) }
        return req
    }
}

// MARK: - Alamofire client
public nonisolated final class AFHTTPClient: HTTPClientProtocol {
    private let baseURL: URL
    private let session: Session
    private let decoder: JSONDecoder
    private let defaultHeaders: HTTPHeaders
    private let requestTimeout: TimeInterval
    private let interceptor: RequestInterceptor?

    public init(
        baseURL: URL,
        session: Session = NetworkingStack.session,
        decoder: JSONDecoder = JSONDecoder(),
        defaultHeaders: [String: String] = ["Accept": "application/json"],
        requestTimeout: TimeInterval = NetworkingStack.requestTimeout,
        interceptor: RequestInterceptor? = nil
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.defaultHeaders = HTTPHeaders(defaultHeaders)
        self.requestTimeout = requestTimeout
        self.interceptor = interceptor
    }
    
    public func send<T: Decodable>(_ endpoint: Endpoint, as type: T.Type = T.self) async throws -> T {
        let (data, _) = try await sendRaw(endpoint)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
#if DEBUG
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Decoding failed for \(T.self)")
                print("Response JSON:", jsonString)
                print("Error:", error)
            }
#endif
            
            CrashlyticsLogger.logDataError(
                error,
                operation: "decoding",
                dataType: String(describing: T.self)
            )
            CrashlyticsLogger.setCustomKeys([
                "endpoint_path": endpoint.path,
                "endpoint_method": endpoint.method.rawValue,
                "response_data_size": data.count
            ])
            
            throw APIError.decodingFailed
        }
    }
    
    public func sendRaw(_ endpoint: Endpoint) async throws -> (Data, HTTPURLResponse) {
        if Task.isCancelled { throw APIError.cancelled }
        
        var headers = defaultHeaders
        endpoint.headers.forEach { headers.add(name: $0.key, value: $0.value) }
        if let ct = endpoint.contentType { headers.add(name: "Content-Type", value: ct) }
        
        let convertible = AFEndpointRequest(
            baseURL: baseURL,
            endpoint: endpoint,
            timeout: requestTimeout,
            combinedHeaders: headers.dictionary
        )
        
        let dataTask = session.request(convertible, interceptor: interceptor)
            .serializingData()
        
        do {
            let response = await dataTask.response
            if let error = response.error, error.isExplicitlyCancelledError {
                throw APIError.cancelled
            }
            if Task.isCancelled {
                throw APIError.cancelled
            }
            guard let http = response.response else {
                let urlError = URLError(.badServerResponse)
                CrashlyticsLogger.logNetworkError(
                    urlError,
                    endpoint: endpoint.path,
                    method: endpoint.method.rawValue
                )
                throw APIError.url(urlError)
            }
            guard (200...299).contains(http.statusCode) else {
                let statusError = NSError(
                    domain: "HTTPStatusCodeError",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"]
                )
                CrashlyticsLogger.logNetworkError(
                    statusError,
                    endpoint: endpoint.path,
                    method: endpoint.method.rawValue,
                    statusCode: http.statusCode
                )
                throw APIError.from(statusCode: http.statusCode, data: response.data)
            }
            if let error = response.error {
                CrashlyticsLogger.logNetworkError(
                    error,
                    endpoint: endpoint.path,
                    method: endpoint.method.rawValue,
                    statusCode: http.statusCode
                )
                throw APIError.transport(error)
            }
            return (response.data ?? Data(), http)
        } catch {
            let isCancelled: Bool = {
                if error is CancellationError { return true }
                if error.asAFError?.isExplicitlyCancelledError == true { return true }
                if case APIError.cancelled = error { return true }
                return false
            }()
            
            if let afErr = error.asAFError {
                if afErr.isExplicitlyCancelledError || error is CancellationError { throw APIError.cancelled }
                if case let .sessionTaskFailed(underlyingError) = afErr,
                   let urlErr = underlyingError as? URLError {
                    if !isCancelled {
                        CrashlyticsLogger.logNetworkError(
                            urlErr,
                            endpoint: endpoint.path,
                            method: endpoint.method.rawValue
                        )
                    }
                    throw APIError.url(urlErr)
                }
            }
            if let urlErr = error as? URLError {
                if !isCancelled {
                    CrashlyticsLogger.logNetworkError(
                        urlErr,
                        endpoint: endpoint.path,
                        method: endpoint.method.rawValue
                    )
                }
                throw APIError.url(urlErr)
            }
            if error is CancellationError { throw APIError.cancelled }
            
            if !isCancelled {
                CrashlyticsLogger.logNetworkError(
                    error,
                    endpoint: endpoint.path,
                    method: endpoint.method.rawValue
                )
            }
            throw error
        }
    }
}
