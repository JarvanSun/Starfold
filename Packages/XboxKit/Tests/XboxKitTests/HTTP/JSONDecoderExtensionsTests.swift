//
//  JSONDecoderExtensionsTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import XboxKit

struct JSONDecoderExtensionsTests {
    private struct Stamp: Decodable {
        let date: Date
    }

    @Test
    func decodeWhenDateHasSevenFractionalDigitsThenParses() throws {
        // Given
        let decoder = JSONDecoder(dateParser: .init())

        // When
        let stamp = try decoder.decode(
            Stamp.self,
            from: Data(#"{"date":"2024-05-22T03:24:04.3321393Z"}"#.utf8)
        )

        // Then
        #expect(abs(stamp.date.timeIntervalSince1970 - 1_716_348_244.332) < 0.001)
    }

    @Test
    func decodeWhenDateIsUnrecognizedThenThrows() {
        // Given
        let decoder = JSONDecoder(dateParser: .init())

        // When / Then
        #expect(throws: DecodingError.self) {
            _ = try decoder.decode(Stamp.self, from: Data(#"{"date":"soon"}"#.utf8))
        }
    }
}
