//
//  DayTimeline.swift
//  college-ios-app
//

import SwiftUI

private let slotMinutes = 30
private let slotHeight: CGFloat = 50
private let gutter: CGFloat = 56
private let markerHeight: CGFloat = 18
private let labelGap = 12
private let cardSpacing: CGFloat = 8

struct DayTimeline: View {
    @Environment(\.colors) private var colors

    let lessons: [Lesson]
    let now: Date?
    let onSelect: (Lesson) -> Void

    private var nowMinutes: Int? { now.map(ScheduleCalendar.minutes(of:)) }

    private var gridStart: Int { (lessons.first?.start ?? 0) / 60 * 60 }

    private var gridEnd: Int {
        let end = lessons.map(\.end).max() ?? gridStart
        let rest = end % slotMinutes
        return rest == 0 ? end : end + (slotMinutes - rest)
    }

    private var slots: Int { max((gridEnd - gridStart) / slotMinutes, 1) }

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(0...slots, id: \.self) { index in
                slotLine(at: index)
            }

            if let nowMinutes, nowMinutes >= gridStart, nowMinutes <= gridEnd {
                nowLine(at: nowMinutes)
                    .animation(.snappy(duration: 0.4), value: nowMinutes)
            }

            ForEach(rows) { row in
                slotRow(row)
            }
        }
        .frame(height: slotHeight * CGFloat(slots), alignment: .top)
    }

    private func slotLine(at index: Int) -> some View {
        let time = gridStart + index * slotMinutes
        let showsLabel = nowMinutes.map { abs($0 - time) > labelGap } ?? true

        return HStack(spacing: 0) {
            Text(showsLabel ? ScheduleFormat.time(time) : "")
                .textStyle(AppType.labelMedium)
                .foregroundStyle(colors.onSurfaceVariant)
                .frame(width: gutter, alignment: .leading)

            DashedLine()
                .stroke(colors.outlineVariant, style: StrokeStyle(lineWidth: 1, dash: [4, 5]))
                .frame(height: 1)
        }
        .frame(height: markerHeight)
        .offset(y: offset(for: time) - markerHeight / 2)
    }

    private func nowLine(at time: Int) -> some View {
        HStack(spacing: 0) {
            Text(ScheduleFormat.time(time))
                .textStyle(AppType.labelMedium)
                .fontWeight(.bold)
                .foregroundStyle(colors.onBackground)
                .contentTransition(.numericText())
                .frame(width: gutter, alignment: .leading)

            Circle()
                .fill(colors.onBackground)
                .frame(width: 7, height: 7)

            Rectangle()
                .fill(colors.onBackground)
                .frame(height: 2)
        }
        .frame(height: markerHeight)
        .offset(y: offset(for: time) - markerHeight / 2)
        .accessibilityHidden(true)
    }

    private var rows: [SlotRow] {
        Dictionary(grouping: lessons, by: \.slot)
            .map { SlotRow(slot: $0.key, lessons: $0.value) }
            .sorted { $0.slot.start < $1.slot.start }
    }

    private func slotRow(_ row: SlotRow) -> some View {
        HStack(spacing: cardSpacing) {
            ForEach(row.lessons) { lesson in
                card(lesson, in: row.slot)
            }
        }
        .padding(.leading, gutter)
        .offset(y: offset(for: row.slot.start))
    }

    private func card(_ lesson: Lesson, in slot: LessonSlot) -> some View {
        let isNow = nowMinutes.map { $0 >= slot.start && $0 < slot.end } ?? false

        return LessonCard(
            lesson: lesson,
            minHeight: slotHeight * CGFloat(slot.end - slot.start) / CGFloat(slotMinutes),
            isPast: nowMinutes.map { slot.end <= $0 } ?? false,
            now: isNow ? now : nil,
            onTap: { onSelect(lesson) }
        )
    }

    private func offset(for time: Int) -> CGFloat {
        slotHeight * CGFloat(time - gridStart) / CGFloat(slotMinutes)
    }
}

private struct SlotRow: Identifiable {
    let slot: LessonSlot
    let lessons: [Lesson]

    var id: LessonSlot { slot }
}

nonisolated private struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

#Preview {
    let day = ScheduleCalendar.day(of: .now)

    return ScrollView {
        DayTimeline(
            lessons: ScheduleMocks.lessons(day: day, weekday: 0),
            now: ScheduleCalendar.date(day, atMinutes: 11 * 60 + 20),
            onSelect: { _ in }
        )
        .padding(.horizontal, 16)
    }
    .appBackground()
    .environment(\.colors, .dark)
}
