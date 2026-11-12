//
//  InputStateTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing

@testable import StreamKit

struct InputStateTests {
    @Test
    func drainWhenStateUnchangedThenResendsOnlyAfterHeartbeat() {
        // Given
        let state = InputState(heartbeatMs: 50)
        state.setGamepad(0, state: GamepadState(buttons: [.a]))

        // When
        let first = state.drain(now: 0)
        let beforeHeartbeat = state.drain(now: 20)
        let afterHeartbeat = state.drain(now: 60)

        // Then
        #expect(first.report.gamepads.count == 1)
        #expect(beforeHeartbeat.report.gamepads.isEmpty)
        #expect(afterHeartbeat.report.gamepads.count == 1)
    }

    @Test

    func drainWhenPadDisconnectedThenReportsItRemovedWithOneNeutralRecord() {
        // Given
        let state = InputState()
        state.setGamepad(1, state: GamepadState(buttons: [.b]))
        let connected = state.drain(now: 0)

        // When
        state.setGamepad(1, state: nil)
        let snapshot = state.drain(now: 10)

        // Then
        #expect(connected.addedPads == [1])
        #expect(snapshot.removedPads == [1])
        #expect(snapshot.report.gamepads.count == 1)
        #expect(snapshot.report.gamepads[0].state == GamepadState())
    }

    @Test

    func drainWhenTapShorterThanOneSampleThenSendsItOnceThenReleases() {
        // Given
        let state = InputState()
        state.setGamepad(0, state: GamepadState())
        state.drain(now: 0)

        // When
        state.setGamepad(0, state: GamepadState(buttons: [.a]))
        state.setGamepad(0, state: GamepadState())
        let tapped = state.drain(now: 8)
        let released = state.drain(now: 16)

        // Then
        #expect(tapped.report.gamepads.first?.state.buttons == [.a])
        #expect(released.report.gamepads.first?.state.buttons == [])
    }

    @Test

    func pulseWhenNoControllerAttachedThenHoldsTheNexusButton() {
        // Given
        let state = InputState()

        // When
        state.pulse(.nexus, on: 0, duration: 10)

        // Then
        #expect(state.drain(now: 0).report.gamepads.first?.state.buttons.contains(.nexus) == true)
    }
}
