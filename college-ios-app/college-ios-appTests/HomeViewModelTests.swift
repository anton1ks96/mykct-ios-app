//
//  HomeViewModelTests.swift
//  college-ios-appTests
//

import Foundation
import Testing
@testable import college_ios_app

private actor CountingHomeRepository: HomeRepositoryProtocol {
    private(set) var months: [Date] = []

    func attendance(month: Date) async throws -> [AttendanceRecord] {
        months.append(month)
        return []
    }

    func streak() async throws -> Streak {
        throw APIError.cancelled
    }

    func leaderboard() async throws -> Leaderboard {
        throw APIError.cancelled
    }

    func subjects() async throws -> [Subject] {
        throw APIError.cancelled
    }

    func scores(subjectID: String, start: Date, end: Date) async throws -> [SubjectLesson] {
        []
    }
}

private let user = User(
    id: "i24s0291",
    username: "i24s0291",
    role: "student",
    academicGroup: "ИТ24-11",
    profile: "BE",
    subgroup: nil,
    englishGroup: "B1.21"
)

@MainActor
private func loaded() async -> (HomeViewModel, CountingHomeRepository) {
    let repository = CountingHomeRepository()
    let viewModel = HomeViewModel(repository: repository)
    viewModel.sync(user: user, isBootstrapping: false)
    await viewModel.refresh()
    return (viewModel, repository)
}

@Suite("Выбор дня и месяца")
@MainActor
struct HomeMonthTests {

    @Test("Экран открывается на текущем месяце и сегодняшнем дне")
    func start() async {
        let (viewModel, _) = await loaded()

        #expect(viewModel.state.month == ScheduleCalendar.monthStart(of: .now))
        #expect(viewModel.state.selected == ScheduleCalendar.day(of: .now))
    }

    @Test("Выбор дня в сеть не ходит")
    func selectDay() async {
        let (viewModel, repository) = await loaded()
        let before = await repository.months.count

        viewModel.select(date: ScheduleCalendar.adding(days: -3, to: .now))

        #expect(await repository.months.count == before)
    }

    @Test("Сегодня внутри открытого месяца не перезагружает данные")
    func todayInCurrentMonth() async {
        let (viewModel, repository) = await loaded()
        let before = await repository.months.count
        viewModel.select(date: ScheduleCalendar.adding(days: -5, to: .now))

        viewModel.goToToday()

        #expect(viewModel.state.selected == ScheduleCalendar.day(of: .now))
        #expect(await repository.months.count == before)
    }

    @Test("Сегодня из чужого месяца возвращает месяц и грузит его один раз")
    func todayFromOtherMonth() async {
        let (viewModel, repository) = await loaded()
        viewModel.shiftMonth(by: -2)
        await viewModel.refresh()
        let before = await repository.months.count

        viewModel.goToToday()
        await viewModel.refresh()

        #expect(viewModel.state.month == ScheduleCalendar.monthStart(of: .now))
        #expect(viewModel.state.selected == ScheduleCalendar.day(of: .now))
        #expect(await repository.months.count > before)
    }

    @Test("Листание уводит выбор на первое число чужого месяца")
    func shiftMonth() async {
        let (viewModel, _) = await loaded()

        viewModel.shiftMonth(by: -1)

        let month = ScheduleCalendar.adding(months: -1, to: ScheduleCalendar.monthStart(of: .now))
        #expect(viewModel.state.month == month)
        #expect(viewModel.state.selected == month)
    }

    @Test("Возврат в текущий месяц листанием выбирает сегодня")
    func shiftBack() async {
        let (viewModel, _) = await loaded()

        viewModel.shiftMonth(by: 1)
        viewModel.shiftMonth(by: -1)

        #expect(viewModel.state.month == ScheduleCalendar.monthStart(of: .now))
        #expect(viewModel.state.selected == ScheduleCalendar.day(of: .now))
    }
}

private actor LeaderboardRepositoryStub: HomeRepositoryProtocol {
    static let board = Leaderboard(
        top: [LeaderboardEntry(rank: 1, alias: "Быстрый Кэш 0x0001", streak: 12, isMe: false)],
        me: LeaderboardEntry(rank: 41, alias: "Тихий Индекс 0x00FF", streak: 2, isMe: true),
        participants: 214
    )

    private let failure: APIError?
    private let delay: Duration
    private(set) var calls = 0

    init(failure: APIError? = nil, delay: Duration = .zero) {
        self.failure = failure
        self.delay = delay
    }

    func attendance(month: Date) async throws -> [AttendanceRecord] { [] }

    func streak() async throws -> Streak {
        throw APIError.cancelled
    }

    func leaderboard() async throws -> Leaderboard {
        calls += 1
        try? await Task.sleep(for: delay)
        if let failure { throw failure }
        return Self.board
    }

    func subjects() async throws -> [Subject] { [] }

    func scores(subjectID: String, start: Date, end: Date) async throws -> [SubjectLesson] { [] }
}

private let teacher = User(
    id: "t0001",
    username: "t0001",
    role: "teacher",
    academicGroup: nil,
    profile: nil,
    subgroup: nil,
    englishGroup: nil
)

@MainActor
private func withLeaderboard(
    failure: APIError? = nil,
    delay: Duration = .zero,
    user signedIn: User = user
) -> (HomeViewModel, LeaderboardRepositoryStub) {
    let repository = LeaderboardRepositoryStub(failure: failure, delay: delay)
    let model = HomeViewModel(repository: repository)
    model.sync(user: signedIn, isBootstrapping: false)
    return (model, repository)
}

@Suite("Рейтинг посещений")
@MainActor
struct HomeLeaderboardTests {

    @Test("Таблица и своё место попадают в состояние")
    func loaded() async {
        let (model, _) = withLeaderboard()

        await model.loadLeaderboard()

        #expect(model.state.leaderboard == .loaded(LeaderboardRepositoryStub.board))
        #expect(model.state.leaderboard.board?.me.rank == 41)
        #expect(model.state.leaderboard.board?.participants == 214)
    }

    @Test(
        "Выключенный рейтинг - не ошибка экрана",
        arguments: [
            APIError.notFound,
            APIError.forbidden,
            APIError.api(code: "LEADERBOARD_DISABLED", message: "Рейтинг отключён", status: 404),
            APIError.api(code: "NOT_FOUND", message: "Маршрут не найден", status: 404),
            APIError.api(code: "LEADERBOARD_FORBIDDEN", message: "Только студентам", status: 403),
        ]
    )
    func unavailable(_ failure: APIError) async {
        let (model, _) = withLeaderboard(failure: failure)

        await model.loadLeaderboard()

        #expect(model.state.leaderboard == .unavailable)
    }

    @Test("Нерассчитанное место показывается текстом бэкенда")
    func notReady() async {
        let message = "Ваше место в рейтинге ещё рассчитывается, попробуйте позже"
        let (model, _) = withLeaderboard(
            failure: .api(code: "LEADERBOARD_NOT_READY", message: message, status: 409)
        )

        await model.loadLeaderboard()

        #expect(model.state.leaderboard == .failed(message))
    }

    @Test("Повторное открытие вкладки в сеть не ходит")
    func cached() async {
        let (model, repository) = withLeaderboard()

        await model.loadLeaderboard()
        await model.loadLeaderboard()

        #expect(await repository.calls == 1)
    }

    @Test("Открытие вкладки поверх незавершённого запроса его не сбрасывает")
    func keepsRequestInFlight() async {
        let (model, repository) = withLeaderboard(delay: .milliseconds(120))

        let loading = Task { await model.loadLeaderboard() }
        while await repository.calls == 0 { await Task.yield() }

        await model.loadLeaderboard()
        await loading.value

        #expect(await repository.calls == 1)
        #expect(model.state.leaderboard.board != nil)
    }

    @Test("После неудачи вкладка пробует снова")
    func retriesAfterFailure() async {
        let (model, repository) = withLeaderboard(failure: .notFound)

        await model.loadLeaderboard()
        await model.loadLeaderboard()

        #expect(await repository.calls == 2)
    }

    @Test("Обновление перезапрашивает рейтинг")
    func reload() async {
        let (model, repository) = withLeaderboard()

        await model.loadLeaderboard()
        await model.reloadLeaderboard()

        #expect(await repository.calls == 2)
    }

    @Test("Не студенту рейтинг не запрашивается")
    func notStudent() async {
        let (model, repository) = withLeaderboard(user: teacher)

        await model.loadLeaderboard()

        #expect(!model.state.canSeeLeaderboard)
        #expect(await repository.calls == 0)
    }

    @Test("Роль читается без оглядки на регистр")
    func roleCase() async {
        let shouting = User(
            id: user.id,
            username: user.username,
            role: "Student",
            academicGroup: user.academicGroup,
            profile: user.profile,
            subgroup: user.subgroup,
            englishGroup: user.englishGroup
        )
        let (model, repository) = withLeaderboard(user: shouting)

        await model.loadLeaderboard()

        #expect(model.state.canSeeLeaderboard)
        #expect(await repository.calls == 1)
    }

    @Test("Выход из аккаунта стирает рейтинг")
    func signOut() async {
        let (model, _) = withLeaderboard()
        await model.loadLeaderboard()

        model.sync(user: nil, isBootstrapping: false)

        #expect(model.state.leaderboard == .idle)
    }
}
