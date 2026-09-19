//
//  StreakSheet.swift
//  college-ios-app
//

import SwiftUI

struct StreakSheet: View {
    @Environment(\.colors) private var colors

    let streak: Streak
    let stats: AttendanceStats
    let weekStart: Date
    let records: [AttendanceRecord]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                StreakFlame(diameter: 132, frameRate: 60, isActive: streak.current > 0)

                Text("\(streak.current)")
                    .textStyle(AppType.displayLarge)
                    .foregroundStyle(colors.onSurface)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Text(HomeFormat.daysInRow(streak.current, schoolDays: streak.schoolDays))
                    .textStyle(AppType.titleMedium)
                    .foregroundStyle(colors.onSurface)

                Text(HomeFormat.status(rate: streak.rate, schoolDays: streak.schoolDays))
                    .textStyle(AppType.bodyMedium)
                    .foregroundStyle(colors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)

                WeekChecks(weekStart: weekStart, records: records)
                    .padding(.top, 24)

                numbers
                    .padding(.top, 24)

                if let period {
                    Text(period)
                        .textStyle(AppType.labelMedium)
                        .foregroundStyle(colors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                        .padding(.top, 12)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 24)
            .padding(.horizontal, Metrics.screenPadding)
            .padding(.bottom, 32)
        }
        .appBackground()
    }

    private var numbers: some View {
        HStack(spacing: 0) {
            number("Дней", "\(streak.daysAttended)")
            number("Пар", "\(stats.total)")
            number("Посещал", "\(Int(streak.rate))%")
            number("Лучший", "\(streak.longest)")
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .glassSurface(RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous))
    }

    private func number(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .textStyle(AppType.labelMedium)
                .foregroundStyle(colors.onSurfaceVariant)

            Text(value)
                .textStyle(AppType.titleMedium)
                .fontWeight(.bold)
                .foregroundStyle(colors.onSurface)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    private var period: String? {
        guard let start = streak.periodStart, streak.schoolDays > 0 else { return nil }
        let days = "\(streak.daysAttended) из \(streak.schoolDays) учебных дней"
        return "С \(ScheduleFormat.dayMonth(start)) · \(days)"
    }
}

#Preview {
    let monday = ScheduleCalendar.monday(of: .now)
    let records = HomeMocks.records(month: .now)

    return StreakSheet(
        streak: HomeMocks.streak,
        stats: AttendanceStats.of(records),
        weekStart: monday,
        records: records
    )
    .environment(\.colors, .dark)
}
