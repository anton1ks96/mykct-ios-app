//
//  PushPayloadTests.swift
//  college-ios-appTests
//

import Foundation
import Testing
@testable import college_ios_app

@Suite("Разбор пуша")
struct PushPayloadTests {

    private func day(_ value: String) -> Date {
        ScheduleParsing.date(from: value)!
    }

    @Test("Уведомление о публикации превращается в маршрут недели")
    func publishedRoute() {
        let route = PushPayload.route(from: [
            "type": "schedule_published",
            "week_start": "2026-09-21"
        ])

        #expect(route?.kind == .published)
        #expect(route?.weekStart == day("2026-09-21"))
    }

    @Test("Дата недели приводится к понедельнику")
    func weekStartNormalized() {
        let route = PushPayload.route(from: [
            "type": "schedule_changed",
            "week_start": "2026-09-24"
        ])

        #expect(route?.kind == .changed)
        #expect(route?.weekStart == day("2026-09-21"))
    }

    @Test("Неизвестный тип уведомления маршрута не даёт")
    func unknownKind() {
        let route = PushPayload.route(from: [
            "type": "lesson_reminder",
            "week_start": "2026-09-21"
        ])

        #expect(route == nil)
    }

    @Test("Дата не в формате бэкенда маршрута не даёт")
    func brokenDate() {
        let route = PushPayload.route(from: [
            "type": "schedule_changed",
            "week_start": "21.09.2026"
        ])

        #expect(route == nil)
    }

    @Test("Уведомление без данных маршрута не даёт")
    func emptyPayload() {
        #expect(PushPayload.route(from: ["aps": ["alert": "Расписание"]]) == nil)
    }
}
