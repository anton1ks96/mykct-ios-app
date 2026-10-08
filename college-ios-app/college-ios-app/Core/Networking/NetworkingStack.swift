//
//  NetworkingStack.swift
//  college-ios-app
//
//  Created by pc on 23.08.2026.
//

import Foundation
import Alamofire

// MARK: - Shared session

public nonisolated enum NetworkingStack {
    public static let requestTimeout: TimeInterval = 30

    public static let session: Session = {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = requestTimeout
        return Session(configuration: configuration, eventMonitors: [AFLogger()])
    }()
}

// MARK: - Logging

nonisolated final class AFLogger: EventMonitor {
    let queue = DispatchQueue(label: "AFLogger")

    func request(_ request: Request, didCreateTask task: URLSessionTask) {
#if DEBUG
        debugPrint(request.description)
#endif
    }

    func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
#if DEBUG
        let code = response.response?.statusCode ?? -1
        debugPrint("[\(code)]", request.description)
        if let data = response.data, let text = String(data: data, encoding: .utf8) {
            debugPrint("Response:", text)
        }
#endif
    }

    func request(_ request: Request, didGatherMetrics metrics: URLSessionTaskMetrics) {
#if DEBUG
        guard let transaction = metrics.transactionMetrics.last else { return }
        let proto = transaction.networkProtocolName ?? "?"
        let connection = transaction.isReusedConnection ? "reused" : "new"
        debugPrint("[\(proto)/\(connection)]", request.description)
#endif
    }
}
