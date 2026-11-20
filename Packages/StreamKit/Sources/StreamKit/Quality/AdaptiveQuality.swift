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
        case (.cloud, .highest, false), (.cloud, .quadHD, false): .high
        case (.cloud, .quadHD, true): .highest
        default: requested
        }
    }

    public func isResolutionFixed(for choice: QualityChoice, streaming quality: StreamQuality)
        -> Bool
    {
        switch target {
        case .console: choice != .automatic || quality != choice.requestedQuality
        case .cloud: false
        }
    }

    public func isLoweredByHost(received: CGSize, requested: StreamQuality) -> Bool {
        Int(received.height) < fullHeight(of: requested)
    }

    private func fullHeight(of quality: StreamQuality) -> Int {
        switch (quality, target) {
        case (.standard, _): 720
        case (.high, _), (.highest, .console): 1080
        case (.highest, .cloud), (.quadHD, _): 1440
        }
    }
}
