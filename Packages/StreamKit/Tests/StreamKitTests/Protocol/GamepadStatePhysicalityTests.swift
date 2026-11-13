//
//  GamepadStatePhysicalityTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import StreamKit

struct GamepadStatePhysicalityTests {
    @Test
    func physicalityWhenNotMergedThenEveryEngagedControlIsPhysical() {
        // Given
        let state = GamepadState(
            buttons: [.dpadUp, .menu],
            leftStick: SIMD2(0.4, 0),
            rightStick: SIMD2(0, -0.2),
            leftTrigger: 0.1
        )

        // When
        let physicality = state.physicality

        // Then
        #expect(physicality == GamepadPhysicality(physical: 0x250011, virtual: 0))
    }

    @Test
    func physicalityWhenMergedWithTouchThenUsesTheMergedValue() {
        // Given
        var state = GamepadState(buttons: [.a])
        state.mergedPhysicality = GamepadPhysicality(physical: 0, virtual: 0x1000)

        // When / Then
        #expect(state.physicality == GamepadPhysicality(physical: 0, virtual: 0x1000))
    }
}
