//
//  GamepadStateMergingTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import StreamKit

struct GamepadStateMergingTests {
    @Test
    func mergedThenCombinesPadAndKeyboardWithoutOverwriting() {
        // Given
        var keyboardGamepad = KeyboardGamepad()
        keyboardGamepad.setKey(KeyboardKey.c.rawValue, isDown: true)

        let pad = GamepadState(buttons: [.b], leftStick: SIMD2(0.2, 0))

        // When
        let merged = pad.merged(with: keyboardGamepad.state)

        // Then
        #expect(merged.buttons == [.b])
        #expect(merged.rightTrigger == 1)
        #expect(merged.leftStick == SIMD2(0.2, 0))
    }

    @Test
    func mergedWithTouchWhenTouchEngagedThenKeepsPhysicalAndVirtualPhysicalityApart() {
        // Given
        let pad = GamepadState(buttons: [.a], rightTrigger: 1)
        let touch = GamepadState(buttons: [.a, .y])

        // When
        let merged = pad.merged(withTouch: touch)

        // Then
        #expect(merged.buttons == [.a, .y])
        #expect(merged.rightTrigger == 1)
        #expect(merged.physicality == GamepadPhysicality(physical: 0x21000, virtual: 0x9000))
    }

    @Test
    func mergedWithTouchWhenTouchNeutralThenIsThePadUnchanged() {
        // Given
        let pad = GamepadState(buttons: [.x], leftStick: SIMD2(0.5, 0))

        // When
        let merged = pad.merged(withTouch: GamepadState())

        // Then
        #expect(merged == pad)
        #expect(merged.mergedPhysicality == nil)
    }
}
