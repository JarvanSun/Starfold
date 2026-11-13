//
//  TouchActionTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchActionTests {
    @Test(
        arguments: [
            (#""gamepadA""#, TouchAction.output(.gamepad(.gamepadA))),
            (#""relativeMouseUp""#, .output(.relativeMouse(.up))),
            (#""jump""#, .output(.unsupported("jump"))),
            (#"{"type":"layer","target":"WeaponLayer"}"#, .layer("WeaponLayer")),
            (
                #"{"type":"turbo","action":"rightTrigger","interval":250}"#,
                .turbo(.gamepad(.rightTrigger), interval: .milliseconds(250))
            ),
            (#"{"type":"macro","steps":[]}"#, .unsupported("macro")),
        ]
    )
    func initThenReadsEveryActionShape(json: String, expected: TouchAction) throws {
        #expect(try JSONFixtureDecoder().decode(TouchAction.self, from: json) == expected)
    }

    @Test(arguments: [#"{"type":"layer"}"#, #"{"type":"turbo","action":"gamepadA"}"#, "3"])
    func initWhenTheActionIsIncompleteThenThrows(json: String) {
        #expect(throws: DecodingError.self) {
            try JSONFixtureDecoder().decode(TouchAction.self, from: json)
        }
    }
}
