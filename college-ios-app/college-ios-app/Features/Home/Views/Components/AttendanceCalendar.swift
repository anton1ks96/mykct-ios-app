//
//  AttendanceCalendar.swift
//  college-ios-app
//

import SwiftUI

private let calendarRadius: CGFloat = 24
private let cellRadius: CGFloat = 14
private let cellSpacing: CGFloat = 6
private let arrowSide: CGFloat = 40
private let monthShift: CGFloat = 40

struct AttendanceCalendar: View {
    @Environment(\.colors) private var colors

    let month: Date
    let selected: Date
    let marks: [Date: DayMark]
    let onToday: () -> Void
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onSelect: (Date) -> Void

    @State private var isForward = true

    var body: some View {
        VStack(spacing: 14) {
            header

            weekdays

            ZStack {
                MonthGrid(month: month, selected: selected, marks: marks, onSelect: onSelect)
                    .id(month)
                    .transition(.slideFade(isForward ? monthShift : -monthShift))
            }
        }
        .padding(14)
        .glassSurface(RoundedRectangle(cornerRadius: calendarRadius, style: .continuous))
        .animation(.snappy(duration: 0.28), value: month)
        .onChange(of: month) { previous, updated in isForward = updated > previous }
    }

    private var header: some View {
        GlassGroup(spacing: 8) {
            HStack(spacing: 8) {
                Button(action: onToday) {
                    Image(systemName: "calendar")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(colors.primary)
                        .frame(width: arrowSide, height: arrowSide)
                }
                .buttonStyle(.plain)
                .glassSurface(Circle(), style: .clear, interactive: true)
                .accessibilityLabel("Сегодня")

                Text(ScheduleFormat.monthYear(month))
                    .textStyle(AppType.titleMedium)
                    .foregroundStyle(colors.onSurface)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 4)

                arrow("chevron.left", label: "Предыдущий месяц", action: onPrevious)
                arrow("chevron.right", label: "Следующий месяц", action: onNext)
            }
        }
    }

    private func arrow(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(colors.onBackground)
                .frame(width: arrowSide, height: arrowSide)
        }
        .buttonStyle(.plain)
        .glassSurface(Circle(), style: .clear, interactive: true)
        .accessibilityLabel(label)
    }

    private var weekdays: some View {
        HStack(spacing: cellSpacing) {
            ForEach(ScheduleFormat.shortWeekdays, id: \.self) { title in
                Text(title)
                    .textStyle(AppType.labelMedium)
                    .foregroundStyle(colors.onSurfaceVariant)
                    .frame(maxWidth: .infinity)
            }
        }
        .accessibilityHidden(true)
    }
}

private struct MonthGrid: View {
    @Environment(\.colors) private var colors
    @Namespace private var glass

    let month: Date
    let selected: Date
    let marks: [Date: DayMark]
    let onSelect: (Date) -> Void

    private var lead: Int {
        ScheduleCalendar.weekdayIndex(of: ScheduleCalendar.monthStart(of: month)) - 1
    }

    private var length: Int {
        ScheduleCalendar.days(inMonth: month)
    }

    private var rows: Int {
        (lead + length + 6) / 7
    }

    var body: some View {
        GlassGroup(spacing: cellSpacing) {
            VStack(spacing: cellSpacing) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: cellSpacing) {
                        ForEach(0..<7, id: \.self) { column in
                            cell(at: row * 7 + column - lead + 1)
                        }
                    }
                }
            }
        }
        .background(alignment: .topLeading) { selection }
        .animation(.snappy(duration: 0.28), value: selected)
    }

    private var selection: some View {
        let mark = marks[selected] ?? .empty

        return RoundedRectangle(cornerRadius: cellRadius, style: .continuous)
            .fill(mark.fill(colors) ?? colors.primary)
            .matchedGeometryEffect(id: "selection", in: glass, isSource: false)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private func cell(at number: Int) -> some View {
        if number < 1 || number > length {
            OutsideCell()
        } else {
            let date = ScheduleCalendar.adding(days: number - 1, to: ScheduleCalendar.monthStart(of: month))

            DayTile(
                date: date,
                number: number,
                mark: marks[date] ?? .empty,
                isSelected: date == selected,
                isToday: date == ScheduleCalendar.day(of: .now),
                namespace: glass,
                onSelect: { onSelect(date) }
            )
        }
    }
}

private struct DayTile: View {
    @Environment(\.colors) private var colors

    let date: Date
    let number: Int
    let mark: DayMark
    let isSelected: Bool
    let isToday: Bool
    let namespace: Namespace.ID
    let onSelect: () -> Void

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cellRadius, style: .continuous)
    }

    var body: some View {
        Button(action: onSelect) {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    Text("\(number)")
                        .textStyle(AppType.bodyMedium)
                        .fontWeight(isSelected || isToday ? .bold : .regular)
                        .foregroundStyle(foreground)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                }
                .contentShape(shape)
        }
        .buttonStyle(.plain)
        .modifier(DayTileSurface(mark: mark, isSelected: isSelected, namespace: namespace))
        .overlay {
            if isToday && !isSelected {
                shape.strokeBorder(colors.primary, lineWidth: 1.5)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(ScheduleFormat.dayTitle(date))
        .accessibilityValue(mark.title)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private var foreground: Color {
        guard isSelected else { return mark.accent(colors) ?? colors.onSurfaceVariant }
        guard !colors.isDark, mark != .empty else { return .white }
        return colors.onStatusFill
    }
}

private struct DayTileSurface: ViewModifier {
    @Environment(\.colors) private var colors

    let mark: DayMark
    let isSelected: Bool
    let namespace: Namespace.ID

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cellRadius, style: .continuous)
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if isSelected {
            content.matchedGeometryEffect(id: "selection", in: namespace, isSource: true)
        } else if let accent = mark.accent(colors) {
            content.background(accent.opacity(0.16), in: shape)
        } else {
            content.background(colors.surfaceVariant.opacity(0.5), in: shape)
        }
    }
}

private struct OutsideCell: View {
    @Environment(\.colors) private var colors

    var body: some View {
        Color.clear
            .aspectRatio(1, contentMode: .fit)
            .background {
                Hatch()
                    .stroke(
                        colors.onSurface.opacity(colors.isDark ? 0.08 : 0.05),
                        style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: cellRadius, style: .continuous))
            }
            .accessibilityHidden(true)
    }
}

nonisolated private struct Hatch: Shape {
    private let step: CGFloat = 7

    func path(in rect: CGRect) -> Path {
        var path = Path()
        var x = rect.minX - rect.height

        while x < rect.maxX {
            path.move(to: CGPoint(x: x, y: rect.maxY))
            path.addLine(to: CGPoint(x: x + rect.height, y: rect.minY))
            x += step
        }

        return path
    }
}

private extension DayMark {
    func accent(_ colors: AppColors) -> Color? {
        switch self {
        case .empty: nil
        case .present: colors.success
        case .excused: colors.warning
        case .absent: colors.danger
        }
    }

    func fill(_ colors: AppColors) -> Color? {
        switch self {
        case .empty: nil
        case .present: colors.successFill
        case .excused: colors.warningFill
        case .absent: colors.dangerFill
        }
    }
}

#Preview {
    @Previewable @State var selected = ScheduleCalendar.day(of: .now)
    @Previewable @State var month = ScheduleCalendar.monthStart(of: .now)

    let records = HomeMocks.records(month: month)

    return AttendanceCalendar(
        month: month,
        selected: selected,
        marks: HomeParsing.marks(from: records),
        onToday: {
            month = ScheduleCalendar.monthStart(of: .now)
            selected = ScheduleCalendar.day(of: .now)
        },
        onPrevious: { month = ScheduleCalendar.adding(months: -1, to: month) },
        onNext: { month = ScheduleCalendar.adding(months: 1, to: month) },
        onSelect: { selected = $0 }
    )
    .padding(20)
    .appBackground()
    .environment(\.colors, .dark)
}
