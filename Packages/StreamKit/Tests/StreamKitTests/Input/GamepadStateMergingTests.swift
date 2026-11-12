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
        var keyboard = KeyboardGamepad()
        keyboard.setKey(KeyboardKey.c.rawValue, isDown: true)

        let pad = GamepadState(buttons: [.b], leftStick: SIMD2(0.2, 0))

        // When
        let merged = pad.merged(with: keyboard.state)

        // Then
        #expect(merged.buttons == [.b])
        #expect(merged.rightTrigger == 1)
        #expect(merged.leftStick == SIMD2(0.2, 0))
    }
}
