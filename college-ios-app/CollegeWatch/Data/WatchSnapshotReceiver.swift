//
//  WatchSnapshotReceiver.swift
//  CollegeWatch
//

import Foundation
import WatchConnectivity

nonisolated final class WatchSnapshotReceiver: NSObject, WCSessionDelegate, Sendable {

    private static let pendingPoll: Duration = .milliseconds(200)
    private static let pendingAttempts = 25

    private let store: WidgetSnapshotStore
    private let onChange: @Sendable () -> Void

    init(store: WidgetSnapshotStore, onChange: @escaping @Sendable () -> Void) {
        self.store = store
        self.onChange = onChange
    }

    func activate() {
        guard WCSession.isSupported() else { return }

        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    func waitForPendingContent() async {
        let session = WCSession.default
        for _ in 0..<Self.pendingAttempts {
            guard session.activationState != .activated || session.hasContentPending else { return }
            try? await Task.sleep(for: Self.pendingPoll)
        }
    }

    private func receive(_ context: [String: Any]) {
        guard let data = context[ScheduleWidgetKey.snapshot] as? Data else { return }

        Task { @MainActor in
            if (try? store.receive(data)) == true {
                onChange()
            }
        }
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        receive(session.receivedApplicationContext)
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        receive(applicationContext)
    }
}
