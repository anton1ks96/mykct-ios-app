//
//  WatchTheme.swift
//  CollegeWatch
//

import SwiftUI

private let largestTypeSize = DynamicTypeSize.xxLarge

extension View {
    func watchTheme() -> some View {
        environment(\.colors, .oled)
            .environment(\.locale, ScheduleCalendar.locale)
            .dynamicTypeSize(...largestTypeSize)
    }
}
