//
//  LiveAccountService.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StreamKit
import XboxKit

final class LiveAccountService: AccountService {
    private let store: AccountStore
    private let http: HTTPClient
    private let streamRuntime: StreamRuntime

    private var xboxAccounts: [String: XboxAccount] = [:]

    init(store: AccountStore, http: HTTPClient, streamRuntime: StreamRuntime) {
        self.store = store
        self.http = http
        self.streamRuntime = streamRuntime
    }

    func restoreAccounts() async -> [SignedInAccount] {
        var accounts: [SignedInAccount] = []

        for xboxAccount in store.restoreAccounts() {
            accounts.append(await signedIn(xboxAccount))
        }

        return accounts
    }

    func beginSignIn() async throws -> DeviceCodePrompt {
        try await store.beginSignIn()
    }

    func completeSignIn(
        _ prompt: DeviceCodePrompt,
        onAuthorized: @escaping @MainActor () -> Void
    ) async throws -> SignedInAccount {
        let xboxAccount = try await store.completeSignIn(prompt) { await onAuthorized() }
        return await signedIn(xboxAccount)
    }

    private func signedIn(_ xboxAccount: XboxAccount) async -> SignedInAccount {
        xboxAccounts[xboxAccount.xuid] = xboxAccount

        return .init(
            summary: .init(id: xboxAccount.xuid, gamertag: await xboxAccount.gamertag),
            consoles: LiveConsoleService(account: xboxAccount, http: http),
            cloudLibrary: LiveCloudLibraryService(account: xboxAccount, http: http),
            streams: LiveStreamService(account: xboxAccount, http: http, runtime: streamRuntime)
        )
    }

    func profile(of account: SignedInAccount) async throws -> XboxProfile {
        guard let xboxAccount = xboxAccounts[account.id] else {
            throw XboxAccountError.signInRequired
        }

        return try await XboxLiveClient(account: xboxAccount, http: http).profile()
    }

    func signOut(_ account: SignedInAccount) throws {
        xboxAccounts[account.id] = nil

        try store.signOut(xuid: account.id)
    }
}
