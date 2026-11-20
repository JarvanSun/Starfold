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
            (.dummyConsole, CGSize(width: 1920, height: 1080), .quadHD, true),
            (.dummyConsole, CGSize(width: 2560, height: 1440), .quadHD, false),
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
            (.dummyConsole, .fixed(.quadHD), false, .quadHD),
            (.dummyCloudGame, .fixed(.quadHD), true, .highest),
            (.dummyCloudGame, .fixed(.quadHD), false, .high),
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

    @Test(
        arguments: [
            (StreamTarget.dummyConsole, QualityChoice.automatic, QualityChoice.automatic, false),
            (.dummyConsole, .automatic, .fixed(.high), true),
            (.dummyConsole, .automatic, .fixed(.standard), true),
            (.dummyConsole, .fixed(.quadHD), .automatic, true),
            (.dummyCloudGame, .fixed(.highest), .automatic, false),
            (.dummyCloudGame, .automatic, .fixed(.standard), false),
        ]
    )
    func isResolutionFixedWhenConsoleThenOnlyAutomaticWithoutCeilingLetsTheHostChoose(
        target: StreamTarget,
        choice: QualityChoice,
        ceiling: QualityChoice,
        isFixed: Bool
    ) {
        // Given
        let adaptiveQuality = AdaptiveQuality(target: target)

        // When / Then
        #expect(adaptiveQuality.isResolutionFixed(for: choice, ceiling: ceiling) == isFixed)
    }
}
