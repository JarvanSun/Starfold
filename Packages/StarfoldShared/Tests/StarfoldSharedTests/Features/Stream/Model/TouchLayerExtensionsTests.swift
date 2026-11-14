//
//  TouchLayerExtensionsTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing
import XboxKit

@testable import StarfoldShared

struct TouchLayerExtensionsTests {
    @Test
    func isDrawableWhenStandardThenIsTrue() {
        #expect(StandardTouchLayout().layout.base.isDrawable)
    }

    @Test
    func isDrawableWhenAVisibleTouchpadIsPresentThenIsFalse() {
        // Given
        let touchpad = TouchControl(
            kind: .touchpad(.init(axes: [.init(input: .xy, output: .gamepad(.rightJoystick))]))
        )

        // When
        let layer = TouchLayer(right: .init(inner: [.control(touchpad)]))

        // Then
        #expect(!layer.isDrawable)
    }

    @Test
    func isDrawableWhenTheUnsupportedControlIsHiddenThenIsTrue() {
        // Given
        let hidden = TouchControl(kind: .unsupported(type: "steeringWheel"), isVisible: false)

        // When
        let layer = TouchLayer(left: .init(inner: [.control(hidden)]))

        // Then
        #expect(layer.isDrawable)
    }

    @Test
    func isDrawableWhenTheCenterWheelHasAVisibleControlThenIsFalse() {
        // Given / When
        let layer = TouchLayer(center: .init(inner: [button(.gamepadA)]))

        // Then
        #expect(!layer.isDrawable)
    }

    @Test
    func isDrawableWhenOneSlotHoldsTwoVisibleControlsThenIsFalse() {
        // Given
        let fire = TouchControl(kind: .button(.init(actions: [.output(.gamepad(.rightTrigger))])))
        let punch = TouchControl(kind: .button(.init(actions: [.output(.gamepad(.gamepadB))])))

        // When
        let layer = TouchLayer(right: .init(outer: [.cluster([fire, punch])]))

        // Then
        #expect(!layer.isDrawable)
    }

    @Test
    func isDrawableWhenASlotHoldsOneControlAndAGapThenIsTrue() {
        // Given
        let aim = TouchControl(kind: .button(.init(actions: [.output(.gamepad(.leftTrigger))])))

        // When
        let layer = TouchLayer(right: .init(outer: [.cluster([aim, nil])]))

        // Then
        #expect(layer.isDrawable)
    }

    @Test
    func isDrawableWhenAButtonTogglesThenIsFalse() {
        // Given
        let aim = TouchControl(
            kind: .button(.init(actions: [.output(.gamepad(.leftTrigger))], isToggle: true))
        )

        // When
        let layer = TouchLayer(right: .init(inner: [.control(aim)]))

        // Then
        #expect(!layer.isDrawable)
    }
}

private extension TouchLayerExtensionsTests {
    func button(_ output: TouchGamepadOutput) -> TouchSlot {
        .control(.init(kind: .button(.init(actions: [.output(.gamepad(output))]))))
    }
}
