//
//  GlassField.swift
//  college-ios-app
//

import SwiftUI

struct GlassField<Field: Hashable>: View {
    @Environment(\.colors) private var colors

    let title: String
    @Binding var text: String
    var isSecure: Bool = false
    var contentType: UITextContentType?
    var submitLabel: SubmitLabel = .next
    let field: Field
    @FocusState.Binding var focus: Field?
    let onSubmit: () -> Void

    @State private var isRevealed = false

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: Metrics.rowRadius, style: .continuous)
    }

    private var isFocused: Bool { focus == field }

    var body: some View {
        HStack(spacing: 12) {
            input
                .textStyle(AppType.bodyLarge)
                .foregroundStyle(colors.onSurface)
                .tint(colors.primary)
                .textContentType(contentType)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(submitLabel)
                .focused($focus, equals: field)
                .onSubmit(onSubmit)

            if isSecure {
                revealButton
            }
        }
        .padding(.horizontal, Metrics.cardPadding)
        .padding(.vertical, 15)
        .glassSurface(shape)
        .overlay {
            RoundedRectangle(cornerRadius: Metrics.rowRadius + 3, style: .continuous)
                .strokeBorder(colors.primary.opacity(isFocused ? 1 : 0), lineWidth: 2)
                .padding(-3)
        }
        .shadow(color: colors.primary.opacity(isFocused ? 0.35 : 0), radius: 14)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }

    // MARK: - Parts

    @ViewBuilder
    private var input: some View {
        if isSecure && !isRevealed {
            SecureField(title, text: $text)
        } else {
            TextField(title, text: $text)
        }
    }

    private var revealButton: some View {
        Button {
            isRevealed.toggle()
            focus = field
        } label: {
            Image(systemName: isRevealed ? "eye.slash" : "eye")
                .font(.system(size: 17))
                .foregroundStyle(colors.primary)
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isRevealed ? "Скрыть пароль" : "Показать пароль")
    }
}

#Preview {
    @Previewable @FocusState var focus: String?
    @Previewable @State var login = ""
    @Previewable @State var password = "secret"

    return GlassGroup(spacing: 12) {
        VStack(spacing: 12) {
            GlassField(
                title: "Логин",
                text: $login,
                contentType: .username,
                field: "login",
                focus: $focus,
                onSubmit: { focus = "password" }
            )

            GlassField(
                title: "Пароль",
                text: $password,
                isSecure: true,
                contentType: .password,
                submitLabel: .done,
                field: "password",
                focus: $focus,
                onSubmit: { focus = nil }
            )
        }
    }
    .padding(Metrics.screenPadding)
    .appBackground()
    .environment(\.colors, .dark)
}
