//
//  StoredAccount.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct StoredAccount: Codable, Sendable, Equatable {
    enum CodingKeys: String, CodingKey {
        case xuid
        case gamertag
        case microsoftAccountToken = "msa"
        case webToken
        case gssvToken
        case streamingTokens
        case cloudOffering
    }

    var xuid: String
    var gamertag: String
    var microsoftAccountToken: MicrosoftAccountToken
    var webToken: XboxToken?
    var gssvToken: XboxToken?
    var streamingTokens: [StreamingOffering: StreamingToken] = [:]
    var cloudOffering: StreamingOffering?
}
