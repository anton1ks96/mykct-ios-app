//
//  RestHeader.swift
//  CollegeWidget
//

import SwiftUI

struct RestHeader: View {
    @Environment(\.colors) private var colors

    let caption: String
    let lessonCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(caption)
                .textStyle(AppType.labelLarge)
                .foregroundStyle(colors.onSurfaceVariant)
                .lineLimit(1)

            Text(lessonCount == 0 ? "Пар нет" : ScheduleFormat.lessonsCount(lessonCount))
                .textStyle(AppType.heroValue)
                .foregroundStyle(colors.onBackground)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(lessonCount == 0 ? "Отдыхай" : "Пары закончились")
                .textStyle(AppType.bodyLarge)
                .foregroundStyle(colors.onSurfaceVariant)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .accessibilityElement(children: .combine)
    }
}
