//
//  CollegeWatchApp.swift
//  CollegeWatch
//

import SwiftUI

@main
struct CollegeWatchApp: App {
    private let receiver = WatchDependencies.receiver

    init() {
        receiver.activate()
    }

    var body: some Scene {
        WindowGroup {
            WatchRoot(schedule: WatchDependencies.schedule)
        }
        .backgroundTask(.watchConnectivity) { [receiver] in
            await receiver.waitForPendingContent()
        }
    }
}
