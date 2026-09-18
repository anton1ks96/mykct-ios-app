//
//  AccountSheet.swift
//  college-ios-app
//

import SwiftUI

struct AccountSheet: View {
    @Environment(\.colors) private var colors
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var sessionViewModel: SessionViewModel

    @State private var didApplyGroup = false
    @State private var isSignOutConfirming = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if let user = sessionViewModel.user {
                    VStack(alignment: .leading, spacing: 0) {
                        SettingsSectionTitle("Информация об аккаунте")
                        SettingsCard {
                            ForEach(Array(rows(for: user).enumerated()), id: \.element.title) { index, row in
                                if index > 0 {
                                    SettingsDivider()
                                }
                                SettingsRow(icon: row.icon, title: row.title) {
                                    Text(row.value)
                                        .textStyle(AppType.bodyMedium)
                                        .foregroundStyle(colors.onSurfaceVariant)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                            }
                        }

                        SettingsSectionTitle("Действия")
                        SettingsCard {
                            if let selection = SelectionMapping.selection(of: user) {
                                applyGroupRow(selection)
                                SettingsDivider()
                            }
                            signOutRow
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .appBackground()
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Выйти из аккаунта?", isPresented: $isSignOutConfirming) {
                Button("Отмена", role: .cancel) {}
                Button("Выйти", role: .destructive) {
                    sessionViewModel.signOut()
                    dismiss()
                }
            } message: {
                Text("Вы уверены, что хотите выйти из аккаунта?")
            }
        }
    }

    // MARK: - Rows

    private var signOutRow: some View {
        Button {
            isSignOutConfirming = true
        } label: {
            SettingsRow(
                icon: "rectangle.portrait.and.arrow.right",
                title: "Выйти из аккаунта",
                tint: colors.danger
            ) {}
        }
        .buttonStyle(SettingsRowButtonStyle())
        .accessibilityElement(children: .combine)
    }

    private func applyGroupRow(_ selection: Selection) -> some View {
        Button {
            SelectionStore().save(selection)
            didApplyGroup = true
        } label: {
            SettingsRow(icon: "calendar", title: "Использовать мою группу") {
                if didApplyGroup {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(colors.primary)
                        .accessibilityHidden(true)
                }
            }
        }
        .buttonStyle(SettingsRowButtonStyle())
        .accessibilityElement(children: .combine)
    }

    // MARK: - Data

    private struct Row {
        let icon: String
        let title: String
        let value: String
    }

    private func rows(for user: User) -> [Row] {
        let group = user.academicGroup
        var rows = [
            Row(icon: "person.circle", title: "Логин", value: user.id),
            Row(icon: "person.text.rectangle", title: "ФИО", value: user.username),
        ]

        if let group {
            rows.append(Row(icon: "graduationcap", title: "Группа", value: group))
        }

        if let profile = user.profile {
            rows.append(Row(icon: "briefcase", title: "Профиль", value: title(of: profile, for: user)))
        }

        if let englishGroup = user.englishGroup {
            rows.append(
                Row(icon: "globe.europe.africa", title: "Группа английского", value: englishGroup)
            )
        }

        if let subgroup = user.subgroup {
            rows.append(
                Row(icon: "number.square", title: "Подгруппа", value: title(of: subgroup, for: user))
            )
        }

        return rows
    }

    private func title(of id: String, for user: User) -> String {
        guard let group = user.academicGroup else { return id }
        let named = Groups.subgroups(of: group)
            + Groups.profileSubgroups(of: group, subgroup: user.profile)
        return named.first { $0.id == id }?.title ?? id
    }
}

#Preview {
    AccountSheet()
        .environmentObject(PreviewMocks.sessionViewModel())
}
