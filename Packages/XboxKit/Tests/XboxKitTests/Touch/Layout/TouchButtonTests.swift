//
//  TouchButtonTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchButtonTests {
    @Test
    func initThenReadsActionsPullActionAndToggle() throws {
        // Given / When
        let button = try JSONFixtureDecoder().decode(
            TouchButton.self,
            from: #"{"action":["gamepadA","rightBumper"],"pullAction":"gamepadY","toggle":true}"#
        )

        // Then
        let expected = TouchButton(
            actions: [.output(.gamepad(.gamepadA)), .output(.gamepad(.rightBumper))],
            pullAction: .actions([.output(.gamepad(.gamepadY))]),
            isToggle: true
        )
        #expect(button == expected)
    }

    @Test
    func initWhenOptionsAreOmittedThenIsAPlainButton() throws {
        // Given / When
        let button = try JSONFixtureDecoder().decode(TouchButton.self, from: #"{"action":"view"}"#)

        // Then
        #expect(button == .init(actions: [.output(.gamepad(.view))]))
    }
}
