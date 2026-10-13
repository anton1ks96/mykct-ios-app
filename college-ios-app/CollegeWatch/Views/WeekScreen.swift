//
//  WeekScreen.swift
//  CollegeWatch
//

import SwiftUI

struct WeekScreen: View {
    let snapshot: WidgetSnapshot?
    let now: Date
    let onDay: (Date) -> Void

    private var today: Date { ScheduleCalendar.day(of: now) }

    private var weeks: [(monday: Date, days: [WidgetDay])] {
        let monday = ScheduleCalendar.monday(of: now)
        return [monday, ScheduleCalendar.adding(weeks: 1, to: monday)]
            .map { ($0, WidgetSchedule.week(of: $0, in: snapshot)) }
            .filter { !$0.days.isEmpty }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 6) {
                if weeks.isEmpty {
                    WatchMessage.unavailable
                }

                ForEach(weeks, id: \.monday) { week in
                    SectionCaps(text: range(of: week.monday))

                    ForEach(week.days, id: \.date) { day in
                        DayTile(day: day, today: today) {
                            onDay(day.date)
                        }
                    }
                }
            }
            .scenePadding(.horizontal)
        }
        .navigationTitle("Неделя")
    }

    private func range(of monday: Date) -> String {
        ScheduleFormat.dateRange(from: monday, to: ScheduleCalendar.adding(days: 6, to: monday))
    }
}

#if DEBUG
#Preview("Неделя") {
    NavigationStack {
        WeekScreen(snapshot: WatchMocks.snapshot, now: WatchMocks.at(1, 11)) { _ in }
    }
    .watchTheme()
}

#Preview("Нет данных") {
    NavigationStack {
        WeekScreen(snapshot: WatchMocks.snapshot, now: WatchMocks.at(14, 10)) { _ in }
    }
    .watchTheme()
}
#endif
