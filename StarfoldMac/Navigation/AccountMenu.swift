//
//  AccountMenu.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/28.
//

import StarfoldShared
import SwiftUI

struct AccountMenu: View {
    @Environment(AppViewModel.self) private var app
    @State private var isConfirmingSignOut = false

    let onShowSignIn: () -> Void

    private var gamertag: String {
        app.signedInGamertag ?? ""
    }

    var body: some View {
        Menu {
            if app.accounts.count > 1 {
                switchAccountSection
            }

            addAccountButton

            Divider()

            signOutButton
        } label: {
            ProfileBadge(gamertag: gamertag, profile: app.profile)
        }
        .menuIndicator(.hidden)
        .help(Text("account.menu.tooltip"))
        .confirmationDialog(
            String(localized: "account.signOut.confirmation.title \(gamertag)"),
            isPresented: $isConfirmingSignOut
        ) {
            Button(String(localized: "account.signOut.confirmation.signOut"), role: .destructive) {
                app.signOut()
            }
        }
    }

    private var switchAccountSection: some View {
        Section(String(localized: "account.menu.switchAccount")) {
            ForEach(app.accounts) { account in
                Button {
                    switchAccount(to: account)
                } label: {
                    accountLabel(account)
                }
            }
        }
    }

    private func switchAccount(to account: AccountSummary) {
        Task { await app.switchAccount(to: account.id) }
    }

    @ViewBuilder
    private func accountLabel(_ account: AccountSummary) -> some View {
        switch account.id == app.activeAccountID {
        case true: Label(account.gamertag, systemImage: "checkmark")
        case false: Text(account.gamertag)
        }
    }

    private var addAccountButton: some View {
        Button(
            String(localized: "account.menu.addAccount"),
            systemImage: "person.crop.circle.badge.plus"
        ) {
            onShowSignIn()
        }
    }

    private var signOutButton: some View {
        Button(
            String(localized: "account.menu.signOut"),
            systemImage: "rectangle.portrait.and.arrow.right",
            role: .destructive
        ) {
            isConfirmingSignOut = true
        }
    }
}
