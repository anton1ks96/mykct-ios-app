//
//  Lesson.swift
//  college-ios-app
//

import Foundation

nonisolated struct LessonSubgroup: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let topic: String
    let room: String
    let classID: String

    init(id: String, title: String, topic: String, room: String, classID: String = "") {
        self.id = id
        self.title = title
        self.topic = topic
        self.room = room
        self.classID = classID
    }
}

nonisolated struct LessonSlot: Hashable, Sendable {
    let start: Int
    let end: Int
}

nonisolated struct Lesson: Identifiable, Equatable, Sendable {
    let id: String
    let day: Date
    let start: Int
    let end: Int
    let title: String
    let topic: String
    let room: String
    let subgroups: [LessonSubgroup]

    init(
        id: String,
        day: Date,
        start: Int,
        end: Int,
        title: String,
        topic: String = "",
        room: String = "",
        subgroups: [LessonSubgroup] = []
    ) {
        self.id = id
        self.day = day
        self.start = start
        self.end = end
        self.title = title
        self.topic = topic
        self.room = room
        self.subgroups = subgroups
    }

    var slot: LessonSlot { LessonSlot(start: start, end: end) }

    var displayTitle: String {
        var names: [String] = []
        for name in subgroups.map(\.title) where !name.isEmpty && !names.contains(name) {
            names.append(name)
        }
        return names.count > 1 ? names.joined(separator: " · ") : title
    }

    func withSubgroup(_ subgroup: LessonSubgroup) -> Lesson {
        Lesson(
            id: subgroup.classID.isEmpty ? "\(id)-\(subgroup.id)" : subgroup.classID,
            day: day,
            start: start,
            end: end,
            title: subgroup.title.isEmpty ? title : subgroup.title,
            topic: subgroup.topic.isEmpty ? topic : subgroup.topic,
            room: subgroup.room.isEmpty ? room : subgroup.room
        )
    }
}

nonisolated extension Collection<Lesson> {

    var slotCount: Int {
        Set(map(\.slot)).count
    }
}
