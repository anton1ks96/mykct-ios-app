//
//  WatchSnapshotSender.swift
//  college-ios-app
//

import Foundation
import WatchConnectivity

nonisolated final class WatchSnapshotSender: NSObject, WCSessionDelegate, Sendable {

    private let store: WidgetSnapshotStore

    init(store: WidgetSnapshotStore) {
        self.store = store
    }

    func activate() {
        guard WCSession.isSupported() else { return }

        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    func send() {
        guard WCSession.isSupported() else { return }

        let session = WCSession.default
        guard session.activationState == .activated,
              session.isPaired,
              session.isWatchAppInstalled,
              let data = store.data(),
              session.applicationContext[ScheduleWidgetKey.snapshot] as? Data != data
        else { return }

        do {
            try session.updateApplicationContext([ScheduleWidgetKey.snapshot: data])
        } catch {
            CrashlyticsLogger.logDataError(
                error,
                operation: "send_watch_snapshot",
                dataType: "WidgetSnapshot"
            )
        }
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error {
            CrashlyticsLogger.logError(error, context: "watch_session_activation")
            return
        }
        send()
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        send()
    }
}
