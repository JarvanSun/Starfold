//
//  JSONPointerTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct JSONPointerTests {
    @Test
    func initWhenTokensAreEscapedThenUnescapesTildeAndSlash() throws {
        // Given / When
        let pointer = try JSONPointer("/a~1b/m~0n/")

        // Then
        #expect(pointer.tokens == ["a/b", "m~n", ""])
        #expect(pointer.description == "/a~1b/m~0n/")
    }

    @Test(arguments: ["a", "/a~2", "/a~"])
    func initWhenTextIsMalformedThenThrows(text: String) {
        #expect(throws: JSONPatchError.invalidPointer(text)) { try JSONPointer(text) }
    }

    @Test
    func valueThenWalksObjectsAndArrays() throws {
        // Given
        let document = JSONValue.object(["list": .array([.string("zero"), .string("one")])])

        // When
        let found = try JSONPointer("/list/1").value(in: document)

        // Then
        #expect(found == .string("one"))
    }

    @Test(arguments: ["/list/01", "/list/2", "/list/-", "/missing"])
    func valueWhenTargetIsMissingThenIsNil(path: String) throws {
        // Given
        let document = JSONValue.object(["list": .array([.null, .null])])

        // When / Then
        #expect(try JSONPointer(path).value(in: document) == nil)
    }

    @Test
    func valueWhenPointerIsEmptyThenIsTheWholeDocument() throws {
        // Given
        let document = JSONValue.array([.bool(true)])

        // When / Then
        #expect(try JSONPointer("").value(in: document) == document)
    }
}
