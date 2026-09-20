//
//  HomeParsingTests.swift
//  college-ios-appTests
//

import Testing
import Foundation
@testable import college_ios_app

private let decoder = JSONDecoder()

private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
    try decoder.decode(type, from: Data(json.utf8))
}

private func date(_ value: String) -> Date {
    ScheduleParsing.date(from: value)!
}

@Suite("Разбор посещаемости")
struct AttendanceParsingTests {

    @Test("Голый null вместо массива читается как пустой список")
    func nullResponse() throws {
        let decoded = try decode([AttendanceDTO]?.self, "null")
        #expect((decoded ?? []).isEmpty)
    }

    @Test("Отсутствующие поля не роняют разбор")
    func missingFields() throws {
        let dto = try decode(AttendanceDTO.self, #"{"Day": "2026-08-24"}"#)

        #expect(dto.title.isEmpty)
        #expect(dto.status == -1)
        #expect(HomeParsing.record(from: dto)?.attendance == .unknown)
    }

    @Test("Идентификатор приходит и числом, и строкой")
    func identifier() throws {
        #expect(try decode(AttendanceDTO.self, #"{"ClID": 42}"#).clID == "42")
        #expect(try decode(AttendanceDTO.self, #"{"ClID": "42"}"#).clID == "42")
    }

    @Test("Прочерк вместо кабинета превращается в пустую строку")
    func dash() throws {
        let dto = try decode(AttendanceDTO.self, #"{"Day": "2026-08-24", "room": "—"}"#)
        #expect(HomeParsing.record(from: dto)?.room == "")
    }

    @Test("Запись без разбираемой даты выбрасывается")
    func brokenDate() throws {
        let dto = try decode(AttendanceDTO.self, #"{"Day": "не дата", "title": "Математика"}"#)
        #expect(HomeParsing.record(from: dto) == nil)
    }

    @Test("Время читается из даты со временем")
    func time() throws {
        let dto = try decode(
            AttendanceDTO.self,
            #"{"Day": "2026-08-24", "start": "2026-08-24 9:00", "end": "2026-08-24 10:30"}"#
        )
        let record = HomeParsing.record(from: dto)

        #expect(record?.start == 540)
        #expect(record?.end == 630)
    }

    @Test("Записи сортируются по дате и началу пары")
    func sorting() throws {
        let dtos = try decode([AttendanceDTO].self, """
        [
          {"ClID": 3, "Day": "2026-08-25", "start": "2026-08-25 9:00"},
          {"ClID": 2, "Day": "2026-08-24", "start": "2026-08-24 12:40"},
          {"ClID": 1, "Day": "2026-08-24", "start": "2026-08-24 9:00"},
          {"ClID": 0, "Day": "сломано"}
        ]
        """)

        #expect(HomeParsing.records(from: dtos).map(\.id) == ["1", "2", "3"])
    }

    @Test("Отметка дня берётся по худшему статусу")
    func marks() throws {
        let dtos = try decode([AttendanceDTO].self, """
        [
          {"ClID": 1, "Day": "2026-08-24", "status": 2},
          {"ClID": 2, "Day": "2026-08-24", "status": 0},
          {"ClID": 3, "Day": "2026-08-25", "status": 2},
          {"ClID": 4, "Day": "2026-08-25", "status": 1},
          {"ClID": 5, "Day": "2026-08-26", "status": 2},
          {"ClID": 6, "Day": "2026-08-27", "status": -1}
        ]
        """)
        let marks = HomeParsing.marks(from: HomeParsing.records(from: dtos))

        #expect(marks.count == 4)
        #expect(marks[date("2026-08-24")] == .absent)
        #expect(marks[date("2026-08-25")] == .excused)
        #expect(marks[date("2026-08-26")] == .present)
        #expect(marks[date("2026-08-27")] == .empty)
    }

    @Test("Пустой день отметки не получает")
    func emptyMark() {
        #expect(DayMark.of([]) == .empty)
    }
}

@Suite("Разбор баллов")
struct ScoresParsingTests {

    @Test("Вложенная карта разбирается в занятия, отсортированные по названию")
    func nested() throws {
        let response = try decode(ScoresResponse.self, """
        {
          "Разработка": {
            "Самостоятельная": [{"Score": "3", "MaxScore": 5, "Description": "Опрос"}],
            "Практическая": [{"Score": "5", "MaxScore": 5, "DateF": "2026-08-24T00:00:00"}]
          }
        }
        """)
        let lessons = HomeParsing.lessons(from: response)

        #expect(lessons.map(\.title) == ["Практическая", "Самостоятельная"])
        #expect(lessons[0].scores.first?.value == 5)
        #expect(lessons[0].scores.first?.date == ScheduleParsing.date(from: "2026-08-24"))
    }

    @Test("Пустой ответ даёт пустой список")
    func empty() throws {
        #expect(HomeParsing.lessons(from: try decode(ScoresResponse.self, "{}")).isEmpty)
    }

    @Test("Неоценённая работа читается как отсутствие балла")
    func notGraded() throws {
        let response = try decode(ScoresResponse.self, """
        {
          "Предмет": {
            "Занятие": [
              {"Score": "", "MaxScore": 5},
              {"Score": "—", "MaxScore": 5},
              {"Score": "4", "MaxScore": 5}
            ]
          }
        }
        """)
        let scores = HomeParsing.lessons(from: response).first?.scores ?? []

        #expect(scores.map(\.value) == [nil, nil, 4])
        #expect(scores.compactMap(\.value).count == 1)
    }

    @Test("Предмет берётся детерминированно, битая ветка пропускается")
    func brokenBranch() throws {
        let response = try decode(ScoresResponse.self, """
        {
          "Алгебра": {
            "Занятие": [{"Score": "4", "MaxScore": 5}],
            "Сломанное": "не массив"
          },
          "Геометрия": {"Занятие": [{"Score": "2", "MaxScore": 5}]}
        }
        """)
        let lessons = HomeParsing.lessons(from: response)

        #expect(lessons.map(\.title) == ["Занятие"])
        #expect(lessons[0].scores.first?.value == 4)
    }

    @Test("Средний балл считается без неоценённых работ")
    func average() {
        let scores = SubjectScores(
            subject: Subject(id: "1", title: "Разработка"),
            lessons: [
                SubjectLesson(title: "Практическая", scores: [
                    Score(id: "0", date: nil, value: 5, max: 5, details: ""),
                    Score(id: "1", date: nil, value: 4, max: 5, details: ""),
                    Score(id: "2", date: nil, value: nil, max: 5, details: ""),
                ]),
            ],
            isLoading: false
        )

        #expect(scores.graded.count == 2)
        #expect(scores.average == 4.5)
    }
}

@Suite("Разбор рейтинга")
struct LeaderboardParsingTests {

    @Test("Спортивные места приходят из ответа и не пересчитываются")
    func sportingRanks() throws {
        let dto = try decode(LeaderboardDTO.self, """
        {
          "top": [
            {"rank": 1, "alias": "Быстрый Кэш 0x0001", "current_streak": 12, "is_me": false},
            {"rank": 2, "alias": "Атомарный Буфер 0x0002", "current_streak": 9, "is_me": false},
            {"rank": 2, "alias": "Гибкий Сокет 0x0003", "current_streak": 9, "is_me": false},
            {"rank": 4, "alias": "Модульный Демон 0x0004", "current_streak": 7, "is_me": true}
          ],
          "me": {"rank": 4, "alias": "Модульный Демон 0x0004", "current_streak": 7, "is_me": true},
          "participants": 37
        }
        """)
        let board = try #require(HomeParsing.leaderboard(from: dto))

        #expect(board.top.map(\.rank) == [1, 2, 2, 4])
        #expect(board.participants == 37)
        #expect(board.isMeInTop)
    }

    @Test("Своя строка вне топа переживает разбор")
    func meOutsideTop() throws {
        let dto = try decode(LeaderboardDTO.self, """
        {
          "top": [{"rank": 1, "alias": "Быстрый Кэш 0x0001", "current_streak": 12, "is_me": false}],
          "me": {"rank": 41, "alias": "Тихий Индекс 0x00FF", "current_streak": 2, "is_me": true},
          "participants": 214
        }
        """)
        let board = try #require(HomeParsing.leaderboard(from: dto))

        #expect(!board.isMeInTop)
        #expect(board.me.rank == 41)
        #expect(board.me.streak == 2)
    }

    @Test("Строка без псевдонима выбрасывается")
    func brokenEntry() throws {
        let dto = try decode(LeaderboardDTO.self, """
        {
          "top": [
            {"rank": 1, "alias": "   ", "current_streak": 12},
            {"rank": 2, "alias": "Быстрый Кэш 0x0001", "current_streak": 9}
          ],
          "me": {"rank": 2, "alias": "Быстрый Кэш 0x0001", "current_streak": 9, "is_me": true},
          "participants": 20
        }
        """)
        let board = try #require(HomeParsing.leaderboard(from: dto))

        #expect(board.top.map(\.alias) == ["Быстрый Кэш 0x0001"])
    }

    @Test("Строка без места выбрасывается")
    func missingRank() throws {
        let dto = try decode(LeaderboardDTO.self, """
        {
          "top": [
            {"alias": "Безместный Демон 0x0007", "current_streak": 12},
            {"rank": 2, "alias": "Быстрый Кэш 0x0001", "current_streak": 9}
          ],
          "me": {"rank": 2, "alias": "Быстрый Кэш 0x0001", "current_streak": 9, "is_me": true},
          "participants": 20
        }
        """)
        let board = try #require(HomeParsing.leaderboard(from: dto))

        #expect(board.top.map(\.alias) == ["Быстрый Кэш 0x0001"])
    }

    @Test("Своя строка без места разбору не поддаётся")
    func meWithoutRank() throws {
        let dto = try decode(LeaderboardDTO.self, """
        {
          "top": [{"rank": 1, "alias": "Быстрый Кэш 0x0001", "current_streak": 12}],
          "me": {"alias": "Тихий Индекс 0x00FF", "current_streak": 2, "is_me": true},
          "participants": 20
        }
        """)

        #expect(HomeParsing.leaderboard(from: dto) == nil)
    }

    @Test("Ответ без своей строки разбору не поддаётся")
    func missingMe() throws {
        let dto = try decode(LeaderboardDTO.self, #"{"top": [], "participants": 0}"#)
        #expect(HomeParsing.leaderboard(from: dto) == nil)
    }
}
