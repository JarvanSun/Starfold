//
//  TouchSensorTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchSensorTests {
    @Test
    func initThenReadsAnAccelerometerWithSeveralAxes() throws {
        // Given / When
        let sensor = try JSONFixtureDecoder().decode(
            TouchSensor.self,
            from: """
                {"type":"accelerometer","enabled":false,"axis":[
                  {"input":"axisZY","output":"rightJoystick"},{"input":"axisX","output":"leftJoystickX"}]}
                """
        )

        // Then
        let expected = TouchSensor(
            kind: .accelerometer,
            axes: [
                .init(input: .zy, output: .gamepad(.rightJoystick)),
                .init(input: .x, output: .gamepad(.leftJoystickX)),
            ],
            isEnabled: false
        )
        #expect(sensor == expected)
    }

    @Test(
        arguments: [
            (#"{"type":"blank"}"#, TouchSensorKind.blank),
            (#"{"type":"gyroscope"}"#, .unsupported(type: "gyroscope")),
            (
                #"{"type":"magnetometer","axis":{"input":"axisXY","output":"relativeMouse"}}"#,
                .unsupported(type: "magnetometer")
            ),
        ]
    )
    func initWhenTheSensorIsBlankUnknownOrIncompleteThenHasNoAxes(
        json: String,
        kind: TouchSensorKind
    )
        throws
    {
        // Given / When
        let sensor = try JSONFixtureDecoder().decode(TouchSensor.self, from: json)

        // Then
        #expect(sensor == .init(kind: kind))
    }
}
