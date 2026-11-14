//
//  TouchControlKindTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchControlKindTests {
    @Test(
        arguments: [
            (#"{"type":"button","action":"gamepadA"}"#, "button"),
            (#"{"type":"joystick","axis":{"input":"axisXY","output":"leftJoystick"}}"#, "joystick"),
            (#"{"type":"directionalPad"}"#, "directionalPad"),
            (#"{"type":"throttle","axisUp":"rightTrigger","axisDown":"leftTrigger"}"#, "throttle"),
            (
                #"{"type":"touchpad","axis":{"input":"axisXY","output":"relativeMouse"}}"#,
                "touchpad"
            ),
            (#"{"type":"arcadeButtons","lightPunch":{"action":"gamepadX"}}"#, "arcadeButtons"),
            (#"{"type":"blank"}"#, "blank"),
        ]
    )
    func initThenReadsEveryKnownType(json: String, expected: String) throws {
        // Given / When
        let control = try JSONFixtureDecoder().decode(TouchControl.self, from: json)

        // Then
        #expect(name(of: control.kind) == expected)
    }

    @Test(
        arguments: [
            (#"{"type":"steeringWheel"}"#, "steeringWheel"),
            (#"{"type":"button"}"#, "button"),
            (#"{"type":"joystick","axis":{"input":"axisW","output":"leftJoystick"}}"#, "joystick"),
            (#"{"action":"gamepadA"}"#, ""),
        ]
    )
    func initWhenTheTypeIsUnknownOrIncompleteThenIsUnsupported(json: String, type: String) throws {
        // Given / When
        let control = try JSONFixtureDecoder().decode(TouchControl.self, from: json)

        // Then
        #expect(control.kind == .unsupported(type: type))
    }
}

private extension TouchControlKindTests {
    func name(of kind: TouchControlKind) -> String {
        switch kind {
        case .button: "button"
        case .joystick: "joystick"
        case .directionalPad: "directionalPad"
        case .throttle: "throttle"
        case .touchpad: "touchpad"
        case .arcadeButtons: "arcadeButtons"
        case .blank: "blank"
        case .unsupported(let type): "unsupported \(type)"
        }
    }
}
