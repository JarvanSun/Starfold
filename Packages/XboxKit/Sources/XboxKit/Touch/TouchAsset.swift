//
//  TouchAsset.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

public struct TouchAsset: Sendable, Hashable {
    public let png: Data
    public let scale: Double

    public init(png: Data, scale: Double) {
        self.png = png
        self.scale = scale
    }
}
