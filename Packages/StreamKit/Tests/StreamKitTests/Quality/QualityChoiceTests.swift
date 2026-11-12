//
//  QualityChoiceTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing
import XboxKit

@testable import StreamKit

struct QualityChoiceTests {
    @Test(
        arguments: [
            (QualityChoice.automatic, StreamQuality.high),
            (QualityChoice.fixed(.standard), StreamQuality.standard),
            (QualityChoice.fixed(.highest), StreamQuality.highest),
        ]
    )
    func requestedQualityThenAsksAutomaticForTenEightyAndKeepsAFixedChoice(
        choice: QualityChoice,
        expected: StreamQuality
    ) {
        #expect(choice.requestedQuality == expected)
    }

    @Test(arguments: [QualityChoice.automatic, .fixed(.standard), .fixed(.high), .fixed(.highest)])
    func storageValueThenRoundTrips(choice: QualityChoice) {
        #expect(QualityChoice(storageValue: choice.storageValue) == choice)
    }

    @Test

    func initWhenStoredValueUnknownThenIsAutomatic() {
        #expect(QualityChoice(storageValue: "unknown") == .automatic)
    }
}
