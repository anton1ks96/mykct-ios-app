//
//  LessonSheet.swift
//  college-ios-app
//

import SwiftUI

private let watermarkSize: CGFloat = 84

struct LessonSheet: View {
    @Environment(\.colors) private var colors

    let details: LessonDetails
    let selection: Selection
    var onSelect: (LessonSubgroup?) -> Void = { _ in }

    private var lesson: Lesson { details.lesson }
    private var ownIDs: Set<String> { LessonSplitting.selectedIDs(selection) }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
    }

    private var visibleRows: [DetailRow] {
        let shown = Set(
            [lesson.title, lesson.topic, details.selected?.title, details.selected?.topic]
                .compactMap { $0?.lowercased() }
                .filter { !$0.isEmpty }
        )
        return DetailLabels.sorted(details.rows).filter { !shown.contains($0.value.lowercased()) }
    }

    private var phase: Phase {
        phaseOf(isLoading: details.isLoading, error: details.error, isEmpty: visibleRows.isEmpty)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Metrics.sectionSpacing) {
                hero

                if lesson.subgroups.isEmpty {
                    detailsCard
                } else {
                    subgroups
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, Metrics.screenPadding)
            .padding(.bottom, 32)
            .animation(.snappy(duration: 0.28), value: details.selected)
        }
        .appBackground()
    }

    // MARK: - Sections

    private var hero: some View {
        VStack(alignment: .leading, spacing: 0) {
            TimePill(text: timeRange, accent: colors.primary)

            Text(lesson.title)
                .textStyle(AppType.headlineMedium)
                .foregroundStyle(.white)
                .padding(.top, 10)

            if !lesson.topic.isEmpty {
                Text(lesson.topic)
                    .textStyle(AppType.bodyLarge)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.top, 4)
            }

            if !heroChips.isEmpty {
                GlassGroup {
                    FlowLayout {
                        ForEach(heroChips) { chip in
                            GlassChip(text: chip.text, symbol: chip.symbol)
                        }
                    }
                }
                .padding(.top, 12)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Metrics.cardPadding)
        .background(alignment: .bottomTrailing) { watermark }
        .clipShape(shape)
        .accentGlass(shape)
        .accessibilityElement(children: .combine)
    }

    private var subgroups: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Подгруппы")
                .textStyle(AppType.labelLarge)
                .foregroundStyle(colors.onSurfaceVariant)
                .padding(.leading, 4)

            GlassGroup {
                VStack(spacing: 10) {
                    ForEach(Array(lesson.subgroups.enumerated()), id: \.offset) { _, subgroup in
                        subgroupCard(subgroup)
                    }
                }
            }
        }
    }

    private func subgroupCard(_ subgroup: LessonSubgroup) -> some View {
        let isOpen = details.selected == subgroup

        return Button {
            onSelect(isOpen ? nil : subgroup)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(subgroup.id)
                        .textStyle(AppType.titleLarge)
                        .foregroundStyle(isOpen ? colors.primary : colors.onSurface)
                        .lineLimit(1)

                    Spacer(minLength: 0)

                    if !subgroup.classID.isEmpty {
                        Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(colors.onSurfaceVariant)
                    }
                }

                if subgroup.title != lesson.title && !subgroup.title.isEmpty {
                    Text(subgroup.title)
                        .textStyle(AppType.titleMedium)
                        .foregroundStyle(colors.onSurface)
                        .padding(.top, 2)
                }

                if !subgroup.topic.isEmpty {
                    Text(subgroup.topic)
                        .textStyle(AppType.bodyLarge)
                        .foregroundStyle(colors.onSurfaceVariant)
                        .padding(.top, 4)
                }

                let chips = subgroupChips(subgroup)
                if !chips.isEmpty {
                    GlassGroup {
                        FlowLayout {
                            ForEach(chips) { chip in
                                GlassChip(
                                    text: chip.text,
                                    symbol: chip.symbol,
                                    foreground: chip.isAccent ? colors.primary : colors.onSurfaceVariant,
                                    fill: .clear
                                )
                            }
                        }
                    }
                    .padding(.top, 10)
                }

                if isOpen {
                    hairline.padding(.vertical, 14)

                    Fade(value: phase) { phase in
                        content(for: phase)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Metrics.cardPadding)
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .glassSurface(shape, tint: isOpen ? colors.primary.opacity(0.35) : nil, interactive: true)
        .disabled(subgroup.classID.isEmpty)
        .accessibilityHint(isOpen ? "Скрыть подробности подгруппы" : "Показать подробности подгруппы")
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Подробности")
                .textStyle(AppType.labelLarge)
                .foregroundStyle(colors.onSurfaceVariant)

            Fade(value: phase) { phase in
                content(for: phase)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Metrics.cardPadding)
        .glassSurface(shape)
    }

    // MARK: - Parts

    @ViewBuilder
    private func content(for phase: Phase) -> some View {
        switch phase {
        case .loading:
            Swirl().frame(width: 26, height: 26)

        case .error:
            Text(details.error ?? "")
                .textStyle(AppType.bodyLarge)
                .foregroundStyle(colors.onSurfaceVariant)

        case .empty:
            Text("Подробностей нет")
                .textStyle(AppType.bodyLarge)
                .foregroundStyle(colors.onSurfaceVariant)

        case .content:
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(visibleRows.enumerated()), id: \.offset) { _, row in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(DetailLabels.title(for: row.key))
                            .textStyle(AppType.labelLarge)
                            .foregroundStyle(colors.onSurfaceVariant)

                        Text(row.value)
                            .textStyle(AppType.bodyLarge)
                            .foregroundStyle(colors.onSurface)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var watermark: some View {
        Image(systemName: SubjectIcon.symbol(for: lesson.title))
            .font(.system(size: watermarkSize, weight: .light))
            .foregroundStyle(.white.opacity(0.13))
            .offset(x: 10, y: 10)
            .accessibilityHidden(true)
    }

    private var hairline: some View {
        Rectangle()
            .fill(colors.onSurface.opacity(Metrics.hairlineOpacity))
            .frame(height: 1)
    }

    private var heroChips: [SheetChip] {
        var chips: [SheetChip] = []
        if !lesson.room.isEmpty {
            chips.append(SheetChip(text: lesson.room, symbol: "mappin.and.ellipse"))
        }
        if !lesson.subgroups.isEmpty {
            chips.append(
                SheetChip(text: "Подгруппы: \(lesson.subgroups.count)", symbol: "list.bullet")
            )
        }
        return chips
    }

    private func subgroupChips(_ subgroup: LessonSubgroup) -> [SheetChip] {
        var chips: [SheetChip] = []
        if !subgroup.room.isEmpty {
            chips.append(SheetChip(text: subgroup.room, symbol: "mappin.and.ellipse"))
        }
        if ownIDs.contains(subgroup.id) {
            chips.append(
                SheetChip(text: "Ваша подгруппа", symbol: "checkmark.seal", isAccent: true)
            )
        }
        return chips
    }

    private var timeRange: String {
        "\(ScheduleFormat.time(lesson.start)) - \(ScheduleFormat.time(lesson.end))"
    }
}

private struct SheetChip: Identifiable {
    let text: String
    let symbol: String
    var isAccent: Bool = false

    var id: String { "\(symbol)-\(text)" }
}

#Preview("С подгруппами") {
    let lesson = ScheduleMocks.lessons(day: ScheduleCalendar.day(of: .now), weekday: 0)[2]

    return LessonSheet(
        details: LessonDetails(lesson: lesson, isLoading: false),
        selection: ScheduleMocks.selection
    )
    .environment(\.colors, .dark)
}

#Preview("Без подгрупп") {
    let lesson = ScheduleMocks.lessons(day: ScheduleCalendar.day(of: .now), weekday: 0)[0]

    return LessonSheet(
        details: LessonDetails(
            lesson: lesson,
            rows: [
                DetailRow(key: "Teacher", value: "Иванов И. И."),
                DetailRow(key: "topicDescr", value: "Методы интегрирования"),
            ],
            isLoading: false
        ),
        selection: ScheduleMocks.selection
    )
    .environment(\.colors, .dark)
}
