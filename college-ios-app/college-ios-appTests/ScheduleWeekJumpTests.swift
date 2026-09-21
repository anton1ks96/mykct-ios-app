//
//  ScheduleWeekJumpTests.swift
//  college-ios-appTests
//

import Foundation
import Testing
@testable import college_ios_app

private actor CountingScheduleRepository: ScheduleRepositoryProtocol {
    private(set) var mondays: [Date] = []

    func weekSchedule(monday: Date, selection: Selection) async throws -> WeekSchedule {
        mondays.append(monday)
        return WeekSchedule(lessons: [])
    }

    func classDetails(id: String) async throws -> [DetailRow] {
        []
    }
}

@MainActor
private func makeViewModel() -> (ScheduleViewModel, CountingScheduleRepository) {
    let defaults = UserDefaults(suiteName: "schedule.tests.\(UUID().uuidString)")!
    let repository = CountingScheduleRepository()
    let viewModel = ScheduleViewModel(
        repository: repository,
        selectionStore: SelectionStore(defaults: defaults),
        settingsStore: ScheduleSettingsStore(defaults: defaults)
    )
    return (viewModel, repository)
}

private func loads(_ repository: CountingScheduleRepository, count: Int) async {
    while await repository.mondays.count < count { await Task.yield() }
}

@MainActor
@Suite("Переход на неделю из уведомления")
struct ScheduleWeekJumpTests {

    @Test("Неделя с сегодняшним днём открывается на сегодня")
    func currentWeekSelectsToday() async {
        let (viewModel, repository) = makeViewModel()
        let today = ScheduleCalendar.day(of: .now)

        viewModel.show(week: ScheduleCalendar.monday(of: today))
        await loads(repository, count: 1)

        #expect(viewModel.state.weekStart == ScheduleCalendar.monday(of: today))
        #expect(viewModel.state.selectedDate == today)
    }

    @Test("Чужая неделя открывается на понедельнике")
    func otherWeekSelectsMonday() async {
        let (viewModel, repository) = makeViewModel()
        let future = ScheduleCalendar.adding(weeks: 3, to: ScheduleCalendar.day(of: .now))
        let monday = ScheduleCalendar.monday(of: future)

        viewModel.show(week: ScheduleCalendar.adding(days: 2, to: monday))
        await loads(repository, count: 1)

        #expect(viewModel.state.weekStart == monday)
        #expect(viewModel.state.selectedDate == monday)
    }

    @Test("Переход на уже открытую неделю перезагружает расписание")
    func sameWeekReloads() async {
        let (viewModel, repository) = makeViewModel()
        let monday = ScheduleCalendar.monday(of: ScheduleCalendar.adding(weeks: 2, to: .now))

        viewModel.show(week: monday)
        await loads(repository, count: 1)
        viewModel.show(week: monday)
        await loads(repository, count: 2)

        #expect(await repository.mondays == [monday, monday])
    }

    @Test("Переход до открытия экрана второй загрузки не даёт")
    func jumpBeforeStart() async {
        let (viewModel, repository) = makeViewModel()
        let monday = ScheduleCalendar.monday(of: ScheduleCalendar.adding(weeks: 1, to: .now))

        viewModel.show(week: monday)
        await loads(repository, count: 1)
        await viewModel.start()

        #expect(await repository.mondays == [monday])
    }
}
