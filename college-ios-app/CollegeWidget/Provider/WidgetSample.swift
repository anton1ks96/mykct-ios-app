//
//  WidgetSample.swift
//  CollegeWidget
//

import Foundation

nonisolated enum WidgetSample {

    static func entry(at now: Date) -> ScheduleEntry {
        let day = ScheduleCalendar.adding(days: 1, to: ScheduleCalendar.day(of: now))
        let lessons = [
            Lesson(
                id: "sample-math", day: day, start: 9 * 60, end: 10 * 60 + 30,
                title: "Математика", topic: "Пределы и непрерывность", room: "301"
            ),
            Lesson(
                id: "sample-algorithms", day: day, start: 10 * 60 + 40, end: 12 * 60 + 10,
                title: "Основы алгоритмизации", topic: "Сортировки", room: "215"
            ),
            Lesson(
                id: "sample-english", day: day, start: 12 * 60 + 40, end: 14 * 60 + 10,
                title: "Английский язык", room: "210"
            ),
        ]
        let slots = WidgetSchedule.slots(of: lessons, on: day)
        let focus = WidgetFocus(
            stage: .tomorrow,
            day: WidgetDay(date: day, slots: slots),
            index: 0,
            next: slots[1]
        )
        return ScheduleEntry(date: now, content: .focus(focus))
    }
}
