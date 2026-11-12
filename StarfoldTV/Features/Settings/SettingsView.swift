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

    let settings: SettingsViewModel

    let onAddAccount: () -> Void

    var body: some View {
        Form {
            QualitySettingsSection(settings: settings)

            CloudGamingSettingsSection(settings: settings)

            PictureSettingsSection(settings: settings)

            ControllerSettingsSection(settings: settings)

            AccountSettingsSection(
                accounts: settings.accountChoices,
                onSwitch: { switchAccount(to: $0) },
                onAdd: onAddAccount,
                onSignOut: { confirmSignOut() }
            )

            AppearanceSettingsSection(settings: settings)
        }
        .confirmationDialog(
            "settings.signOut.confirmation \(settings.signOutSubject)",
            isPresented: $isConfirmingSignOut
        ) {
            Button("settings.signOut.confirm", role: .destructive) { settings.signOut() }

            Button("common.cancel", role: .cancel) {}
        }
    }
}

private extension SettingsView {
    func switchAccount(to account: AccountChoice) {
        Task { await settings.switchAccount(to: account) }
    }

    func confirmSignOut() {
        isConfirmingSignOut = true
    }
}

#if DEBUG
#Preview {
    let app = PreviewObjectPool.appViewModel(signedIn: true)
    SettingsView(settings: app.settings, onAddAccount: {})
        .environment(app)
}
#endif
