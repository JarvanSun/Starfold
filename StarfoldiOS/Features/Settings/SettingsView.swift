//
//  SettingsView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct SettingsView: View {
    @State private var isConfirmingSignOut = false
    @State private var isEditingTouchLayout = false

    let settingsViewModel: SettingsViewModel

    let onAddAccount: () -> Void

    var body: some View {
        form
            .navigationTitle(Text("settings.title"))
            .confirmationDialog(
                "settings.signOut.confirmation \(settingsViewModel.signOutSubject)",
                isPresented: $isConfirmingSignOut,
                titleVisibility: .visible
            ) {
                Button("settings.signOut.confirm", role: .destructive) {
                    settingsViewModel.signOut()
                }
            }
            .touchLayoutEditorCover(
                isPresented: $isEditingTouchLayout,
                settingsViewModel: settingsViewModel
            )
    }

    private var form: some View {
        Form {
            StreamingSettingsSection(settingsViewModel: settingsViewModel)

            DisplaySettingsSection(settingsViewModel: settingsViewModel)

            ControlsSettingsSection(settingsViewModel: settingsViewModel) { editTouchLayout() }

            if settingsViewModel.hasAccounts {
                accountSection
            }
        }
    }

    private func editTouchLayout() {
        settingsViewModel.editTouchLayout()
        isEditingTouchLayout = true
    }

    private var accountSection: some View {
        AccountSettingsSection(
            accounts: settingsViewModel.accountChoices,
            onSwitch: { switchAccount(to: $0) },
            onAdd: onAddAccount,
            onSignOut: { isConfirmingSignOut = true }
        )
    }

    private func switchAccount(to account: AccountChoice) {
        Task { await settingsViewModel.switchAccount(to: account) }
    }
}

#if DEBUG
#Preview {
    let appViewModel = PreviewObjectPool.appViewModel(signedIn: true)
    NavigationStack {
        SettingsView(settingsViewModel: appViewModel.settingsViewModel, onAddAccount: {})
    }
    .environment(appViewModel)
}
#endif
