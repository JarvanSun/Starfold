//
//  TouchAxisMappingTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchAxisMappingTests {
    @Test
    func initThenReadsSensitivityDeadzoneAndResponseCurve() throws {
        // Given / When
        let mapping = try JSONFixtureDecoder().decode(
            TouchAxisMapping.self,
            from: """
                {"input":"axisRight","output":"rightTrigger","sensitivity":2,"deadzone":{"threshold":0.1},
                 "responseCurve":{"type":"circular-inverse","range":[0,1]}}
                """
        )

        // Then
        let expected = TouchAxisMapping(
            input: .right,
            output: .gamepad(.rightTrigger),
            sensitivity: 2,
            deadzone: .init(threshold: 0.1, isRadial: false),
            responseCurve: .circularInverse
        )
        #expect(mapping == expected)
    }

    @Test
    func initWhenOptionsAreOmittedThenHasUnitSensitivityAndNoDeadzone() throws {
        // Given / When
        let mapping = try JSONFixtureDecoder().decode(
            TouchAxisMapping.self,
            from: #"{"input":"axisY","output":"relativeMouseY"}"#
        )

        // Then
        #expect(mapping == .init(input: .y, output: .relativeMouse(.vertical)))
    }
}
