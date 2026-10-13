//
//  ScheduleQuery.swift
//  college-ios-app
//

import Foundation

nonisolated enum ScheduleQuery {

    static let path = "/api/mykct/v1/schedule"

    static func items(selection: Selection, start: Date, end: Date) -> [URLQueryItem] {
        let optional = [
            ("subgroup", selection.subgroup),
            ("english_group", selection.englishGroup),
            ("profile_subgroup", selection.profileSubgroup),
        ]
        let required = [
            URLQueryItem(name: "group", value: selection.group),
            URLQueryItem(name: "start", value: ScheduleParsing.requestString(from: start)),
            URLQueryItem(name: "end", value: ScheduleParsing.requestString(from: end)),
        ]
        return required + optional.compactMap { name, value in
            guard let value, !value.isEmpty, value != "*" else { return nil }
            return URLQueryItem(name: name, value: value)
        }
    }
}
