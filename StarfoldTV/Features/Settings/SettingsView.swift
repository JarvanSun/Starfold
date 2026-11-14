//
//  SettingsView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import SwiftUI

struct SettingsView: View {
    @State private var isConfirmingSignOut = false

    let settingsViewModel: SettingsViewModel

    let onAddAccount: () -> Void

    var body: some View {
        Form {
            QualitySettingsSection(settingsViewModel: settingsViewModel)

            CloudGamingSettingsSection(settingsViewModel: settingsViewModel)

            PictureSettingsSection(settingsViewModel: settingsViewModel)

            ControllerSettingsSection(settingsViewModel: settingsViewModel)

            AccountSettingsSection(
                accounts: settingsViewModel.accountChoices,
                onSwitch: { switchAccount(to: $0) },
                onAdd: onAddAccount,
                onSignOut: { confirmSignOut() }
            )

            AppearanceSettingsSection(settingsViewModel: settingsViewModel)
        }
        .confirmationDialog(
            "settings.signOut.confirmation \(settingsViewModel.signOutSubject)",
            isPresented: $isConfirmingSignOut
        ) {
            Button("settings.signOut.confirm", role: .destructive) { settingsViewModel.signOut() }

            Button("common.cancel", role: .cancel) {}
        }
    }

    private func switchAccount(to account: AccountChoice) {
        Task { await settingsViewModel.switchAccount(to: account) }
    }

    private func confirmSignOut() {
        isConfirmingSignOut = true
    }
}

#if DEBUG
#Preview {
    let app = PreviewObjectPool.appViewModel(signedIn: true)
    SettingsView(settingsViewModel: app.settingsViewModel, onAddAccount: {})
        .environment(app)
}
#endif
