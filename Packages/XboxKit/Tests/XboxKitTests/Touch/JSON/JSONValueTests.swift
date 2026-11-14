//
//  JSONValueTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import Testing

@testable import XboxKit

struct JSONValueTests {
    @Test
    func initThenKeepsEveryKindOfValue() throws {
        // Given
        let json =
            #"{"flag":true,"count":1,"ratio":0.5,"name":"A","list":[null,false],"nested":{}}"#

        // When
        let value = try JSONDecoder().decode(JSONValue.self, from: Data(json.utf8))

        // Then
        let expected = JSONValue.object([
            "flag": .bool(true),
            "count": .number(1),
            "ratio": .number(0.5),
            "name": .string("A"),
            "list": .array([.null, .bool(false)]),
            "nested": .object([:]),
        ])
        #expect(value == expected)
    }

    @Test
    func encodeThenRoundTripsThroughJSON() throws {
        // Given
        let value = JSONValue.object(["a": .array([.number(2), .string("b"), .null, .bool(true)])])

        // When
        let decoded = try JSONDecoder().decode(JSONValue.self, from: JSONEncoder().encode(value))

        // Then
        #expect(decoded == value)
    }
}
