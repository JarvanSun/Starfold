//
//  ConsoleActivity.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public struct ConsoleActivity: Codable, Sendable, Hashable {
    public enum Kind: String, Codable, Sendable {
        case playingNow
        case lastPlayedHere
    }

    public var name: String
    public var imageURL: URL?
    public var kind: Kind

    var titleID: String

    public init(titleID: String, name: String, imageURL: URL?, kind: Kind) {
        self.titleID = titleID
        self.name = name
        self.imageURL = imageURL
        self.kind = kind
    }
}
