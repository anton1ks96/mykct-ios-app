//
//  ScheduleQueryTests.swift
//  college-ios-appTests
//

import Foundation
import Testing
@testable import college_ios_app

private let monday = ScheduleParsing.date(from: "2026-10-12")!
private let sunday = ScheduleCalendar.adding(days: 6, to: monday)

private func query(_ selection: Selection) -> [String: String] {
    let items = ScheduleQuery.items(selection: selection, start: monday, end: sunday)
    return Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") })
}

@Suite("Параметры запроса расписания")
struct ScheduleQueryTests {

    @Test("Группа и неделя передаются в формате yyyy-MM-dd")
    func requiredItems() {
        #expect(query(Selection(group: "ИТ24-11")) == [
            "group": "ИТ24-11",
            "start": "2026-10-12",
            "end": "2026-10-18",
        ])
    }

    @Test("Пустые и звёздочные подгруппы не попадают в запрос")
    func skipsEmptySubgroups() {
        let selection = Selection(
            group: "ИТ24-11",
            subgroup: "FE",
            englishGroup: "*",
            profileSubgroup: ""
        )

        #expect(query(selection)["subgroup"] == "FE")
        #expect(query(selection)["english_group"] == nil)
        #expect(query(selection)["profile_subgroup"] == nil)
    }
}
