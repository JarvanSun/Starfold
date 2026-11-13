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

    let settings: SettingsViewModel

    let onAddAccount: () -> Void

    var body: some View {
        Form {
            QualitySettingsSection(settings: settings)

            CloudGamingSettingsSection(settings: settings)

            PictureSettingsSection(settings: settings)

            if settings.hasTouchControls {
                TouchControlsSettingsSection(settings: settings) { isEditingTouchLayout = true }
            }

            ControllerSettingsSection(settings: settings)

            if settings.hasAccounts {
                accountSection
            }

            AppearanceSettingsSection(settings: settings)
        }
        .navigationTitle(Text("settings.title"))
        .confirmationDialog(
            "settings.signOut.confirmation \(settings.signOutSubject)",
            isPresented: $isConfirmingSignOut,
            titleVisibility: .visible
        ) {
            Button("settings.signOut.confirm", role: .destructive) { settings.signOut() }
        }
        .fullScreenCover(isPresented: $isEditingTouchLayout) {
            TouchLayoutEditorHost()
        }
    }

    private var accountSection: some View {
        AccountSettingsSection(
            accounts: settings.accountChoices,
            onSwitch: { switchAccount(to: $0) },
            onAdd: onAddAccount,
            onSignOut: { isConfirmingSignOut = true }
        )
    }

    private func switchAccount(to account: AccountChoice) {
        Task { await settings.switchAccount(to: account) }
    }
}

#if DEBUG
#Preview {
    let app = PreviewObjectPool.appViewModel(signedIn: true)
    NavigationStack {
        SettingsView(settings: app.settings, onAddAccount: {})
    }
    .environment(app)
}
#endif
