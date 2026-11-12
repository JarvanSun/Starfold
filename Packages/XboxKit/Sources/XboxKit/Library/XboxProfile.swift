//
//  XboxProfile.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public struct XboxProfile: Codable, Sendable, Hashable {
    public var xuid: String
    public var gamertag: String
    public var gamerscore: Int?
    public var pictureURL: URL?

    public init(xuid: String, gamertag: String, gamerscore: Int?, pictureURL: URL?) {
        self.xuid = xuid
        self.gamertag = gamertag
        self.gamerscore = gamerscore
        self.pictureURL = pictureURL
    }
}
