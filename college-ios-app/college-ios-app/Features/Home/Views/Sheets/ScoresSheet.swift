//
//  ScoresSheet.swift
//  college-ios-app
//

import SwiftUI

struct ScoresSheet: View {
    @Environment(\.colors) private var colors

    let scores: SubjectScores

    var body: some View {
        FillScroll(fills: phase != .content) {
            VStack(alignment: .leading, spacing: 0) {
                Text(scores.subject.title)
                    .textStyle(AppType.titleLarge)
                    .foregroundStyle(colors.onSurface)

                if let summary {
                    Text(summary)
                        .textStyle(AppType.bodyMedium)
                        .foregroundStyle(colors.onSurfaceVariant)
                        .padding(.top, 4)
                }

                Fade(value: phase) { phase in
                    body(for: phase)
                }
                .padding(.top, 16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 24)
            .padding(.horizontal, Metrics.screenPadding)
            .padding(.bottom, 32)
        }
        .appBackground()
    }

    @ViewBuilder
    private func body(for phase: Phase) -> some View {
        switch phase {
        case .loading:
            HomePlaceholder { Swirl().frame(width: 44, height: 44) }

        case .error:
            HomePlaceholder {
                Text(scores.error ?? "Не удалось загрузить баллы")
                    .textStyle(AppType.bodyLarge)
                    .foregroundStyle(colors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }

        case .empty:
            HomePlaceholder {
                Text("За это полугодие баллов нет")
                    .textStyle(AppType.bodyLarge)
                    .foregroundStyle(colors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
            }

        case .content:
            lessons
        }
    }

    private var lessons: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(scores.lessons.enumerated()), id: \.element.id) { index, lesson in
                VStack(alignment: .leading, spacing: 8) {
                    if !lesson.title.isEmpty {
                        Text(lesson.title)
                            .textStyle(AppType.labelLarge)
                            .foregroundStyle(colors.onSurfaceVariant)
                    }

                    GlassGroup(spacing: 8) {
                        VStack(spacing: 8) {
                            ForEach(lesson.scores) { score in
                                ScoreRow(score: score)
                            }
                        }
                    }
                }
                .padding(.top, index == 0 ? 0 : 20)
            }
        }
    }

    private var phase: Phase {
        phaseOf(isLoading: scores.isLoading, error: scores.error, isEmpty: scores.lessons.isEmpty)
    }

    private var summary: String? {
        guard let average = scores.average else { return nil }
        let count = ScheduleFormat.scoresCount(scores.graded.count)
        return "Средний балл \(HomeFormat.average(average)) · \(count)"
    }
}

private struct ScoreRow: View {
    @Environment(\.colors) private var colors

    let score: Score

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Metrics.rowRadius, style: .continuous)
    }

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(score.details.isEmpty ? "Без описания" : score.details)
                    .textStyle(AppType.bodyMedium)
                    .foregroundStyle(colors.onSurface)

                if let date = score.date {
                    Text(HomeFormat.date(date))
                        .textStyle(AppType.bodySmall)
                        .foregroundStyle(colors.onSurfaceVariant)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(value)
                .textStyle(AppType.titleMedium)
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .padding(14)
        .glassSurface(shape)
        .accessibilityElement(children: .combine)
    }

    private var value: String {
        score.value.map { "\($0) / \(score.max)" } ?? "—"
    }

    private var color: Color {
        guard let share = score.share else { return colors.onSurfaceVariant }
        if share >= 0.8 { return colors.success }
        if share >= 0.6 { return colors.warning }
        return colors.danger
    }
}

#if DEBUG
#Preview {
    ScoresSheet(
        scores: SubjectScores(
            subject: HomeMocks.subjects[0],
            lessons: HomeMocks.lessons,
            isLoading: false
        )
    )
    .environment(\.colors, .dark)
}
#endif
