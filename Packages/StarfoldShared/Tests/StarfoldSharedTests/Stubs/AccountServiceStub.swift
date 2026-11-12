//
//  AccountServiceStub.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

@testable import StarfoldShared

final class AccountServiceStub: AccountService {
    var savedAccounts: [SignedInAccount] = []
    var profile: Result<XboxProfile, Error> = .success(.dummy)
    var prompts: [Result<DeviceCodePrompt, Error>] = []
    var completions: [Result<SignedInAccount, Error>] = []
    private(set) var signInRequests = 0
    private(set) var signedOutIDs: [String] = []

    func restoreAccounts() async -> [SignedInAccount] {
        savedAccounts
    }

    func beginSignIn() async throws -> DeviceCodePrompt {
        signInRequests += 1

        guard !prompts.isEmpty else { return try await hang() }

        return try prompts.removeFirst().get()
    }

    func completeSignIn(
        _ prompt: DeviceCodePrompt,
        onAuthorized: @escaping @MainActor () -> Void
    ) async throws -> SignedInAccount {
        guard !completions.isEmpty else { return try await hang() }

        let account = try completions.removeFirst().get()
        onAuthorized()
        savedAccounts.append(account)
        return account
    }

    func profile(of account: SignedInAccount) async throws -> XboxProfile {
        try profile.get()
    }

    func signOut(_ account: SignedInAccount) throws {
        signedOutIDs.append(account.id)
        savedAccounts.removeAll { $0.id == account.id }
    }
}

private extension AccountServiceStub {
    func hang<Value>() async throws -> Value {
        try await Task.sleep(for: .seconds(3600))

        throw CancellationError()
    }
}
