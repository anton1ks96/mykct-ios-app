//
//  WelcomeScreen.swift
//  college-ios-app
//

import SwiftUI

struct WelcomeScreen: View {
    private let colors = AppColors.dark

    let onEnter: () -> Void

    @State private var isLoginPresented = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            Text("Добро пожаловать в МойКЦТ")
                .textStyle(AppType.heroValue)
                .foregroundStyle(colors.onBackground)
                .multilineTextAlignment(.center)

            Text("Расписание, посещаемость и баллы — всё в одном приложении.")
                .textStyle(AppType.bodyLarge)
                .foregroundStyle(colors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.top, 12)

            Button {
                isLoginPresented = true
            } label: {
                Text("Войти")
                    .textStyle(AppType.titleMedium)
            }
            .accentAction()
            .padding(.top, 32)

            Button(action: onEnter) {
                Text("Нет аккаунта? ")
                    .foregroundStyle(colors.onSurfaceVariant)
                    + Text("Продолжить без входа")
                    .foregroundStyle(colors.onBackground)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.plain)
            .textStyle(AppType.bodyLarge)
            .multilineTextAlignment(.center)
            .padding(.top, 20)

            Text("Расписание доступно без входа. Вход нужен для посещаемости и баллов.")
                .textStyle(AppType.bodySmall)
                .foregroundStyle(colors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .loginBackdrop()
        .fullScreenCover(isPresented: $isLoginPresented) {
            LoginScreen(
                onClose: { isLoginPresented = false },
                onSkip: onEnter
            )
        }
    }

}

#Preview {
    WelcomeScreen(onEnter: {})
}
