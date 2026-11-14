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
        var keyboardGamepad = KeyboardGamepad()

        // When
        keyboardGamepad.setKey(KeyboardKey.w.rawValue, isDown: true)
        keyboardGamepad.setKey(KeyboardKey.d.rawValue, isDown: true)

        // Then
        let stick = keyboardGamepad.state.leftStick
        #expect(abs((stick * stick).sum() - 1) < 0.0001)
        #expect(stick.x > 0 && stick.y > 0)
    }

    @Test

    func stateWhenOppositeKeysHeldThenTheyCancelOut() {
        // Given
        var keyboardGamepad = KeyboardGamepad()

        // When
        keyboardGamepad.setKey(KeyboardKey.a.rawValue, isDown: true)
        keyboardGamepad.setKey(KeyboardKey.d.rawValue, isDown: true)

        // Then
        #expect(keyboardGamepad.state.leftStick == .zero)
    }

    @Test(arguments: [(UInt16(45), false), (KeyboardKey.space.rawValue, true)])
    func setKeyThenReportsWhetherTheKeyIsBound(keyCode: UInt16, isBound: Bool) {
        // Given
        var keyboardGamepad = KeyboardGamepad()

        // When / Then
        #expect(keyboardGamepad.setKey(keyCode, isDown: true) == isBound)
    }

    @Test

    func stateWhenSpaceHeldThenPressesA() {
        // Given
        var keyboardGamepad = KeyboardGamepad()

        // When
        keyboardGamepad.setKey(KeyboardKey.space.rawValue, isDown: true)

        // Then
        #expect(keyboardGamepad.state.buttons == [.a])
    }

    @Test

    func releaseAllThenNoKeyStaysPressed() {
        // Given
        var keyboardGamepad = KeyboardGamepad()
        keyboardGamepad.setKey(KeyboardKey.space.rawValue, isDown: true)

        // When
        keyboardGamepad.releaseAll()

        // Then
        #expect(keyboardGamepad.state == GamepadState())
    }
}
