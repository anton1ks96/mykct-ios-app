//
//  LessonProgressBar.swift
//  CollegeWidget
//

import SwiftUI
import WidgetKit

struct LessonProgressBar: View {
    let slot: WidgetSlot

    var body: some View {
        ProgressView(timerInterval: slot.startDate...slot.endDate, countsDown: false) {
            EmptyView()
        } currentValueLabel: {
            EmptyView()
        }
        .progressViewStyle(.linear)
        .tint(.white)
        .background(.white.opacity(0.3), in: Capsule())
        .widgetAccentable()
    }
}
