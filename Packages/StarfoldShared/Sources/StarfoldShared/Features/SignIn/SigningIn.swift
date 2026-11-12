//
//  SigningIn.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

protocol SigningIn {
    func beginSignIn() async throws -> DeviceCodePrompt
    func completeSignIn(
        _ prompt: DeviceCodePrompt,
        onAuthorized: @escaping @MainActor () -> Void
    ) async throws
}
