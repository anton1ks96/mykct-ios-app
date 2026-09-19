//
//  LessonSplittingTests.swift
//  college-ios-appTests
//

import Foundation
import Testing
@testable import college_ios_app

private let day = ScheduleParsing.date(from: "2026-04-07")!

private func subgroup(_ id: String, _ title: String, room: String, classID: String) -> LessonSubgroup {
    LessonSubgroup(id: id, title: title, topic: "", room: room, classID: classID)
}

private func lesson(_ subgroups: [LessonSubgroup], title: String = "ПрофПредмет") -> Lesson {
    Lesson(
        id: "7028",
        day: day,
        start: 14 * 60 + 45,
        end: 16 * 60 + 15,
        title: title,
        subgroups: subgroups
    )
}

private let ownPair = [
    subgroup("FE", "УчПроект.FE", room: "3-2", classID: "8744"),
    subgroup("FE", "React", room: "2-5", classID: "8745"),
]

private let profiles = [
    subgroup("BE", "UML-BE", room: "3-2", classID: "8738"),
    subgroup("FE", "КомпСети", room: "3-3", classID: "8739"),
    subgroup("GD", "ПрогрC#", room: "3-0", classID: "8740"),
]

@Suite("Параллельные пары в слоте")
struct LessonSplittingTests {

    @Test("Две свои пары становятся отдельными занятиями")
    func ownLessonsAreSplit() {
        let result = LessonSplitting.split(
            [lesson(ownPair)],
            selection: Selection(group: "ИТ24-11", subgroup: "FE")
        )

        #expect(result.count == 2)
        #expect(result.map(\.title) == ["УчПроект.FE", "React"])
        #expect(result.map(\.room) == ["3-2", "2-5"])
        #expect(result.map(\.id) == ["8744", "8745"])
        #expect(result.allSatisfy { $0.subgroups.isEmpty })
        #expect(result.allSatisfy { $0.start == 14 * 60 + 45 && $0.end == 16 * 60 + 15 })
    }

    @Test("Пары других подгрупп остаются одним занятием")
    func foreignSubgroupsStayTogether() {
        let withoutSelection = LessonSplitting.split(
            [lesson(profiles)],
            selection: Selection(group: "ИТ24-11")
        )
        #expect(withoutSelection.count == 1)

        let ownProfile = LessonSplitting.split(
            [lesson(profiles)],
            selection: Selection(group: "ИТ24-11", subgroup: "BE")
        )
        #expect(ownProfile.count == 1)
    }

    @Test("Спортивные секции не разворачиваются")
    func sportSectionsStayTogether() {
        let sport = [
            subgroup("ФизраКол", "Физкульт", room: "СпортЗал", classID: "10623"),
            subgroup("БрайтФит", "Физкульт", room: "ФанФан", classID: "10622"),
        ]

        let result = LessonSplitting.split(
            [lesson(sport, title: "Физкульт")],
            selection: Selection(group: "ИТ25-11", subgroup: "Подгр1", englishGroup: "A0.11")
        )

        #expect(result.count == 1)
    }

    @Test("Своя английская группа тоже разворачивается")
    func englishGroupIsSplit() {
        let english = [
            subgroup("B1.21", "АнглЯзПро", room: "404", classID: "9001"),
            subgroup("B1.21", "Разговорный", room: "405", classID: "9002"),
        ]

        let result = LessonSplitting.split(
            [lesson(english, title: "АнглЯзПро")],
            selection: Selection(group: "ИТ24-11", englishGroup: "B1.21")
        )

        #expect(result.map(\.title) == ["АнглЯзПро", "Разговорный"])
    }

    @Test("Четыре и больше пар остаются одной карточкой")
    func tooManyLessonsStayTogether() {
        let many = (1...4).map { subgroup("FE", "Предмет\($0)", room: "3-\($0)", classID: "900\($0)") }

        let result = LessonSplitting.split(
            [lesson(many)],
            selection: Selection(group: "ИТ24-11", subgroup: "FE")
        )

        #expect(result.count == 1)
    }

    @Test("Занятие без подгрупп не меняется")
    func plainLessonIsUntouched() {
        let plain = Lesson(id: "7025", day: day, start: 540, end: 630, title: "ДискрМат", room: "3-1")

        let result = LessonSplitting.split([plain], selection: Selection(group: "ИТ24-11", subgroup: "FE"))

        #expect(result == [plain])
    }
}

@Suite("Заголовок занятия")
struct LessonDisplayTitleTests {

    @Test("Разные предметы подгрупп попадают в заголовок")
    func differentSubjectsAreJoined() {
        #expect(lesson(profiles).displayTitle == "UML-BE · КомпСети · ПрогрC#")
    }

    @Test("Одинаковый предмет оставляет название занятия")
    func sameSubjectKeepsTitle() {
        let english = (1...4).map { subgroup("A0.1\($0)", "АнглЯз", room: "40\($0)", classID: "86\($0)") }

        #expect(lesson(english, title: "АнглЯз").displayTitle == "АнглЯз")
        #expect(lesson([], title: "Математика").displayTitle == "Математика")
    }


    @Test("Параллельные пары считаются одной парой в слоте")
    func parallelLessonsCountAsOneSlot() {
        let split = LessonSplitting.split(
            [lesson(ownPair)],
            selection: Selection(group: "ИТ24-11", subgroup: "FE")
        )

        #expect(split.count == 2)
        #expect(split.slotCount == 1)
    }
}
