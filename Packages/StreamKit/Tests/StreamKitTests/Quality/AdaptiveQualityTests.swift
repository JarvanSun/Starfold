//
//  AdaptiveQualityTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/09/28.
//

import CoreGraphics
import Testing
import XboxKit

@testable import StreamKit

struct AdaptiveQualityTests {
    @Test(
        arguments: [
            (StreamTarget.dummyConsole, CGSize(width: 1280, height: 720), StreamQuality.high, true),
            (.dummyConsole, CGSize(width: 1920, height: 1080), .high, false),
            (.dummyConsole, CGSize(width: 1280, height: 720), .standard, false),
            (.dummyConsole, CGSize(width: 1920, height: 1080), .highest, false),
            (.dummyCloudGame, CGSize(width: 1920, height: 1080), .highest, true),
        ]
    )
    func isLoweredByHostThenComparesWithTheTiersFullHeight(
        target: StreamTarget,
        received: CGSize,
        requested: StreamQuality,
        isLowered: Bool
    ) {
        // Given
        let quality = AdaptiveQuality(target: target)

        // When / Then
        #expect(quality.isLoweredByHost(received: received, requested: requested) == isLowered)
    }

    @Test(
        arguments: [
            (StreamTarget.dummyCloudGame, QualityChoice.fixed(.highest), false, StreamQuality.high),
            (.dummyCloudGame, .fixed(.highest), true, .highest),
            (.dummyConsole, .fixed(.highest), false, .highest),
            (.dummyCloudGame, .automatic, false, .high),
        ]
    )
    func requestedQualityWhenCloudWithoutGamePassThenNeverAsksForFourteenForty(
        target: StreamTarget,
        choice: QualityChoice,
        hasGamePass: Bool,
        expected: StreamQuality
    ) {
        // Given
        let quality = AdaptiveQuality(target: target)

        // When / Then
        #expect(quality.requestedQuality(for: choice, hasGamePass: hasGamePass) == expected)
    }
}
