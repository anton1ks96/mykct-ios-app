//
//  ErrorText.swift
//  college-ios-app
//

import Foundation

nonisolated enum ErrorText {

    static func isCancellation(_ error: Error) -> Bool {
        if error is CancellationError { return true }
        if case APIError.cancelled = error { return true }
        return false
    }

    static func isConnectivity(_ error: Error) -> Bool {
        switch error {
        case APIError.url, APIError.transport, is URLError:
            return true
        default:
            return false
        }
    }

    static func isFeatureDisabled(_ error: Error) -> Bool {
        if case let APIError.api(code, _, _) = error { return code == "FEATURE_DISABLED" }
        return false
    }

    static func message(for error: Error) -> String? {
        (error as? LocalizedError)?.errorDescription
    }
}
