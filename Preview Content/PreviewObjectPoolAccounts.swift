//
//  PreviewObjectPoolAccounts.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import Foundation
import StarfoldShared
import XboxKit

extension PreviewObjectPool {
    static var profile: XboxProfile {
        .init(xuid: "2535000000000000", gamertag: "NovaPilot", gamerscore: 12480, pictureURL: nil)
    }

    static var deviceCodePrompt: DeviceCodePrompt {
        .init(
            userCode: "PWMLFVSX",
            verificationURL: URL(string: "https://www.microsoft.com/link")!,
            verificationURLComplete: URL(string: "https://www.microsoft.com/link?otc=PWMLFVSX")!,
            expiresAt: .now + 897,
            deviceCode: "preview",
            pollInterval: .seconds(5)
        )
    }

    static var signInPhases: [SignInPhase] {
        let failedSignInPhase: SignInPhase = .failed("The sign-in code expired.")

        return [.requesting, .waiting(deviceCodePrompt), .finishing, .done, failedSignInPhase]
    }

    static func signInViewModel(phase: SignInPhase) -> SignInViewModel {
        appViewModel(
            accountService: PreviewAccountService(
                accounts: [],
                profile: profile,
                signInPhase: phase
            )
        )
        .makeSignInViewModel()
    }
}
#endif
