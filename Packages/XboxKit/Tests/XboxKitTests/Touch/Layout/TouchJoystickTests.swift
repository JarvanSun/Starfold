//
//  TouchJoystickTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchJoystickTests {
    @Test
    func initWhenOptionsAreOmittedThenUsesTheSchemaDefaults() throws {
        // Given / When
        let joystick = try JSONFixtureDecoder().decode(
            TouchJoystick.self,
            from: #"{"axis":{"input":"axisXY","output":"leftJoystick"}}"#
        )

        // Then
        #expect(joystick.actions.isEmpty)
        #expect(joystick.actionThreshold == 0)
        #expect(joystick.isRelative)
        #expect(joystick.shouldExpand)
    }

    @Test
    func initThenReadsActionThresholdRelativeAndExpand() throws {
        // Given / When
        let joystick = try JSONFixtureDecoder().decode(
            TouchJoystick.self,
            from: """
                {"axis":[{"input":"axisXY","output":"rightJoystick"}],"action":"rightTrigger",
                 "actionThreshold":0.8,"relative":false,"expand":false}
                """
        )

        // Then
        let expected = TouchJoystick(
            axes: [.init(input: .xy, output: .gamepad(.rightJoystick))],
            actions: [.output(.gamepad(.rightTrigger))],
            actionThreshold: 0.8,
            isRelative: false,
            shouldExpand: false
        )
        #expect(joystick == expected)
    }

    @Test
    func initWhenAVersionOneThresholdIsGivenThenUsesItAsTheActionThreshold() throws {
        // Given / When
        let joystick = try JSONFixtureDecoder().decode(
            TouchJoystick.self,
            from: #"{"axis":{"input":"axisXY","output":"leftJoystick"},"threshold":0.6}"#
        )

        // Then
        #expect(joystick.actionThreshold == 0.6)
    }
}
