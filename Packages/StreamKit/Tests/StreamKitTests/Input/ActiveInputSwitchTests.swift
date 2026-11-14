//
//  ActiveInputSwitchTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import StreamKit

struct ActiveInputSwitchTests {
    @Test
    func recordWhenControllerPressesRepeatedlyThenFlipsOnce() {
        // Given
        var activeInput = ActiveInputSwitch()
        let press = GamepadState(buttons: [.a])

        // When
        let flips = (0..<5).compactMap { _ in activeInput.record(press, from: .controller) }

        // Then
        #expect(flips == [.controller])
        #expect(activeInput.currentInput == .controller)
    }

    @Test
    func recordWhenTouchFollowsControllerThenFlipsBack() {
        // Given
        var activeInput = ActiveInputSwitch()
        activeInput.record(GamepadState(rightTrigger: 1), from: .controller)

        // When
        let flip = activeInput.record(GamepadState(buttons: [.b]), from: .touch)

        // Then
        #expect(flip == .touch)
        #expect(activeInput.currentInput == .touch)
    }

    @Test(arguments: [
        GamepadState(),
        GamepadState(leftStick: SIMD2(0.1, 0.1)),
        GamepadState(rightStick: SIMD2(0, -0.2)),
        GamepadState(leftTrigger: 0.2),
    ])
    func recordWhenControllerOnlyDriftsThenKeepsTouch(state: GamepadState) {
        // Given
        var activeInput = ActiveInputSwitch()

        // When
        let flip = activeInput.record(state, from: .controller)

        // Then
        #expect(flip == nil)
        #expect(activeInput.currentInput == .touch)
    }

    @Test
    func useWhenAlreadyCurrentThenReportsNoFlip() {
        // Given
        var activeInput = ActiveInputSwitch()

        // When / Then
        #expect(activeInput.use(.touch) == nil)
        #expect(activeInput.use(.controller) == .controller)
    }
}
