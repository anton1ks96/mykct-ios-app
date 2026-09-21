//
//  AppDependencies.swift
//  college-ios-app
//

import Foundation

enum AppDependencies {
    static let refreshStorage = KeychainTokenStorage()
    static let authSession = AuthSession(refreshStorage: refreshStorage)
    static let decoder = JSONDecoder()

    static let authClient = AFHTTPClient(baseURL: AppEnvironment.authBaseURL, decoder: decoder)
    static let authAPI: AuthAPIProtocol = {
        let live = AuthAPI(client: authClient)
#if DEBUG
        return AppEnvironment.usesMockData ? MockAuthAPI() : live
#else
        return live
#endif
    }()

    static let authService = AuthService(api: authAPI, session: authSession)

    static let interceptor = AuthRequestInterceptor(authService: authService)
    static let authenticatedClient = AFHTTPClient(
        baseURL: AppEnvironment.scheduleBaseURL,
        decoder: decoder,
        interceptor: interceptor
    )

    static let scheduleClient = AFHTTPClient(baseURL: AppEnvironment.scheduleBaseURL, decoder: decoder)

    static let scheduleRepository: ScheduleRepositoryProtocol = {
        let live = ScheduleRepository(api: ScheduleAPI(client: scheduleClient))
#if DEBUG
        return AppEnvironment.usesMockData ? MockScheduleRepository() : live
#else
        return live
#endif
    }()

    static let pushAPI: PushAPIProtocol = {
        let live = PushAPI(authenticatedClient: authenticatedClient, publicClient: scheduleClient)
#if DEBUG
        return AppEnvironment.usesMockData ? MockPushAPI() : live
#else
        return live
#endif
    }()

    static let pushService = PushService()

    static let homeRepository: HomeRepositoryProtocol = {
        let live = HomeRepository(api: HomeAPI(client: authenticatedClient))
#if DEBUG
        return AppEnvironment.usesMockData ? MockHomeRepository() : live
#else
        return live
#endif
    }()
}
