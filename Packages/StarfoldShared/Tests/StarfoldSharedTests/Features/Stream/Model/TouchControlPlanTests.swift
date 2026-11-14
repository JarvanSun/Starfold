//
//  TouchControlPlanTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import CoreGraphics
import Testing
import XboxKit

@testable import StarfoldShared

struct TouchControlPlanTests {
    @Test
    func isRearrangementWhenOnlyOffsetsAndOpacityChangeThenIsTrue() {
        // Given
        let plan = makePlan(adjustments: .init())
        var moved = TouchLayoutAdjustments()
        moved.opacity = 0.9
        moved.controls["left.inner.0"] = .init(offset: CGPoint(x: 30, y: -12), scale: 1)

        // When
        let rearranged = makePlan(adjustments: moved)

        // Then
        #expect(rearranged.isRearrangement(of: plan))
    }

    @Test
    func isRearrangementWhenAControlIsResizedThenIsFalse() {
        // Given
        let plan = makePlan(adjustments: .init())
        var resized = TouchLayoutAdjustments()
        resized.controls["left.inner.0"] = .init(offset: .zero, scale: 1.2)

        // When / Then
        #expect(!makePlan(adjustments: resized).isRearrangement(of: plan))
    }

    @Test
    func isRearrangementWhenAStickIsHiddenThenIsFalse() {
        // Given
        let plan = makePlan(adjustments: .init())
        var sticks = TouchSticks()
        sticks.setVisibility(.off, of: .leftStick)

        // When / Then
        #expect(!makePlan(adjustments: .init(), sticks: sticks).isRearrangement(of: plan))
    }
}

private extension TouchControlPlanTests {
    func makePlan(
        adjustments: TouchLayoutAdjustments,
        sticks: TouchSticks = .init()
    ) -> TouchControlPlan {
        TouchLayoutPlanner(metrics: .dummy, adjustments: adjustments, sticks: sticks)
            .plan(for: StandardTouchLayout().layout.base)
    }
}
