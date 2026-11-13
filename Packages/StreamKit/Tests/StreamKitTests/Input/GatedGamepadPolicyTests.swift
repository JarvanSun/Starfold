//
//  GatedGamepadPolicyTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import StreamKit

struct GatedGamepadPolicyTests {
    @Test
    func updateWhenPlayingThenMenuPressHoldAndReleasePassThrough() {
        // Given
        var policy = GatedGamepadPolicy()
        policy.setPlaying(true)

        let down = GamepadState(buttons: [.menu])
        let held = GamepadState(buttons: [.menu, .a])
        let released = GamepadState(buttons: [.a])

        // When
        let downOutput = policy.update(.slot(0), state: down)
        let heldOutput = policy.update(.slot(0), state: held)
        let releasedOutput = policy.update(.slot(0), state: released)

        // Then
        #expect(downOutput.states[.slot(0)] == down)
        #expect(heldOutput.states[.slot(0)] == held)
        #expect(releasedOutput.states[.slot(0)] == released)
        #expect(policy.isPlaying)
    }

    @Test

    func setPlayingWhenStoppedThenSendsNeutralAndQuarantinesHeldControlsUntilRelease() {
        // Given
        var policy = GatedGamepadPolicy()
        policy.setPlaying(true)

        let held = GamepadState(buttons: [.a, .menu], leftStick: SIMD2(1, 0), leftTrigger: 1)
        policy.update(.slot(0), state: held)
        policy.update(.slot(1), state: GamepadState(buttons: [.b]))

        // When
        let stopped = policy.setPlaying(false)

        policy.setPlaying(true)
        let stillHeld = policy.update(.slot(0), state: held)

        policy.update(.slot(0), state: GamepadState())
        let pressedAgain = policy.update(.slot(0), state: held)

        // Then
        #expect(stopped.states[.slot(0)] == GamepadState())
        #expect(stopped.states[.slot(1)] == GamepadState())
        #expect(stillHeld.states[.slot(0)] == GamepadState())
        #expect(pressedAgain.states[.slot(0)] == held)
    }

    @Test

    func updateWhenDisconnectedThenRemovesPlayerOnceAndForgetsHeldState() {
        // Given
        var policy = GatedGamepadPolicy()
        policy.setPlaying(true)
        policy.update(.slot(0), state: GamepadState(buttons: [.menu]))

        // When
        let removed = policy.update(.slot(0), state: nil)
        let reconnected = policy.update(.slot(0), state: GamepadState(buttons: [.a]))

        // Then
        #expect(removed.states.isEmpty)
        #expect(removed.removed == [.slot(0)])
        #expect(reconnected.states[.slot(0)]?.buttons == [.a])
    }

    @Test
    func setPlayingWhenTouchHeldThenQuarantinesTouchApartFromPlayerOnePad() {
        // Given
        var policy = GatedGamepadPolicy()
        policy.setPlaying(true)

        let touchHeld = GamepadState(buttons: [.a])
        policy.update(.touch, state: touchHeld)
        policy.update(.slot(0), state: GamepadState())

        // When
        let stopped = policy.setPlaying(false)

        policy.setPlaying(true)
        let stillHeld = policy.update(.touch, state: touchHeld)
        let padPress = policy.update(.slot(0), state: GamepadState(buttons: [.a]))

        // Then
        #expect(stopped.states[.touch] == GamepadState())
        #expect(stopped.shouldClearPendingInput)
        #expect(stillHeld.states[.touch] == GamepadState())
        #expect(padPress.states[.slot(0)] == GamepadState(buttons: [.a]))
    }
}
