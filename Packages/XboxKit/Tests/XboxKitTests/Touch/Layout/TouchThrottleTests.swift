//
//  TouchThrottleTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchThrottleTests {
    @Test(
        arguments: [
            (
                #"{"axisUp":"rightTrigger","axisDown":"leftTrigger"}"#,
                TouchThrottle(upOutput: .gamepad(.rightTrigger), downOutput: .gamepad(.leftTrigger))
            ),
            (
                #"{"axisUp":"leftJoystickUp","axisDown":"leftJoystickDown","sticky":true,"relative":false}"#,
                .init(
                    upOutput: .gamepad(.leftJoystickUp),
                    downOutput: .gamepad(.leftJoystickDown),
                    isSticky: true,
                    isRelative: false
                )
            ),
        ]
    )
    func initThenReadsOutputsStickinessAndRelativeInteraction(json: String, expected: TouchThrottle)
        throws
    {
        #expect(try JSONFixtureDecoder().decode(TouchThrottle.self, from: json) == expected)
    }
}
