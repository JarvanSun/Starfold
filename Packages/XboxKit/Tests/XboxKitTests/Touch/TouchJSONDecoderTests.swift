//
//  TouchJSONDecoderTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import Testing

@testable import XboxKit

struct TouchJSONDecoderTests {
    @Test
    func decodeWhenTheFileStartsWithAByteOrderMarkThenSkipsIt() throws {
        // Given
        let json = Data([0xEF, 0xBB, 0xBF]) + Data(#"{"version":"1.0"}"#.utf8)

        // When
        let value = try TouchJSONDecoder().decode(JSONValue.self, from: json)

        // Then
        #expect(value == .object(["version": .string("1.0")]))
    }
}
