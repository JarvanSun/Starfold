//
//  StreamingToken.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct StreamingToken: Codable, Sendable, Equatable {
    var offering: StreamingOffering
    var token: String
    var expiresAt: Date
    var market: String?
    var regions: [StreamingRegion]

    var defaultRegion: StreamingRegion? {
        regions.first(where: \.isDefault) ?? regions.first
    }

    func isValid(at date: Date) -> Bool {
        let refreshMargin: TimeInterval = 60

        return expiresAt.timeIntervalSince(date) > refreshMargin
    }
}
