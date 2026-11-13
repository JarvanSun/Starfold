//
//  PreviewAccountService.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import StarfoldShared
import StreamKit
import XboxKit

struct PreviewAccountService: AccountService {
    let accounts: [SignedInAccount]
    let profile: XboxProfile
    let signInPhase: SignInPhase

    private var unanswered: PreviewReply {
        .init(state: .loading)
    }

    func restoreAccounts() async -> [SignedInAccount] {
        accounts
    }

    func beginSignIn() async throws -> DeviceCodePrompt {
        switch signInPhase {
        case .requesting: try await unanswered.neverAnswer()
        case .waiting(let prompt): prompt
        case .finishing, .done: PreviewObjectPool.deviceCodePrompt
        case .failed(let message): throw PreviewError(message: message)
        }
    }

    func completeSignIn(
        _ prompt: DeviceCodePrompt,
        onAuthorized: @escaping @MainActor () -> Void
    ) async throws -> SignedInAccount {
        switch signInPhase {
        case .finishing: onAuthorized()
        case .done: return PreviewObjectPool.account(streamPhase: .streaming)
        case .requesting, .waiting, .failed: break
        }

        return try await unanswered.neverAnswer()
    }

    func profile(of account: SignedInAccount) async throws -> XboxProfile {
        profile
    }

    func signOut(_ account: SignedInAccount) throws {}
}
#endif
