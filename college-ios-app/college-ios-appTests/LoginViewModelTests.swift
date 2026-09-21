//
//  LoginViewModelTests.swift
//  college-ios-appTests
//

import Foundation
import Testing
@testable import college_ios_app

private actor StubAuthAPI: AuthAPIProtocol {
    private(set) var lastUsername: String?

    private let signInError: Error?
    private let user = User(
        id: "i24s0291",
        username: "i24s0291",
        role: "student",
        academicGroup: "ИТ24-11",
        profile: "BE",
        subgroup: nil,
        englishGroup: "B1.21"
    )

    init(signInError: Error? = nil) {
        self.signInError = signInError
    }

    func signIn(username: String, password: String) async throws -> SignInResponse {
        lastUsername = username
        if let signInError { throw signInError }
        return SignInResponse(
            accessToken: "access",
            refreshToken: "refresh",
            accessExpiresIn: 3600,
            refreshExpiresIn: 60 * 60 * 24 * 30,
            user: user
        )
    }

    func getAccessToken(refreshToken: String) async throws -> AccessTokenResponse {
        AccessTokenResponse(accessToken: "access", expiresIn: 3600, user: user)
    }

    func refreshRefreshToken(refreshToken: String) async throws -> RefreshTokenResponse {
        RefreshTokenResponse(refreshToken: "refresh", expiresIn: 60 * 60 * 24 * 30)
    }

    func signOut(refreshToken: String) async throws {}
}

@MainActor
private func makeViewModel(api: StubAuthAPI) -> LoginViewModel {
    LoginViewModel(
        authService: AuthService(api: api, session: AuthSession(refreshStorage: InMemoryTokenStorage()))
    )
}

@MainActor
@Test("Пустые поля не дают отправить форму")
func emptyFieldsBlockSubmit() async throws {
    let api = StubAuthAPI()
    let viewModel = makeViewModel(api: api)

    #expect(viewModel.canSubmit == false)

    viewModel.login = "   "
    viewModel.password = "secret"
    #expect(viewModel.canSubmit == false)

    await viewModel.signIn()
    #expect(await api.lastUsername == nil)
    #expect(viewModel.didSignIn == false)
}

@MainActor
@Test("Успешный вход поднимает флаг и не оставляет ошибки")
func successfulSignInRaisesFlag() async throws {
    let viewModel = makeViewModel(api: StubAuthAPI())
    viewModel.login = "i24s0291"
    viewModel.password = "secret"

    await viewModel.signIn()

    #expect(viewModel.didSignIn)
    #expect(viewModel.error == nil)
    #expect(viewModel.isLoading == false)
}

@MainActor
@Test("Отказ сервера показывается пользователю по-русски")
func serverErrorIsShown() async throws {
    let viewModel = makeViewModel(api: StubAuthAPI(signInError: APIError.unauthorized(message: nil)))
    viewModel.login = "i24s0291"
    viewModel.password = "secret"

    await viewModel.signIn()

    #expect(viewModel.error == "Требуется авторизация")
    #expect(viewModel.didSignIn == false)
}

@MainActor
@Test("Правка поля гасит прежнюю ошибку")
func editingClearsError() async throws {
    let viewModel = makeViewModel(api: StubAuthAPI(signInError: APIError.unauthorized(message: nil)))
    viewModel.login = "i24s0291"
    viewModel.password = "secret"
    await viewModel.signIn()
    #expect(viewModel.error != nil)

    viewModel.password = "secret2"

    #expect(viewModel.error == nil)
}

@MainActor
@Test("Логин отправляется без пробелов по краям")
func loginIsTrimmed() async throws {
    let api = StubAuthAPI()
    let viewModel = makeViewModel(api: api)
    viewModel.login = "  i24s0291  "
    viewModel.password = "secret"

    await viewModel.signIn()

    #expect(await api.lastUsername == "i24s0291")
}
