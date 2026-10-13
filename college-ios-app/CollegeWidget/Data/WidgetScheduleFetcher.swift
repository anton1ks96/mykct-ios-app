//
//  WidgetScheduleFetcher.swift
//  CollegeWidget
//

import Foundation

nonisolated struct WidgetScheduleFetcher: Sendable {
    private static let requestTimeout: TimeInterval = 15

    let baseURL: URL
    var session: URLSession = .shared

    static var live: WidgetScheduleFetcher? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "BaseScheduleURL") as? String,
              let url = URL(string: value),
              let host = url.host(), !host.hasSuffix(".invalid")
        else { return nil }
        return WidgetScheduleFetcher(baseURL: url)
    }

    func week(monday: Date, selection: Selection) async throws -> [Lesson] {
        var components = URLComponents(
            url: baseURL.appending(path: ScheduleQuery.path),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = ScheduleQuery.items(
            selection: selection,
            start: monday,
            end: ScheduleCalendar.adding(days: 6, to: monday)
        )
        guard let url = components?.url else { throw URLError(.badURL) }

        let request = URLRequest(url: url, timeoutInterval: Self.requestTimeout)
        let (data, response) = try await session.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(ScheduleResponse.self, from: data)
            .events
            .compactMap { $0.toLesson() }
    }
}
