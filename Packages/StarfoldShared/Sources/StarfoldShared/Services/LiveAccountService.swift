//
//  LiveAccountService.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit
import XboxKit

final class LiveAccountService: AccountService {
    private let accountStore: AccountStore
    private let httpClient: HTTPClient
    private let streamRuntime: StreamRuntime

    private var xboxAccounts: [String: XboxAccount] = [:]

    init(accountStore: AccountStore, httpClient: HTTPClient, streamRuntime: StreamRuntime) {
        self.accountStore = accountStore
        self.httpClient = httpClient
        self.streamRuntime = streamRuntime
    }

    func restoreAccounts() async -> [SignedInAccount] {
        var accounts: [SignedInAccount] = []

        for xboxAccount in accountStore.restoreAccounts() {
            xboxAccounts[xboxAccount.xuid] = xboxAccount
            accounts.append(await makeSignedInAccount(for: xboxAccount))
        }

        return accounts
    }

    private func makeSignedInAccount(for xboxAccount: XboxAccount) async -> SignedInAccount {
        .init(
            summary: .init(id: xboxAccount.xuid, gamertag: await xboxAccount.gamertag),
            consoleService: LiveConsoleService(xboxAccount: xboxAccount, httpClient: httpClient),
            cloudLibraryService: LiveCloudLibraryService(
                xboxAccount: xboxAccount,
                httpClient: httpClient
            ),
            streamService: LiveStreamService(
                xboxAccount: xboxAccount,
                httpClient: httpClient,
                streamRuntime: streamRuntime
            )
        )
    }

    func beginSignIn() async throws -> DeviceCodePrompt {
        try await accountStore.beginSignIn()
    }

    func completeSignIn(
        _ prompt: DeviceCodePrompt,
        onAuthorized: @escaping @MainActor () -> Void
    ) async throws -> SignedInAccount {
        let xboxAccount = try await accountStore.completeSignIn(prompt) { await onAuthorized() }
        xboxAccounts[xboxAccount.xuid] = xboxAccount

        return await makeSignedInAccount(for: xboxAccount)
    }

    func profile(of account: SignedInAccount) async throws -> XboxProfile {
        guard let xboxAccount = xboxAccounts[account.id] else {
            throw XboxAccountError.signInRequired
        }

        return try await XboxLiveClient(account: xboxAccount, httpClient: httpClient).profile()
    }

    func signOut(_ account: SignedInAccount) throws {
        xboxAccounts[account.id] = nil

        try accountStore.signOut(xuid: account.id)
    }
}
