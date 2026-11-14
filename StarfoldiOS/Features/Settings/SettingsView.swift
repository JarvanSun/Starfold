//
//  SettingsView.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct SettingsView: View {
    @Environment(\.dimensions) private var dimensions
    @State private var isConfirmingSignOut = false
    @State private var isEditingTouchLayout = false

    let settingsViewModel: SettingsViewModel

    let onAddAccount: () -> Void

    var body: some View {
        GeometryReader { proxy in
            form
                .contentMargins(
                    .trailing,
                    trailingMargin(in: proxy.size.width),
                    for: .scrollContent
                )
        }
        .navigationTitle(Text("settings.title"))
        .confirmationDialog(
            "settings.signOut.confirmation \(settingsViewModel.signOutSubject)",
            isPresented: $isConfirmingSignOut,
            titleVisibility: .visible
        ) {
            Button("settings.signOut.confirm", role: .destructive) { settingsViewModel.signOut() }
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

    private func trailingMargin(in width: CGFloat) -> CGFloat {
        max(0, width - dimensions.settingsMaxWidth)
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

    private func editTouchLayout() {
        settingsViewModel.editTouchLayout()
        isEditingTouchLayout = true
    }
}

#if DEBUG
#Preview {
    let appViewModel = PreviewObjectPool.appViewModel(signedIn: true)
    NavigationStack {
        SettingsView(settingsViewModel: appViewModel.settings, onAddAccount: {})
    }
    .environment(appViewModel)
}
#endif
