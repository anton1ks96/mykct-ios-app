//
//  TodayScreen.swift
//  CollegeWatch
//

import SwiftUI

struct TodayScreen: View {
    let snapshot: WidgetSnapshot?
    let now: Date
    var onWeek: () -> Void = {}
    var onDay: (Date) -> Void = { _ in }

    private var today: Date { ScheduleCalendar.day(of: now) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .scenePadding(.horizontal)
        }
        .navigationTitle("Сегодня")
        .toolbar {
            if snapshot != nil {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Неделя", systemImage: "calendar", action: onWeek)
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch WidgetSchedule.content(at: now, in: snapshot) {
        case .focus(let focus) where focus.stage != .tomorrow:
            NowCard(focus: focus, now: now)
            upcoming(after: focus)
        case .focus(let focus):
            RestHeader(caption: ScheduleFormat.dayTitle(today), lessonCount: todayCount)
            nextDay(focus.day)
        case .rest(let rest):
            RestHeader(caption: ScheduleFormat.dayTitle(today), lessonCount: rest.lessonCount)
            if let day = rest.upcoming {
                nextDay(day)
            }
        case .setup:
            WatchMessage.setup
        case .unavailable:
            WatchMessage.unavailable
        }
    }

    private var todayCount: Int {
        WidgetSchedule.day(now, in: snapshot)?.slots.count ?? 0
    }

    @ViewBuilder
    private func upcoming(after focus: WidgetFocus) -> some View {
        let later = Array(focus.day.slots.dropFirst(focus.index + 1))

        if !later.isEmpty {
            SectionCaps(text: "Далее")
            ForEach(later.indices, id: \.self) { index in
                LessonTile(slot: later[index])
            }
        } else if let next = focus.next {
            SectionCaps(text: WidgetSchedule.dayLabel(of: next.day, focusDay: focus.day.date, at: now))
            LessonTile(slot: next)
        }
    }

    @ViewBuilder
    private func nextDay(_ day: WidgetDay) -> some View {
        if let slot = day.slots.first {
            Button {
                onDay(day.date)
            } label: {
                NextDayCard(label: dayCaption(day.date), slot: slot)
            }
            .buttonStyle(.plain)
        }
    }

    private func dayCaption(_ date: Date) -> String {
        let label = WidgetSchedule.dayLabel(of: date, focusDay: today, at: now)
        return "\(label), \(ScheduleFormat.dayMonth(date))"
    }
}

#if DEBUG
#Preview("Идёт пара") {
    NavigationStack {
        TodayScreen(snapshot: WatchMocks.snapshot, now: WatchMocks.at(1, 10, 58))
    }
    .watchTheme()
}

#Preview("Перемена") {
    NavigationStack {
        TodayScreen(snapshot: WatchMocks.snapshot, now: WatchMocks.at(1, 12, 22))
    }
    .watchTheme()
}

#Preview("Вечер") {
    NavigationStack {
        TodayScreen(snapshot: WatchMocks.snapshot, now: WatchMocks.at(1, 19, 40))
    }
    .watchTheme()
}

#Preview("Свободный день") {
    NavigationStack {
        TodayScreen(snapshot: WatchMocks.snapshot, now: WatchMocks.at(2, 12))
    }
    .watchTheme()
}

#Preview("Нет группы") {
    NavigationStack {
        TodayScreen(snapshot: nil, now: .now)
    }
    .watchTheme()
}

#Preview("Нет недели") {
    NavigationStack {
        TodayScreen(snapshot: WatchMocks.snapshot, now: WatchMocks.at(14, 10))
    }
    .watchTheme()
}
#endif
