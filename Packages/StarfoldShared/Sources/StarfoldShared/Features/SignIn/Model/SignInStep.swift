//
//  SignInStep.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum SignInStep: Equatable {
    case preparing
    case code(SignInCode)
    case progress(SignInProgress)
    case failure(String)

    init(phase: SignInPhase) {
        self =
            switch phase {
            case .requesting: .preparing
            case .waiting(let prompt): .code(.init(prompt: prompt))
            case .finishing: .progress(.signingIn)
            case .done: .progress(.signedIn)
            case .failed(let message): .failure(message)
            }
    }
}
