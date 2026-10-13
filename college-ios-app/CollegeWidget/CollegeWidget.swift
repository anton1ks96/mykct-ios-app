//
//  CollegeWidget.swift
//  CollegeWidget
//
//  Created by pc on 12.10.2026.
//

import WidgetKit
import SwiftUI

nonisolated struct ComingSoonEntry: TimelineEntry {
    let date: Date
}

nonisolated struct ComingSoonProvider: TimelineProvider {
    func placeholder(in context: Context) -> ComingSoonEntry {
        ComingSoonEntry(date: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (ComingSoonEntry) -> Void) {
        completion(ComingSoonEntry(date: .now))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<ComingSoonEntry>) -> Void
    ) {
        completion(Timeline(entries: [ComingSoonEntry(date: .now)], policy: .never))
    }
}

struct ComingSoonView: View {
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryInline:
            Label("Скоро", systemImage: "hourglass")
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "hourglass")
                    .font(.title3)
            }
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Label("МойКЦТ", systemImage: "calendar")
                    .font(.headline)
                Text("Скоро")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .systemSmall:
            content(iconSize: 32, titleFont: .title3.bold(), showsSubtitle: false)
        default:
            content(iconSize: 44, titleFont: .title.bold(), showsSubtitle: true)
        }
    }

    private func content(iconSize: CGFloat, titleFont: Font, showsSubtitle: Bool) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "hourglass")
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(Color("AccentColor"))
            Text("Скоро")
                .font(titleFont)
            if showsSubtitle {
                Text("Виджеты МойКЦТ в разработке")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CollegeWidget: Widget {
    let kind: String = "CollegeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ComingSoonProvider()) { _ in
            ComingSoonView()
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("МойКЦТ")
        .description("Скоро здесь появится расписание.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .systemExtraLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}

#Preview(as: .systemSmall) {
    CollegeWidget()
} timeline: {
    ComingSoonEntry(date: .now)
}

#Preview(as: .systemMedium) {
    CollegeWidget()
} timeline: {
    ComingSoonEntry(date: .now)
}

#Preview(as: .systemLarge) {
    CollegeWidget()
} timeline: {
    ComingSoonEntry(date: .now)
}

#Preview(as: .accessoryCircular) {
    CollegeWidget()
} timeline: {
    ComingSoonEntry(date: .now)
}

#Preview(as: .accessoryRectangular) {
    CollegeWidget()
} timeline: {
    ComingSoonEntry(date: .now)
}

#Preview(as: .accessoryInline) {
    CollegeWidget()
} timeline: {
    ComingSoonEntry(date: .now)
}
