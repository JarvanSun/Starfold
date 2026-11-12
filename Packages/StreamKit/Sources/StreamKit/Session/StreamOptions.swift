//
//  StreamOptions.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import XboxKit

public struct StreamOptions: Sendable, Equatable {
    var quality: StreamQuality
    var maxBitrateKbps: Int?
    var gameLocale: String
    var stunServers: [String]
    var clientAppInstallID: UUID

    public init(
        quality: StreamQuality = .high,
        maxBitrateKbps: Int? = nil,
        gameLocale: String = "en-US",
        stunServers: [String] = ["stun:stun.l.google.com:19302", "stun:stun1.l.google.com:19302"],
        clientAppInstallID: UUID
    ) {
        self.quality = quality
        self.maxBitrateKbps = maxBitrateKbps
        self.gameLocale = gameLocale
        self.stunServers = stunServers
        self.clientAppInstallID = clientAppInstallID
    }
}
