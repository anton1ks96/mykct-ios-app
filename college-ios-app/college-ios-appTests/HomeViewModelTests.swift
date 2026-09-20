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
