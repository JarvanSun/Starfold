//
//  AccountSettingsSection.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI

struct AccountSettingsSection: View {
    let accounts: [AccountChoice]

    let onSwitch: (AccountChoice) -> Void
    let onAdd: () -> Void
    let onSignOut: () -> Void

    var body: some View {
        Section("settings.account.header") {
            ForEach(accounts) { accountButton($0) }

            Button("settings.account.add") { onAdd() }

            Button("settings.account.signOut", role: .destructive) { onSignOut() }
        }
    }

    private func accountButton(_ account: AccountChoice) -> some View {
        Button {
            onSwitch(account)
        } label: {
            HStack {
                Text(verbatim: account.gamertag)

                Image(systemName: "checkmark").opacity(account.isActive ? 1 : 0)
            }
        }
    }
}

#if DEBUG
#Preview {
    Form {
        AccountSettingsSection(
            accounts: PreviewObjectPool.accountChoices,
            onSwitch: { _ in },
            onAdd: {},
            onSignOut: {}
        )
    }
}
#endif
