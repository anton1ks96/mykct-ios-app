//
//  SignInInvite.swift
//  college-ios-app
//

import SwiftUI

struct SignInInvite: View {
    @Environment(\.colors) private var colors

    let onLogin: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Посещаемость и баллы")
                .textStyle(AppType.heroValue)
                .foregroundStyle(colors.onBackground)

            Text(
                """
                Стрик посещений, отметки по парам и баллы по предметам колледж отдаёт только \
                вошедшим. Нужен корпоративный логин и пароль.
                """
            )
            .textStyle(AppType.bodyLarge)
            .foregroundStyle(colors.onSurfaceVariant)
            .padding(.top, 8)

            Button(action: onLogin) {
                Text("Войти")
                    .textStyle(AppType.titleMedium)
            }
            .accentAction()
            .padding(.top, 28)
        }
        .padding(.top, 40)
    }
}

#Preview {
    SignInInvite(onLogin: {})
        .padding(.horizontal, 20)
        .appBackground()
        .environment(\.colors, .dark)
}
