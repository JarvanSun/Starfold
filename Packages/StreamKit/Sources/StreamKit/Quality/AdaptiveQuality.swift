//
//  AdaptiveQuality.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import CoreGraphics
import XboxKit

public struct AdaptiveQuality: Sendable {
    private let target: StreamTarget

    public init(target: StreamTarget) {
        self.target = target
    }

    public func requestedQuality(for choice: QualityChoice, hasGamePass: Bool) -> StreamQuality {
        let requested = choice.requestedQuality

        return switch (target, requested, hasGamePass) {
        case (.cloud, .highest, false): .high
        default: requested
        }
    }

    public func isLoweredByHost(received: CGSize, requested: StreamQuality) -> Bool {
        Int(received.height) < fullHeight(of: requested)
    }

    private func fullHeight(of quality: StreamQuality) -> Int {
        switch (quality, target) {
        case (.standard, _): 720
        case (.high, _), (.highest, .console): 1080
        case (.highest, .cloud): 1440
        }
    }
}
