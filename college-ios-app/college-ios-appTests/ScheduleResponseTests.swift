//
//  ScheduleResponseTests.swift
//  college-ios-appTests
//

import Foundation
import Testing
@testable import college_ios_app

private func decodeSchedule(_ json: String) throws -> ScheduleResponse {
    try JSONDecoder().decode(ScheduleResponse.self, from: Data(json.utf8))
}

@Suite("Разбор ответа расписания")
struct ScheduleResponseTests {

    @Test("Занятие с подгруппами несёт их идентификаторы занятий")
    func subgroupsCarryClassIDs() throws {
        let response = try decodeSchedule("""
        {"events":[{"ClID":"8658","Day":"2026-06-01","start":"09:00","end":"10:30",
        "title":"АнглЯз","topic":"","room":"",
        "SubGroup":[{"SClID":"10618","SGrID":"A0.11","SGCaID":"404","STitle":"АнглЯз","STopic":""},
        {"SClID":"10621","SGrID":"B1.11","SGCaID":"410","STitle":"АнглЯз","STopic":""}]}],
        "source":"live","fetched_at":"2026-08-30T18:54:28Z","stale":false}
        """)

        let lesson = try #require(response.events.first?.toLesson())
        #expect(lesson.id == "8658")
        #expect(lesson.subgroups.map(\.classID) == ["10618", "10621"])
        #expect(lesson.subgroups.map(\.room) == ["404", "410"])
    }

    @Test("Схлопнутое занятие ведёт детали за подгруппой")
    func collapsedLessonKeepsSubgroupID() throws {
        let response = try decodeSchedule("""
        {"events":[{"ClID":"10621","Day":"2026-06-01","start":"09:00","end":"10:30",
        "title":"АнглЯз","topic":"","room":"410"}],"stale":false}
        """)

        let lesson = try #require(response.events.first?.toLesson())
        #expect(lesson.id == "10621")
        #expect(lesson.subgroups.isEmpty)

        let details = LessonDetails(lesson: lesson)
        #expect(details.detailsID == "10621")
    }

    @Test("Выбранная подгруппа меняет занятие, за деталями которого идём")
    func selectedSubgroupChangesDetailsID() throws {
        let response = try decodeSchedule("""
        {"events":[{"ClID":"8662","Day":"2026-06-02","start":"10:45","end":"12:15",
        "title":"Физкульт","topic":"","room":"",
        "SubGroup":[{"SClID":"10623","SGrID":"ФизраКол","SGCaID":"Зал","STitle":"Физкульт","STopic":""}]}]}
        """)

        let lesson = try #require(response.events.first?.toLesson())
        var details = LessonDetails(lesson: lesson)
        #expect(details.detailsID == "8662")

        details.selected = lesson.subgroups.first
        #expect(details.detailsID == "10623")
    }

    @Test("Признак снимка и время получения читаются из ответа")
    func staleFlagIsParsed() throws {
        let cached = try decodeSchedule("""
        {"events":[],"source":"cache","fetched_at":"2026-08-30T18:54:28Z","stale":true}
        """)
        #expect(cached.stale)
        #expect(cached.fetchedAt == Date(timeIntervalSince1970: 1_788_116_068))

        let legacy = try decodeSchedule(#"{"events":[]}"#)
        #expect(legacy.stale == false)
        #expect(legacy.fetchedAt == nil)
    }
}

@Suite("Ошибки API")
struct APIErrorTests {

    private let envelope = Data(#"{"code":"SCHEDULE_UNAVAILABLE","message":"Расписание недоступно"}"#.utf8)

    @Test("Сообщение бэкенда показывается пользователю")
    func envelopeMessageIsUsed() {
        let error = APIError.from(statusCode: 503, data: envelope)

        guard case .api(let code, let message, let status) = error else {
            Issue.record("ожидался кейс api, получен \(error)")
            return
        }
        #expect(code == "SCHEDULE_UNAVAILABLE")
        #expect(status == 503)
        #expect(error.errorDescription == message)
    }

    @Test("Ответ без конверта разбирается по статусу")
    func plainStatusesStayAsBefore() {
        guard case .server(let code) = APIError.from(statusCode: 500, data: nil) else {
            Issue.record("ожидался кейс server")
            return
        }
        #expect(code == 500)

        guard case .notFound = APIError.from(statusCode: 404, data: Data("<html>".utf8)) else {
            Issue.record("ожидался кейс notFound")
            return
        }
    }

    @Test("401 и 403 не подменяются конвертом: на них завязано обновление токена")
    func authStatusesKeepTheirCases() {
        guard case .unauthorized = APIError.from(statusCode: 401, data: envelope) else {
            Issue.record("ожидался кейс unauthorized")
            return
        }
        guard case .forbidden = APIError.from(statusCode: 403, data: envelope) else {
            Issue.record("ожидался кейс forbidden")
            return
        }
    }
}
