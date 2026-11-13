//
//  TouchContextTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchContextTests {
    @Test
    func applyingThenPatchesOnlyTheState() throws {
        // Given
        let definitions = JSONValue.object(["icon": .string("walk")])
        let context = TouchContext(members: [
            "definitions": definitions,
            "state": .object(["hasSpell": .bool(false)]),
        ])
        let patch = JSONPatch(operations: [
            .replace(path: try JSONPointer("/hasSpell"), value: .bool(true))
        ])

        // When
        let patched = try context.applying(patch)

        // Then
        #expect(patched.state == .object(["hasSpell": .bool(true)]))
        #expect(patched.document["definitions"] == definitions)
        #expect(context.state == .object(["hasSpell": .bool(false)]))
    }

    @Test
    func applyingWhenThereIsNoStateThenAddsToAnEmptyOne() throws {
        // Given
        let level = try JSONPointer("/level")
        let patch = JSONPatch(operations: [.add(path: level, value: .number(2))])

        // When
        let patched = try TouchContext().applying(patch)

        // Then
        #expect(patched.state == .object(["level": .number(2)]))
    }

    @Test
    func applyingWhenThePatchFailsThenThrows() {
        // Given
        let patch = JSONPatch(operations: [.remove(path: .init(tokens: ["missing"]))])

        // When / Then
        #expect(throws: JSONPatchError.pathNotFound("/missing")) {
            try TouchContext().applying(patch)
        }
    }
}
