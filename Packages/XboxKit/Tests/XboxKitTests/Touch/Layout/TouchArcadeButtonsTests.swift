//
//  TouchArcadeButtonsTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchArcadeButtonsTests {
    @Test
    func initThenReadsEachPresentPosition() throws {
        // Given / When
        let buttons = try JSONFixtureDecoder().decode(
            TouchArcadeButtons.self,
            from: """
                {"type":"arcadeButtons","lightPunch":{"action":"gamepadX","visible":false},
                 "heavyKick":{"action":"leftBumper","icon":"heavyKick"}}
                """
        )

        // Then
        let heavyKickFace = TouchImage(source: .icon("heavyKick", showsActionLabel: true))
        let expected: [TouchArcadeButtonPosition: TouchArcadeButton] = [
            .lightPunch: .init(actions: [.output(.gamepad(.gamepadX))], isVisible: false),
            .heavyKick: .init(
                actions: [.output(.gamepad(.leftBumper))],
                styles: [.default: .init(faceImage: heavyKickFace)]
            ),
        ]
        #expect(buttons.buttons == expected)
    }
}
