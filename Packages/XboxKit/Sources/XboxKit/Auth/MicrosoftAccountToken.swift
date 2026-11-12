//
//  MicrosoftAccountToken.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct MicrosoftAccountToken: Codable, Sendable, Equatable {
    var accessToken: String
    var refreshToken: String?
    var expiresAt: Date
    var userID: String?

    func isValid(at date: Date) -> Bool {
        expiresAt.timeIntervalSince(date) > refreshMargin
    }
}

private extension MicrosoftAccountToken {
    var refreshMargin: TimeInterval {
        60
    }
}
