//
//  JSONPatchOperationTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import Testing

@testable import XboxKit

struct JSONPatchOperationTests {
    @Test
    func initThenReadsEveryOperation() throws {
        // Given
        let json = """
            [{"op":"add","path":"/a","value":1},{"op":"remove","path":"/a"},
             {"op":"replace","path":"/a","value":null},{"op":"move","from":"/a","path":"/b"},
             {"op":"copy","from":"/b","path":"/c"},{"op":"test","path":"/c","value":"x"}]
            """

        // When
        let operations = try JSONDecoder().decode([JSONPatchOperation].self, from: Data(json.utf8))

        // Then
        let a = try JSONPointer("/a")
        let b = try JSONPointer("/b")
        let c = try JSONPointer("/c")
        #expect(
            operations == [
                .add(path: a, value: .number(1)),
                .remove(path: a),
                .replace(path: a, value: .null),
                .move(from: a, path: b),
                .copy(from: b, path: c),
                .test(path: c, value: .string("x")),
            ]
        )
    }

    @Test(
        arguments: [
            #"{"op":"merge","path":"/a"}"#,
            #"{"op":"add","path":"/a"}"#,
            #"{"op":"move","path":"/a"}"#,
            #"{"op":"remove","path":"a"}"#,
        ]
    )
    func initWhenOperationIsIncompleteThenThrows(json: String) {
        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(JSONPatchOperation.self, from: Data(json.utf8))
        }
    }
}
