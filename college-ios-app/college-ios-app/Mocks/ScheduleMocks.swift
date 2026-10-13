//
//  ScheduleMocks.swift
//  college-ios-app
//

#if DEBUG
import Foundation

nonisolated enum ScheduleMocks {

    static let selection = Selection(group: "ИТ26-11", subgroup: "Подгр1", englishGroup: "A0.11")

    static func week(monday: Date) -> [Lesson] {
        (0..<7).flatMap { offset in
            lessons(day: ScheduleCalendar.adding(days: offset, to: monday), weekday: offset)
        }
    }

    static func widgetSnapshot(monday: Date) -> WidgetSnapshot? {
        [monday, ScheduleCalendar.adding(weeks: 1, to: monday)].reduce(nil) { snapshot, week in
            WidgetSnapshot.merging(
                snapshot,
                lessons: self.week(monday: week),
                monday: week,
                selection: selection,
                resetsSelection: true,
                at: monday
            )
        }
    }

    static func lessons(day: Date, weekday: Int) -> [Lesson] {
        plan(for: weekday).enumerated().map { index, item in
            Lesson(
                id: "\(ScheduleParsing.requestString(from: day))-\(index)",
                day: day,
                start: slots[index].0,
                end: slots[index].1,
                title: item.0,
                topic: item.1,
                room: item.2,
                subgroups: item.3 ? subgroups : []
            )
        }
    }

    private static let slots: [(Int, Int)] = [
        (9 * 60, 10 * 60 + 30),
        (10 * 60 + 40, 12 * 60 + 10),
        (12 * 60 + 40, 14 * 60 + 10),
        (14 * 60 + 20, 15 * 60 + 50),
        (16 * 60, 17 * 60 + 30),
    ]

    private static let subgroups = [
        LessonSubgroup(
            id: "A0.11", title: "Английский A0.11", topic: "Present Simple",
            room: "210", classID: "mock-A0.11"
        ),
        LessonSubgroup(
            id: "A0.12", title: "Английский A0.12", topic: "Past Simple",
            room: "211", classID: "mock-A0.12"
        ),
    ]

    private static func plan(for weekday: Int) -> [(String, String, String, Bool)] {
        switch weekday {
        case 0:
            return [
                ("Математика", "Пределы и непрерывность", "301", false),
                ("Основы алгоритмизации", "Сортировки", "215", false),
                ("Английский язык", "", "", true),
                ("Физическая культура", "", "Спортзал", false),
            ]
        case 1:
            return [
                ("Базы данных", "Нормальные формы", "118", false),
                ("Разработка мобильных приложений", "Жизненный цикл экрана", "204", false),
                ("История", "Реформы Петра I", "402", false),
            ]
        case 3:
            return [
                ("Английский язык", "", "", true),
                ("Информационная безопасность", "Симметричное шифрование", "310", false),
            ]
        case 4:
            return [
                ("Математика", "Производная", "301", false),
                ("Веб-разработка", "Флексбоксы", "207", false),
                ("Операционные системы", "Процессы и потоки", "215", false),
                ("Психология общения", "", "405", false),
                ("Проектная деятельность", "Защита прототипа", "118", false),
            ]
        default:
            return []
        }
    }
}
#endif
