//
//  CollegeWatchApp.swift
//  CollegeWatch
//

import SwiftUI

@main
struct CollegeWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchRoot(schedule: WatchDependencies.schedule)
        }
    }
}
