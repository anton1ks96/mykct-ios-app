//
//  PushMocks.swift
//  college-ios-app
//

#if DEBUG
import Foundation

nonisolated final class MockPushAPI: PushAPIProtocol {

    func registerDevice(token: String, deviceID: String) async throws {}

    func unregisterDevice(token: String) async throws {}
}
#endif
