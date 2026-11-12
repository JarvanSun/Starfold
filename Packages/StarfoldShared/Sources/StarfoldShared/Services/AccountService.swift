//
//  AccountService.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

public protocol AccountService {
    func restoreAccounts() async -> [SignedInAccount]
    func beginSignIn() async throws -> DeviceCodePrompt
    func completeSignIn(
        _ prompt: DeviceCodePrompt,
        onAuthorized: @escaping @MainActor () -> Void
    ) async throws -> SignedInAccount
    func profile(of account: SignedInAccount) async throws -> XboxProfile
    func signOut(_ account: SignedInAccount) throws
}
