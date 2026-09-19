//
//  LessonCard.swift
//  college-ios-app
//

import SwiftUI

private let cardPadding: CGFloat = 11
private let watermarkSize: CGFloat = 76
private let pastOpacity: Double = 0.55

struct LessonCard: View {
    @Environment(\.colors) private var colors

    let lesson: Lesson
    let minHeight: CGFloat
    let isPast: Bool
    let now: Date?
    let onTap: () -> Void

    private var isNow: Bool { now != nil }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
    }

    var body: some View {
        Button(action: onTap) {
            content
                .padding(cardPadding)
                .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
                .background(alignment: .bottomTrailing) { watermark }
                .clipShape(shape)
                .accentGlass(shape, interactive: true)
                .overlay {
                    if isNow {
                        shape.strokeBorder(.white.opacity(0.85), lineWidth: 2)
                    }
                }
                .background(alignment: .bottom) {
                    if isNow { glow }
                }
        }
        .buttonStyle(.plain)
        .opacity(isPast ? pastOpacity : 1)
        .accessibilityElement(children: .combine)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            TimePill(text: timeRange, showsCheck: isPast, accent: colors.primary)

            Text(lesson.displayTitle)
                .textStyle(AppType.titleLarge)
                .foregroundStyle(.white)
                .lineLimit(2)
                .padding(.top, 8)

            if !lesson.topic.isEmpty {
                Text(lesson.topic)
                    .textStyle(AppType.bodyMedium)
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(2)
                    .padding(.top, 2)
            }

            footer.padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var footer: some View {
        if let now {
            let left = LessonProgress.secondsLeft(of: lesson, at: now)

            chips(secondsLeft: left)
                .animation(.snappy(duration: 0.3), value: left)
        } else {
            chips(secondsLeft: nil)
        }
    }

    private func chips(secondsLeft: Int?) -> some View {
        GlassGroup {
            FlowLayout {
                if let secondsLeft {
                    GlassChip(
                        text: "Идёт · осталось \(ScheduleFormat.remaining(seconds: secondsLeft))",
                        symbol: "clock"
                    )
                }
                if !lesson.room.isEmpty {
                    GlassChip(text: lesson.room, symbol: "mappin.and.ellipse")
                }
                if !lesson.subgroups.isEmpty {
                    GlassChip(text: "Подгруппы: \(lesson.subgroups.count)", symbol: "list.bullet")
                }
            }
        }
    }

    private var watermark: some View {
        Image(systemName: SubjectIcon.symbol(for: lesson.title))
            .font(.system(size: watermarkSize, weight: .light))
            .foregroundStyle(.white.opacity(0.13))
            .offset(x: 8, y: 8)
            .accessibilityHidden(true)
    }

    private var glow: some View {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0),
                .init(color: .violetLight.opacity(0.45), location: 0.25),
                .init(color: .violetTint.opacity(0.65), location: 0.5),
                .init(color: .violetLight.opacity(0.45), location: 0.75),
                .init(color: .clear, location: 1),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 10)
        .blur(radius: 24)
        .padding(.horizontal, 20)
        .offset(y: 8)
        .accessibilityHidden(true)
    }

    private var timeRange: String {
        "\(ScheduleFormat.time(lesson.start)) - \(ScheduleFormat.time(lesson.end))"
    }
}

#Preview {
    let day = ScheduleCalendar.day(of: .now)

    return VStack(spacing: 12) {
        LessonCard(
            lesson: ScheduleMocks.lessons(day: day, weekday: 0)[0],
            minHeight: 150,
            isPast: false,
            now: .now,
            onTap: {}
        )
        LessonCard(
            lesson: ScheduleMocks.lessons(day: day, weekday: 0)[2],
            minHeight: 150,
            isPast: true,
            now: nil,
            onTap: {}
        )
    }
    .padding(16)
    .appBackground()
    .environment(\.colors, .dark)
}
