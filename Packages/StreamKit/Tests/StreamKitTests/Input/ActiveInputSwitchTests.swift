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
        var activeInputSwitch = ActiveInputSwitch()
        let press = GamepadState(buttons: [.a])

        // When
        let flips = (0..<5).compactMap { _ in activeInputSwitch.record(press, from: .controller) }

        // Then
        #expect(flips == [.controller])
        #expect(activeInputSwitch.currentInput == .controller)
    }

    @Test
    func recordWhenTouchFollowsControllerThenFlipsBack() {
        // Given
        var activeInputSwitch = ActiveInputSwitch()
        activeInputSwitch.record(GamepadState(rightTrigger: 1), from: .controller)

        // When
        let flip = activeInputSwitch.record(GamepadState(buttons: [.b]), from: .touch)

        // Then
        #expect(flip == .touch)
        #expect(activeInputSwitch.currentInput == .touch)
    }

    @Test(arguments: [
        GamepadState(),
        GamepadState(leftStick: SIMD2(0.1, 0.1)),
        GamepadState(rightStick: SIMD2(0, -0.2)),
        GamepadState(leftTrigger: 0.2),
    ])
    func recordWhenControllerOnlyDriftsThenKeepsTouch(state: GamepadState) {
        // Given
        var activeInputSwitch = ActiveInputSwitch()

        // When
        let flip = activeInputSwitch.record(state, from: .controller)

        // Then
        #expect(flip == nil)
        #expect(activeInputSwitch.currentInput == .touch)
    }

    @Test
    func useWhenAlreadyCurrentThenReportsNoFlip() {
        // Given
        var activeInputSwitch = ActiveInputSwitch()

        // When / Then
        #expect(activeInputSwitch.use(.touch) == nil)
        #expect(activeInputSwitch.use(.controller) == .controller)
    }
}
