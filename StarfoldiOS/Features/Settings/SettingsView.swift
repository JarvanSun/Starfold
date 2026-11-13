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

    let settings: SettingsViewModel

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
            "settings.signOut.confirmation \(settings.signOutSubject)",
            isPresented: $isConfirmingSignOut,
            titleVisibility: .visible
        ) {
            Button("settings.signOut.confirm", role: .destructive) { settings.signOut() }
        }
        .fullScreenCover(isPresented: $isEditingTouchLayout) {
            settings.finishEditingTouchLayout()
        } content: {
            touchLayoutEditor
        }
    }

    private var form: some View {
        Form {
            StreamingSettingsSection(settings: settings)

            DisplaySettingsSection(settings: settings)

            ControlsSettingsSection(settings: settings) { editTouchLayout() }

            if settings.hasAccounts {
                accountSection
            }
        }
    }

    private func trailingMargin(in width: CGFloat) -> CGFloat {
        max(0, width - dimensions.settingsMaxWidth)
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

    private func editTouchLayout() {
        settings.editTouchLayout()

        isEditingTouchLayout = true
    }

    @ViewBuilder
    private var touchLayoutEditor: some View {
        if let editor = settings.touchLayoutEditor {
            TouchLayoutEditorView(editor: editor)
        }
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
