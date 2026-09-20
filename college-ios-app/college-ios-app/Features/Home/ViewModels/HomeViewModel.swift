//
//  HomeViewModel.swift
//  college-ios-app
//

import Foundation

@Observable
final class HomeViewModel {

    private(set) var state: HomeState

    private let repository: HomeRepositoryProtocol

    private var loadTask: Task<Void, Never>?
    private var scoresTask: Task<Void, Never>?
    private var leaderboardTask: Task<Void, Never>?

    init(repository: HomeRepositoryProtocol = AppDependencies.homeRepository) {
        self.repository = repository
        state = HomeState(
            month: ScheduleCalendar.monthStart(of: .now),
            selected: ScheduleCalendar.day(of: .now)
        )
    }

    // MARK: - Intents

    func sync(user: User?, isBootstrapping: Bool) {
        let wasAuthenticated = state.isAuthenticated

        state.user = user
        state.isBootstrapping = isBootstrapping

        if user == nil {
            clear()
            return
        }

        if !wasAuthenticated {
            Task { await reload() }
        }
    }

    func refresh() async {
        guard state.isAuthenticated else { return }
        await reload()
    }

    func shiftMonth(by months: Int) {
        let month = ScheduleCalendar.adding(months: months, to: state.month)
        state.month = month
        state.selected = pick(in: month)
        Task { await reload() }
    }

    func goToToday() {
        let today = ScheduleCalendar.day(of: .now)
        state.selected = today

        let month = ScheduleCalendar.monthStart(of: today)
        guard month != state.month else { return }
        state.month = month
        Task { await reload() }
    }

    func select(date: Date) {
        state.selected = date
    }

    func openSubject(_ subject: Subject) {
        scoresTask?.cancel()
        state.scores = SubjectScores(subject: subject)

        let bounds = HomeSemester.bounds(for: .now)
        scoresTask = Task { [repository] in
            do {
                let lessons = try await repository.scores(
                    subjectID: subject.id,
                    start: bounds.start,
                    end: bounds.end
                )
                guard state.scores?.subject.id == subject.id else { return }
                state.scores?.lessons = lessons
                state.scores?.isLoading = false
            } catch {
                guard !ErrorText.isCancellation(error), state.scores?.subject.id == subject.id else { return }
                state.scores?.isLoading = false
                state.scores?.error = ErrorText.message(for: error) ?? "Не удалось загрузить баллы"
            }
        }
    }

    func closeSubject() {
        scoresTask?.cancel()
        state.scores = nil
    }

    func loadLeaderboard() async {
        switch state.leaderboard {
        case .loading, .loaded: return
        case .idle, .unavailable, .failed: await reloadLeaderboard()
        }
    }

    func reloadLeaderboard() async {
        guard state.canSeeLeaderboard else { return }

        leaderboardTask?.cancel()
        state.leaderboard = .loading

        let task = Task {
            do {
                let board = try await repository.leaderboard()
                try Task.checkCancellation()
                state.leaderboard = .loaded(board)
            } catch {
                guard !ErrorText.isCancellation(error) else { return }
                state.leaderboard = feed(for: error)
            }
        }
        leaderboardTask = task
        _ = await task.value
    }

    // MARK: - Loading

    private func reload() async {
        loadTask?.cancel()
        let task = Task { await performLoad() }
        loadTask = task
        _ = await task.value
    }

    private func performLoad() async {
        state.isLoading = true

        await loadAttendance()
        await loadStreak()
        await loadSubjects()

        guard !Task.isCancelled else { return }
        state.isLoading = false
    }

    private func loadAttendance() async {
        do {
            let records = try await repository.attendance(month: state.month)
            try Task.checkCancellation()
            let stats = AttendanceStats.of(records)
            state.records = records
            state.marks = HomeParsing.marks(from: records)
            state.stats = stats
            state.motivation = stats.total > 0 ? HomeFormat.motivation(percent: stats.percent) : nil
            state.error = nil
        } catch {
            guard !ErrorText.isCancellation(error) else { return }
            state.records = []
            state.marks = [:]
            state.stats = .empty
            state.motivation = nil
            state.error = ErrorText.message(for: error) ?? "Не удалось загрузить посещаемость"
        }
    }

    private func loadStreak() async {
        do {
            let streak = try await repository.streak()
            try Task.checkCancellation()
            state.streak = streak
        } catch {
            return
        }
    }

    private func loadSubjects() async {
        do {
            let subjects = try await repository.subjects()
            try Task.checkCancellation()
            state.subjects = subjects
        } catch {
            return
        }
    }

    private func feed(for error: Error) -> LeaderboardFeed {
        if let apiError = error as? APIError, isUnavailable(apiError) {
            return .unavailable
        }

        return .failed(ErrorText.message(for: error) ?? "Не удалось загрузить рейтинг")
    }

    private func isUnavailable(_ error: APIError) -> Bool {
        switch error {
        case .notFound, .forbidden: true
        case let .api(_, _, status): status == 404 || status == 403
        default: false
        }
    }

    private func pick(in month: Date) -> Date {
        let today = ScheduleCalendar.day(of: .now)
        return ScheduleCalendar.isSameMonth(month, today) ? today : month
    }

    private func clear() {
        loadTask?.cancel()
        scoresTask?.cancel()
        leaderboardTask?.cancel()
        state.records = []
        state.marks = [:]
        state.stats = .empty
        state.motivation = nil
        state.streak = nil
        state.leaderboard = .idle
        state.subjects = []
        state.scores = nil
        state.error = nil
        state.isLoading = false
    }
}
