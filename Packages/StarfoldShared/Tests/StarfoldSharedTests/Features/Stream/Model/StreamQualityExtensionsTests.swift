//
//  StreamQualityExtensionsTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StreamKit
import Testing
import XboxKit

@testable import StarfoldShared

struct StreamQualityExtensionsTests {
    @Test(
        arguments: [
            (StreamQuality.highest, QualityChoice.automatic, StreamQuality.highest),
            (.highest, .fixed(.standard), .standard),
            (.high, .fixed(.high), .high),
            (.standard, .fixed(.high), .standard),
        ]
    )
    func cappedThenNeverExceedsTheCeiling(
        quality: StreamQuality,
        ceiling: QualityChoice,
        expected: StreamQuality
    ) {
        #expect(quality.capped(at: ceiling) == expected)
    }
}
