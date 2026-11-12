//
//  KeyboardGamepadTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import StreamKit

struct KeyboardGamepadTests {
    @Test
    func stateWhenTwoDirectionsHeldThenStickStaysOnTheUnitCircle() {
        // Given
        var keyboard = KeyboardGamepad()

        // When
        keyboard.setKey(KeyboardKey.w.rawValue, isDown: true)
        keyboard.setKey(KeyboardKey.d.rawValue, isDown: true)

        // Then
        let stick = keyboard.state.leftStick
        #expect(abs((stick * stick).sum() - 1) < 0.0001)
        #expect(stick.x > 0 && stick.y > 0)
    }

    @Test

    func stateWhenOppositeKeysHeldThenTheyCancelOut() {
        // Given
        var keyboard = KeyboardGamepad()

        // When
        keyboard.setKey(KeyboardKey.a.rawValue, isDown: true)
        keyboard.setKey(KeyboardKey.d.rawValue, isDown: true)

        // Then
        #expect(keyboard.state.leftStick == .zero)
    }

    @Test(arguments: [(UInt16(45), false), (KeyboardKey.space.rawValue, true)])
    func setKeyThenReportsWhetherTheKeyIsBound(keyCode: UInt16, isBound: Bool) {
        // Given
        var keyboard = KeyboardGamepad()

        // When / Then
        #expect(keyboard.setKey(keyCode, isDown: true) == isBound)
    }

    @Test

    func stateWhenSpaceHeldThenPressesA() {
        // Given
        var keyboard = KeyboardGamepad()

        // When
        keyboard.setKey(KeyboardKey.space.rawValue, isDown: true)

        // Then
        #expect(keyboard.state.buttons == [.a])
    }

    @Test

    func releaseAllThenNoKeyStaysPressed() {
        // Given
        var keyboard = KeyboardGamepad()
        keyboard.setKey(KeyboardKey.space.rawValue, isDown: true)

        // When
        keyboard.releaseAll()

        // Then
        #expect(keyboard.state == GamepadState())
    }
}
