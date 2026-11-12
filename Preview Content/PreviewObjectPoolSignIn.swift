//
//  PreviewObjectPoolSignIn.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

#if DEBUG
import StarfoldShared

extension PreviewObjectPool {
    static var signInCode: SignInCode {
        .init(prompt: deviceCodePrompt)
    }

    static var signInSteps: [SignInStep] {
        [
            .preparing,
            .code(signInCode),
            .progress(.signingIn),
            .progress(.signedIn),
            .failure("The sign-in code expired."),
        ]
    }
}
#endif
