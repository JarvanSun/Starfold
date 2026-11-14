//
//  TouchCapabilities.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

public struct TouchCapabilities: Sendable, Equatable {
    var maxTouchPoints: UInt8
    var maxLayoutVersion: String
    var maxManifestVersion: String

    public init(maxTouchPoints: UInt8, maxLayoutVersion: String, maxManifestVersion: String) {
        self.maxTouchPoints = maxTouchPoints
        self.maxLayoutVersion = maxLayoutVersion
        self.maxManifestVersion = maxManifestVersion
    }
}
