//
//  KeychainError.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Security

struct KeychainError: LocalizedError, Sendable, CustomStringConvertible {
    let status: OSStatus

    var description: String {
        let message = SecCopyErrorMessageString(status, nil) as String? ?? "unknown"
        return "Keychain error \(status): \(message)"
    }

    var errorDescription: String? {
        description
    }
}
