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
}
