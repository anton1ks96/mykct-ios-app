//
//  HomeMocks.swift
//  college-ios-app
//

#if DEBUG
import Foundation

nonisolated final class MockHomeRepository: HomeRepositoryProtocol {

    private let delay: Duration
    private let failure: Error?

    init(delay: Duration = .milliseconds(350), failure: Error? = nil) {
        self.delay = delay
        self.failure = failure
    }

    func attendance(month: Date) async throws -> [AttendanceRecord] {
        try? await Task.sleep(for: delay)
        if let failure { throw failure }
        return HomeMocks.records(month: month)
    }

    func streak() async throws -> Streak {
        try? await Task.sleep(for: delay)
        if let failure { throw failure }
        return HomeMocks.streak
    }

    func leaderboard() async throws -> Leaderboard {
        try? await Task.sleep(for: delay)
        if let failure { throw failure }
        return HomeMocks.leaderboard
    }

    func subjects() async throws -> [Subject] {
        try? await Task.sleep(for: delay)
        if let failure { throw failure }
        return HomeMocks.subjects
    }

    func scores(subjectID: String, start: Date, end: Date) async throws -> [SubjectLesson] {
        try? await Task.sleep(for: delay)
        if let failure { throw failure }
        return HomeMocks.lessons
    }
}

nonisolated enum HomeMocks {

    static let user = User(
        id: "i24s0291",
        username: "i24s0291",
        role: "student",
        academicGroup: "ИТ24-11",
        profile: "BE",
        subgroup: nil,
        englishGroup: "B1.21"
    )

    static let streak = Streak(
        current: 5,
        longest: 9,
        daysAttended: 40,
        schoolDays: 45,
        lastAttended: ScheduleCalendar.day(of: .now),
        periodStart: HomeSemester.bounds(for: .now).start,
        periodEnd: HomeSemester.bounds(for: .now).end
    )

    static let leaderboard = Leaderboard(
        top: topRows.map { LeaderboardEntry(rank: $0.0, alias: $0.1, streak: $0.2, isMe: false) },
        me: LeaderboardEntry(rank: 14, alias: "Асинхронный Планировщик 0x5D91", streak: 5, isMe: true),
        participants: 214
    )

    private static let topRows: [(Int, String, Int)] = [
        (1, "Рекурсивный Компилятор 0x1A7C", 14),
        (2, "Атомарный Планировщик 0x04F1", 12),
        (2, "Векторный Кэш 0x7B20", 12),
        (4, "Гибридный Маршрутизатор 0x2E55", 11),
        (5, "Детерминированный Индекс 0x9C13", 9),
        (5, "Реактивный Сокет 0x3F8A", 9),
        (7, "Потоковый Дескриптор 0x60D4", 8),
        (8, "Модульный Транслятор 0x11B9", 7),
        (8, "Кластерный Демон 0x8A47", 7),
        (10, "Символьный Буфер 0xC302", 6),
    ]

    static let subjects = [
        Subject(id: "1", title: "Разработка программных модулей"),
        Subject(id: "2", title: "Базы данных"),
        Subject(id: "3", title: "Операционные системы"),
        Subject(id: "4", title: "Иностранный язык"),
        Subject(id: "5", title: "Математика"),
        Subject(id: "6", title: "Физическая культура"),
    ]

    static let lessons = [
        SubjectLesson(
            title: "Практическая работа",
            scores: [
                Score(id: "p0", date: day(-21), value: 5, max: 5, details: "Вёрстка макета"),
                Score(id: "p1", date: day(-14), value: 3, max: 5, details: "Формы и валидация"),
                Score(id: "p2", date: day(-7), value: 4, max: 5, details: ""),
            ]
        ),
        SubjectLesson(
            title: "Самостоятельная работа",
            scores: [
                Score(id: "s0", date: day(-10), value: 2, max: 5, details: "Опрос по теме"),
                Score(id: "s1", date: day(-3), value: nil, max: 5, details: "Реферат"),
            ]
        ),
    ]

    static func records(month: Date) -> [AttendanceRecord] {
        let start = ScheduleCalendar.monthStart(of: month)
        let today = ScheduleCalendar.day(of: .now)

        return (0..<ScheduleCalendar.days(inMonth: start)).flatMap { offset -> [AttendanceRecord] in
            let date = ScheduleCalendar.adding(days: offset, to: start)
            let weekday = ScheduleCalendar.weekdayIndex(of: date)
            guard weekday <= 5, date <= today else { return [] }

            let day = offset + 1
            return plan[weekday - 1].enumerated().map { index, lesson in
                AttendanceRecord(
                    id: "\(ScheduleParsing.requestString(from: date))-\(index)",
                    date: date,
                    start: slots[index].0,
                    end: slots[index].1,
                    title: lesson.0,
                    topic: lesson.1,
                    room: lesson.2,
                    attendance: attendance(day: day, lesson: index)
                )
            }
        }
    }

    private static func attendance(day: Int, lesson: Int) -> Attendance {
        switch (day * 7 + lesson * 3) % 29 {
        case 0: .absent
        case 1: .excused
        default: .present
        }
    }

    private static func day(_ offset: Int) -> Date {
        ScheduleCalendar.adding(days: offset, to: ScheduleCalendar.day(of: .now))
    }

    private static let slots: [(Int, Int)] = [
        (9 * 60, 10 * 60 + 30),
        (10 * 60 + 40, 12 * 60 + 10),
        (12 * 60 + 40, 14 * 60 + 10),
        (14 * 60 + 20, 15 * 60 + 50),
    ]

    private static let plan: [[(String, String, String)]] = [
        [
            ("Разработка программных модулей", "Паттерны проектирования", "305"),
            ("Базы данных", "Индексы и планы запросов", "412"),
            ("Математика", "Производная сложной функции", "210"),
            ("Иностранный язык", "Present Perfect", "118"),
        ],
        [
            ("Операционные системы", "Права доступа", "305"),
            ("Физическая культура", "", "Спортзал"),
            ("Разработка программных модулей", "Рефакторинг", "305"),
            ("Базы данных", "Транзакции", "412"),
        ],
        [
            ("Математика", "Ряды", "210"),
            ("Иностранный язык", "Технический перевод", "118"),
            ("Базы данных", "Нормализация", "412"),
            ("Операционные системы", "Виртуальная память", "305"),
        ],
        [
            ("Математика", "Интегралы", "210"),
            ("Разработка программных модулей", "Тестирование модулей", "305"),
            ("Иностранный язык", "Аудирование", "118"),
            ("Операционные системы", "Процессы и потоки", "305"),
        ],
        [
            ("Базы данных", "Транзакции и блокировки", "412"),
            ("Физическая культура", "", "Спортзал"),
            ("Разработка программных модулей", "Курсовой проект", "305"),
            ("Математика", "Ряды Фурье", "210"),
        ],
    ]
}
#endif
