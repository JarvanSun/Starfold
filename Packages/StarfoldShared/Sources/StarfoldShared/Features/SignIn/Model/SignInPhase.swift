//
//  SignInPhase.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import XboxKit

public enum SignInPhase: Equatable {
    case requesting
    case waiting(DeviceCodePrompt)
    case finishing
    case done
    case failed(String)

    var step: SignInStep {
        switch self {
        case .requesting: .preparing
        case .waiting(let prompt): .code(.init(prompt: prompt))
        case .finishing: .progress(.signingIn)
        case .done: .progress(.signedIn)
        case .failed(let message): .failure(message)
        }
    }
}
