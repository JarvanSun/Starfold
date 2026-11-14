//
//  AccountMenu.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import SwiftUI
import XboxKit

struct AccountMenu: View {
    @Environment(AppViewModel.self) private var appViewModel
    @Environment(\.dimensions) private var dimensions
    @State private var isConfirmingSignOut = false

    let onAddAccount: () -> Void

    private var gamertag: String {
        appViewModel.signedInGamertag ?? ""
    }

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
                appViewModel.signOut()
            }
        }
    }

    @ViewBuilder
    private var accountSwitcher: some View {
        if appViewModel.accounts.count > 1 {
            Section("home.account.switchAccount") {
                ForEach(appViewModel.accounts) { accountButton($0) }
            }
        }
    }

    private func accountButton(_ account: AccountSummary) -> some View {
        Button {
            Task { await appViewModel.switchAccount(to: account.id) }
        } label: {
            accountLabel(account)
        }
    }

    @ViewBuilder
    private func accountLabel(_ account: AccountSummary) -> some View {
        if account.id == appViewModel.activeAccountID {
            Label(account.gamertag, systemImage: "checkmark")
        } else {
            Text(account.gamertag)
        }
    }

    private var profile: some View {
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

    private var picture: some View {
        AsyncImage(url: appViewModel.profile?.pictureURL) { image in
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
    private var gamerscore: some View {
        if let score = appViewModel.profile?.gamerscore {
            Text("home.account.gamerscore \(score.formatted())")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
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
