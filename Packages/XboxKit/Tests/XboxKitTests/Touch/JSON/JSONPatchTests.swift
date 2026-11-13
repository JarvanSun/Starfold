//
//  JSONPatchTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import Testing

@testable import XboxKit

struct JSONPatchTests {
    @Test(
        arguments: [
            (#"{"a":1}"#, #"[{"op":"add","path":"/b","value":2}]"#, #"{"a":1,"b":2}"#),
            (#"{"a":[1,3]}"#, #"[{"op":"add","path":"/a/1","value":2}]"#, #"{"a":[1,2,3]}"#),
            (#"{"a":[1]}"#, #"[{"op":"add","path":"/a/-","value":2}]"#, #"{"a":[1,2]}"#),
            (#"{"a":1}"#, #"[{"op":"add","path":"","value":[]}]"#, #"[]"#),
            (#"{"a":1,"b":2}"#, #"[{"op":"remove","path":"/a"}]"#, #"{"b":2}"#),
            (#"{"a":[1,2,3]}"#, #"[{"op":"remove","path":"/a/1"}]"#, #"{"a":[1,3]}"#),
            (#"{"a":1}"#, #"[{"op":"replace","path":"/a","value":null}]"#, #"{"a":null}"#),
            (#"{"a":[1,2]}"#, #"[{"op":"replace","path":"/a/0","value":9}]"#, #"{"a":[9,2]}"#),
            (
                #"{"a":{"b":1},"c":{}}"#, #"[{"op":"move","from":"/a/b","path":"/c/d"}]"#,
                #"{"a":{},"c":{"d":1}}"#
            ),
            (#"{"a":[1,2,3]}"#, #"[{"op":"move","from":"/a/0","path":"/a/2"}]"#, #"{"a":[2,3,1]}"#),
            (
                #"{"a":{"b":1}}"#, #"[{"op":"copy","from":"/a","path":"/c"}]"#,
                #"{"a":{"b":1},"c":{"b":1}}"#
            ),
            (
                #"{"a~b":{"c/d":1}}"#, #"[{"op":"replace","path":"/a~0b/c~1d","value":2}]"#,
                #"{"a~b":{"c/d":2}}"#
            ),
            (
                #"{"a":[1,{"b":"x"}]}"#, #"[{"op":"test","path":"/a/1/b","value":"x"}]"#,
                #"{"a":[1,{"b":"x"}]}"#
            ),
        ]
    )
    func appliedThenProducesTheRFC6902Result(document: String, patch: String, expected: String)
        throws
    {
        // Given
        let patch = try decoded(JSONPatch.self, from: patch)

        // When
        let result = try patch.applied(to: decoded(JSONValue.self, from: document))

        // Then
        #expect(result == (try decoded(JSONValue.self, from: expected)))
    }

    @Test(
        arguments: [
            (#"[{"op":"remove","path":"/missing"}]"#, JSONPatchError.pathNotFound("/missing")),
            (#"[{"op":"replace","path":"/missing","value":1}]"#, .pathNotFound("/missing")),
            (#"[{"op":"add","path":"/x/y","value":1}]"#, .pathNotFound("/x/y")),
            (#"[{"op":"add","path":"/list/5","value":1}]"#, .invalidArrayIndex("/list/5")),
            (#"[{"op":"remove","path":"/list/-"}]"#, .invalidArrayIndex("/list/-")),
            (#"[{"op":"test","path":"/name","value":"other"}]"#, .testFailed("/name")),
            (#"[{"op":"move","from":"/list","path":"/list/0"}]"#, .moveIntoDescendant("/list/0")),
            (#"[{"op":"copy","from":"/missing","path":"/b"}]"#, .pathNotFound("/missing")),
            (#"[{"op":"remove","path":""}]"#, .pathNotFound("")),
        ]
    )
    func appliedWhenAnOperationCannotApplyThenThrows(patch: String, error: JSONPatchError) throws {
        // Given
        let document = try decoded(JSONValue.self, from: #"{"name":"pad","list":[1]}"#)
        let patch = try decoded(JSONPatch.self, from: patch)

        // When / Then
        #expect(throws: error) { try patch.applied(to: document) }
    }

    @Test
    func appliedWhenALaterOperationFailsThenLeavesTheDocumentUnchanged() throws {
        // Given
        let document = JSONValue.object(["a": .number(1)])
        let patch = try decoded(
            JSONPatch.self,
            from: #"[{"op":"replace","path":"/a","value":2},{"op":"test","path":"/a","value":3}]"#
        )

        // When
        _ = try? patch.applied(to: document)

        // Then
        #expect(document == .object(["a": .number(1)]))
    }
}

private extension JSONPatchTests {
    func decoded<Value: Decodable>(_ type: Value.Type, from json: String) throws -> Value {
        try JSONDecoder().decode(type, from: Data(json.utf8))
    }
}
