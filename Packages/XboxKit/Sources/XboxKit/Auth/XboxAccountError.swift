//
//  XboxAccountError.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum XboxAccountError: Error, Sendable, Equatable {
    case signInRequired
    case cloudGamingUnavailable
}
