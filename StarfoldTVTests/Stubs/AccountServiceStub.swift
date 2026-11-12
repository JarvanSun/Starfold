//
//  AccountServiceStub.swift
//  StarfoldTVTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import XboxKit

struct AccountServiceStub: AccountService {
    func restoreAccounts() async -> [SignedInAccount] {
        []
    }

    func beginSignIn() async throws -> DeviceCodePrompt {
        throw CancellationError()
    }

    func completeSignIn(
        _ prompt: DeviceCodePrompt,
        onAuthorized: @escaping @MainActor () -> Void
    ) async throws -> SignedInAccount {
        throw CancellationError()
    }

    func profile(of account: SignedInAccount) async throws -> XboxProfile {
        throw CancellationError()
    }

    func signOut(_ account: SignedInAccount) throws {}
}
