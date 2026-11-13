//
//  TouchSticksTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StreamKit
import Testing

@testable import StarfoldShared

struct TouchSticksTests {
    @Test(
        arguments: [
            TouchInput.button(.a), .button(.leftThumb), .leftTrigger, .rightTrigger, .directionPad,
        ]
    )
    func visibilityWhenTheControlIsNotAStickThenIsAlways(input: TouchInput) {
        // Given
        var sticks = TouchSticks()
        sticks.setVisibility(.off, of: .leftStick)
        sticks.setVisibility(.off, of: .rightStick)

        // When
        sticks.setVisibility(.off, of: input)

        // Then
        #expect(sticks.visibility(of: input) == .always)
    }
}
