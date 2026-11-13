//
//  XboxToken.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct XboxToken: Codable, Sendable, Equatable {
    var token: String
    var notAfter: Date
    var userHash: String
    var gamertag: String?
    var xuid: String?

    var authorizationHeader: String {
        "XBL3.0 x=\(userHash);\(token)"
    }

    func isValid(at date: Date) -> Bool {
        let refreshMargin: TimeInterval = 60

        return notAfter.timeIntervalSince(date) > refreshMargin
    }
}
