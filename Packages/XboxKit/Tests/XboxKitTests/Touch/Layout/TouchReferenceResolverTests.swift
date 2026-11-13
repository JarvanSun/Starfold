//
//  TouchReferenceResolverTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchReferenceResolverTests {
    @Test
    func resolvedLayoutThenFollowsLayoutAndContextReferencesAndDropsDefinitions() throws {
        // Given
        let layout = try JSONFixtureDecoder().decode(
            JSONValue.self,
            from: ##"""
                {"content":{"scale":{"$ref":"#/definitions/size"},
                 "icon":{"$ref":"../../context.json#/definitions/icon"}},
                 "definitions":{"size":{"$ref":"../../context.json#/state/size"},"unused":{"$ref":"#/nowhere"}}}
                """##
        )
        let context = try JSONFixtureDecoder().decode(
            JSONValue.self,
            from:
                ##"{"definitions":{"icon":{"$ref":"#/state/icon"}},"state":{"size":1.5,"icon":"jump"}}"##
        )

        // When
        let resolved = try TouchReferenceResolver(layout: layout, context: context).resolvedLayout()

        // Then
        #expect(
            resolved
                == .object([
                    "content": .object(["scale": .number(1.5), "icon": .string("jump")])
                ])
        )
    }

    @Test
    func resolvedLayoutWhenThePointerIsEscapedThenFindsTheMember() throws {
        // Given
        let layout = try JSONFixtureDecoder().decode(
            JSONValue.self,
            from: ##"{"content":{"$ref":"#/definitions/a~1b%20c"},"definitions":{"a/b c":true}}"##
        )

        // When
        let resolved = try TouchReferenceResolver(layout: layout, context: .object([:]))
            .resolvedLayout()

        // Then
        #expect(resolved == .object(["content": .bool(true)]))
    }

    @Test
    func resolvedLayoutWhenReferencesFormACycleThenThrows() throws {
        // Given
        let layout = try JSONFixtureDecoder().decode(
            JSONValue.self,
            from: ##"""
                {"content":{"$ref":"#/definitions/a"},
                 "definitions":{"a":{"$ref":"#/definitions/b"},"b":{"$ref":"#/definitions/a"}}}
                """##
        )
        let resolver = TouchReferenceResolver(layout: layout, context: .object([:]))

        // When / Then
        #expect(throws: TouchLayoutError.referenceCycle("#/definitions/a")) {
            try resolver.resolvedLayout()
        }
    }

    @Test(arguments: ["other.json#/state/a", "../../context.json#/state/missing", "#definitions"])
    func resolvedLayoutWhenTheTargetIsUnknownThenThrows(reference: String) throws {
        // Given
        let layout = JSONValue.object(["content": .object(["$ref": .string(reference)])])
        let resolver = TouchReferenceResolver(
            layout: layout,
            context: .object(["state": .object([:])])
        )

        // When / Then
        #expect(throws: TouchLayoutError.unresolvedReference(reference)) {
            try resolver.resolvedLayout()
        }
    }

    @Test
    func resolvedLayoutWhenTheLayoutIsNotAnObjectThenThrows() {
        // Given
        let resolver = TouchReferenceResolver(layout: .array([]), context: .object([:]))

        // When / Then
        #expect(throws: TouchLayoutError.invalidLayout("The layout is not a JSON object")) {
            try resolver.resolvedLayout()
        }
    }
}
