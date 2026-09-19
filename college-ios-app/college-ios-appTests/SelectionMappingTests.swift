//
//  SelectionMappingTests.swift
//  college-ios-appTests
//

import Foundation
import Testing
@testable import college_ios_app

private func makeUser(
    group: String?,
    profile: String? = nil,
    subgroup: String? = nil,
    englishGroup: String? = nil
) -> User {
    User(
        id: "i24s0291",
        username: "i24s0291",
        role: "student",
        academicGroup: group,
        profile: profile,
        subgroup: subgroup,
        englishGroup: englishGroup
    )
}

@Test("Группа не из справочника даёт пустой выбор")
func unknownGroupGivesNoSelection() {
    #expect(SelectionMapping.selection(of: makeUser(group: "ИТ-307")) == nil)
    #expect(SelectionMapping.selection(of: makeUser(group: nil)) == nil)
}

@Test("У первого курса подгруппа берётся из subgroup")
func firstYearTakesSubgroup() throws {
    let selection = try #require(
        SelectionMapping.selection(
            of: makeUser(group: "ИТ26-11", profile: "BE", subgroup: "Подгр2", englishGroup: "A1.11")
        )
    )

    #expect(selection.group == "ИТ26-11")
    #expect(selection.subgroup == "Подгр2")
    #expect(selection.englishGroup == "A1.11")
    #expect(selection.profileSubgroup == nil)
}

@Test("У старших курсов подгруппа берётся из профиля")
func seniorYearTakesProfile() throws {
    let selection = try #require(
        SelectionMapping.selection(
            of: makeUser(group: "ИТ24-11", profile: "BE", subgroup: "Подгр1", englishGroup: "A1.31")
        )
    )

    #expect(selection.subgroup == "BE")
    #expect(selection.profileSubgroup == nil)
}

@Test("Подгруппа профиля подставляется только там, где она есть")
func profileSubgroupOnlyWhereDefined() throws {
    let dividedSelection = try #require(
        SelectionMapping.selection(
            of: makeUser(group: "ИТ24-14", profile: "CD", subgroup: "Подгр1")
        )
    )
    #expect(dividedSelection.profileSubgroup == "Подгр1")

    let plainSelection = try #require(
        SelectionMapping.selection(
            of: makeUser(group: "ИТ24-14", profile: "BE", subgroup: "Подгр1")
        )
    )
    #expect(plainSelection.profileSubgroup == nil)
}

@Test("Английская группа чужого курса отбрасывается")
func foreignEnglishGroupIsDropped() throws {
    let selection = try #require(
        SelectionMapping.selection(
            of: makeUser(group: "ИТ24-11", profile: "BE", englishGroup: "A0.11")
        )
    )

    #expect(selection.englishGroup == nil)
}
