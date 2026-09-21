//
//  LoginScreen.swift
//  college-ios-app
//

import SwiftUI

private nonisolated enum LoginField: Hashable {
    case login
    case password
}

struct LoginScreen: View {
    @Environment(\.colors) private var colors

    let onClose: () -> Void
    var onSkip: (() -> Void)?

    @State private var viewModel: LoginViewModel
    @FocusState private var focus: LoginField?

    init(
        viewModel: LoginViewModel = LoginViewModel(),
        onClose: @escaping () -> Void,
        onSkip: (() -> Void)? = nil
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.onClose = onClose
        self.onSkip = onSkip
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { proxy in
                ScrollView {
                    content
                        .padding(.horizontal, Metrics.screenPadding)
                        .padding(.top, 72)
                        .padding(.bottom, 24)
                        .frame(minHeight: proxy.size.height, alignment: .center)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .scrollDismissesKeyboard(.interactively)

            backButton
        }
        .appBackground()
        .onChange(of: viewModel.didSignIn) { _, signedIn in
            if signedIn { onClose() }
        }
    }

    // MARK: - Sections

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Вход")
                .textStyle(AppType.heroValue)
                .foregroundStyle(colors.onBackground)

            Text("Введите ваш корпоративный логин и пароль")
                .textStyle(AppType.bodyLarge)
                .foregroundStyle(colors.onSurfaceVariant)
                .padding(.top, 8)

            fields
                .padding(.top, 24)

            Button(action: submit) {
                Text(viewModel.isLoading ? "Входим…" : "Войти")
                    .textStyle(AppType.titleMedium)
            }
            .accentAction(isEnabled: viewModel.canSubmit)
            .disabled(!viewModel.canSubmit)
            .padding(.top, 24)

            Fade(value: viewModel.error ?? "") { message in
                hint(message)
            }
            .padding(.top, 16)

            if let onSkip {
                Button(action: onSkip) {
                    Text("Продолжить без входа")
                        .textStyle(AppType.titleMedium)
                        .foregroundStyle(colors.onBackground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
        }
    }

    private var fields: some View {
        GlassGroup(spacing: 12) {
            VStack(spacing: 12) {
                GlassField(
                    title: "Логин",
                    text: $viewModel.login,
                    contentType: .username,
                    field: LoginField.login,
                    focus: $focus,
                    onSubmit: { focus = .password }
                )
                .keyboardType(.asciiCapable)

                GlassField(
                    title: "Пароль",
                    text: $viewModel.password,
                    isSecure: true,
                    contentType: .password,
                    submitLabel: .go,
                    field: LoginField.password,
                    focus: $focus,
                    onSubmit: submit
                )
            }
        }
    }

    private var backButton: some View {
        Button(action: onClose) {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(colors.onBackground)
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .glassSurface(Circle(), interactive: true)
        .padding(.horizontal, Metrics.screenPadding)
        .padding(.top, 8)
        .accessibilityLabel("Назад")
    }

    private func hint(_ message: String) -> some View {
        Text(message.isEmpty ? Self.hintText : message)
            .textStyle(AppType.bodyMedium)
            .foregroundStyle(message.isEmpty ? colors.onSurfaceVariant : colors.danger)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Intents

    private func submit() {
        focus = nil
        Task { await viewModel.signIn() }
    }

    private static let hintText =
        "Вход нужен для посещаемости и баллов. Расписание работает и без него."
}

#Preview("Из настроек") {
    LoginScreen(viewModel: PreviewMocks.loginViewModel(), onClose: {})
        .environment(\.colors, .dark)
}

#Preview("С приветствия") {
    let error = APIError.unauthorized(message: "Неверный логин или пароль")

    return LoginScreen(
        viewModel: PreviewMocks.loginViewModel(error: error),
        onClose: {},
        onSkip: {}
    )
    .environment(\.colors, .light)
}
