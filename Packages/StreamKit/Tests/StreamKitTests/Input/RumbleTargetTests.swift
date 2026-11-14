//
//  RumbleTargetTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import StreamKit

struct RumbleTargetTests {
    @Test
    func initWhenControllerInSlotThenPlaysOnItEvenWithDeviceRumbleOn() {
        // Given / When
        let target = RumbleTarget(
            effect: makeEffect(slot: 0),
            controllerSlots: [0],
            isDeviceRumbleEnabled: true
        )

        // Then
        #expect(target == .controllers(slot: 0))
    }

    @Test
    func initWhenOnlyTouchAndDeviceRumbleOnThenPlaysOnDevice() {
        // Given / When
        let target = RumbleTarget(
            effect: makeEffect(slot: 0),
            controllerSlots: [],
            isDeviceRumbleEnabled: true
        )

        // Then
        #expect(target == .device)
    }

    @Test
    func initWhenOnlyTouchAndDeviceRumbleOffThenPlaysNowhere() {
        // Given / When
        let target = RumbleTarget(
            effect: makeEffect(slot: 0),
            controllerSlots: [],
            isDeviceRumbleEnabled: false
        )

        // Then
        #expect(target == .nowhere)
    }

    @Test
    func initWhenAnotherPlayersSlotIsEmptyThenNeverPlaysOnDevice() {
        // Given / When
        let target = RumbleTarget(
            effect: makeEffect(slot: 1),
            controllerSlots: [0],
            isDeviceRumbleEnabled: true
        )

        // Then
        #expect(target == .nowhere)
    }
}

private extension RumbleTargetTests {
    func makeEffect(slot: UInt8) -> VibrationEffect {
        .init(
            gamepadIndex: slot,
            leftMotor: 1,
            rightMotor: 0.5,
            leftTrigger: 0,
            rightTrigger: 0,
            duration: .milliseconds(100)
        )
    }
}
