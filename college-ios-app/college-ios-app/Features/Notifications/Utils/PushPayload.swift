//
//  PushPayload.swift
//  college-ios-app
//

import Foundation

nonisolated enum PushPayload {

    static func route(from userInfo: [AnyHashable: Any]) -> PushRoute? {
        guard let rawKind = userInfo["type"] as? String,
              let kind = PushKind(rawValue: rawKind),
              let rawWeek = userInfo["week_start"] as? String,
              let week = ScheduleParsing.date(from: rawWeek)
        else { return nil }

        return PushRoute(kind: kind, weekStart: ScheduleCalendar.monday(of: week))
    }
}
