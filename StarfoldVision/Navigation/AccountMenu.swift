//
//  AccountMenu.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/09/29.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct AccountMenu: View {
    @Environment(AppViewModel.self) private var app
    @Environment(\.dimensions) private var dimensions
    @State private var isConfirmingSignOut = false

    let onAddAccount: () -> Void

    var body: some View {
        Menu {
            accountSwitcher

            Button("home.account.addAccount", systemImage: "person.badge.plus") {
                onAddAccount()
            }

            Button(
                "home.account.signOut",
                systemImage: "rectangle.portrait.and.arrow.right",
                role: .destructive
            ) {
                isConfirmingSignOut = true
            }
        } label: {
            profile
        }
        .accessibilityLabel(Text("home.account.title"))
        .confirmationDialog(
            Text("home.account.signOutConfirmation.title \(gamertag)"),
            isPresented: $isConfirmingSignOut,
            titleVisibility: .visible
        ) {
            Button("home.account.signOutConfirmation.signOut", role: .destructive) {
                app.signOut()
            }
        }
    }
}

private extension AccountMenu {
    var gamertag: String {
        app.signedInGamertag ?? ""
    }

    @ViewBuilder
    var accountSwitcher: some View {
        if app.accounts.count > 1 {
            Section("home.account.switchAccount") {
                ForEach(app.accounts) { accountButton($0) }
            }
        }
    }

    func accountButton(_ account: AccountSummary) -> some View {
        Button {
            Task { await app.switchAccount(to: account.id) }
        } label: {
            accountLabel(account)
        }
    }

    @ViewBuilder
    func accountLabel(_ account: AccountSummary) -> some View {
        switch account.id == app.activeAccountID {
        case true: Label(account.gamertag, systemImage: "checkmark")
        case false: Text(account.gamertag)
        }
    }

    var profile: some View {
        HStack(spacing: dimensions.spaceSmall) {
            picture

            VStack(alignment: .leading, spacing: 0) {
                Text(gamertag)
                    .font(.headline)
                    .lineLimit(1)

                gamerscore
            }
        }
    }

    var picture: some View {
        AsyncImage(url: app.profile?.pictureURL) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .foregroundStyle(.secondary)
        }
        .frame(width: dimensions.accountPictureSize, height: dimensions.accountPictureSize)
        .clipShape(.circle)
    }

    @ViewBuilder
    var gamerscore: some View {
        switch app.profile?.gamerscore {
        case let score?:
            Text("home.account.gamerscore \(score.formatted())")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        case nil:
            EmptyView()
        }
    }
}

#if DEBUG
#Preview("Account menu") {
    NavigationStack {
        Color.clear
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AccountMenu {}
                }
            }
    }
    .environment(PreviewObjectPool.appViewModel(signedIn: true))
}
#endif
