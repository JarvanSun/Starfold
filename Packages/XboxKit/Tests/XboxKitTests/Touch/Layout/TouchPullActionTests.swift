//
//  TouchPullActionTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchPullActionTests {
    @Test(
        arguments: [
            (#""gamepadB""#, TouchPullAction.actions([.output(.gamepad(.gamepadB))])),
            (
                #"["gamepadB",{"type":"layer","target":"Map"}]"#,
                .actions([.output(.gamepad(.gamepadB)), .layer("Map")])
            ),
            (#"{"type":"layer","target":"Map"}"#, .actions([.layer("Map")])),
            (
                #"{"type":"segmented","items":["dPadUp",["dPadDown","gamepadA"]]}"#,
                .segmented([
                    [.output(.gamepad(.dPadUp))],
                    [.output(.gamepad(.dPadDown)), .output(.gamepad(.gamepadA))],
                ])
            ),
        ]
    )
    func initThenReadsSingleListedLayerAndSegmentedActions(json: String, expected: TouchPullAction)
        throws
    {
        #expect(try JSONFixtureDecoder().decode(TouchPullAction.self, from: json) == expected)
    }
}
