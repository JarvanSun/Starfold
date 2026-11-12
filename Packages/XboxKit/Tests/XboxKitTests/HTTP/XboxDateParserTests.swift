//
//  XboxDateParserTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import XboxKit

struct XboxDateParserTests {
    @Test(
        arguments: [
            ("2024-05-22T03:24:04.3321393Z", 1_716_348_244.332),
            ("2024-05-22T03:24:04.332Z", 1_716_348_244.332),
            ("2024-05-22T03:24:04Z", 1_716_348_244),
        ]
    )
    func dateWhenTimestampHasAnyFractionThenParses(text: String, expected: TimeInterval) throws {
        // Given / When
        let date = try #require(XboxDateParser().date(from: text))

        // Then
        #expect(abs(date.timeIntervalSince1970 - expected) < 0.001)
    }

    @Test
    func dateWhenTextIsNotATimestampThenIsNil() {
        #expect(XboxDateParser().date(from: "yesterday") == nil)
    }
}
