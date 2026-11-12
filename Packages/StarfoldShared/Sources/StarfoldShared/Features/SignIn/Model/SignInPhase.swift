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
}
