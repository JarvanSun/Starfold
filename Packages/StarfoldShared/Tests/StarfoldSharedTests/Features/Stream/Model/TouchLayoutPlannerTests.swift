//
//  TouchLayoutPlannerTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import CoreGraphics
import StreamKit
import Testing
import XboxKit

@testable import StarfoldShared

struct TouchLayoutPlannerTests {
    @Test
    func planWhenStandardThenHasEveryXboxControlOnce() {
        // Given / When
        let plan = makePlan()

        // Then
        let inputs = plan.controls.map(\.input)
        #expect(Set(inputs).count == inputs.count)
        #expect(
            Set(inputs) == [
                .leftStick, .rightStick, .directionPad, .leftTrigger, .rightTrigger,
                .button(.a), .button(.b), .button(.x), .button(.y),
                .button(.leftShoulder), .button(.rightShoulder),
                .button(.leftThumb), .button(.rightThumb),
                .button(.menu), .button(.view),
            ]
        )
    }

    @Test
    func planWhenStandardThenPutsMovementBottomLeftAndFaceButtonsBottomRight() {
        // Given / When
        let plan = makePlan()

        // Then
        #expect(control(.leftStick, in: plan)?.anchor == .bottomLeading)
        #expect(control(.button(.a), in: plan)?.anchor == .bottomTrailing)
        #expect(control(.button(.menu), in: plan)?.anchor == .topTrailing)
    }

    @Test
    func planWhenStandardThenArrangesFaceButtonsAsADiamond() throws {
        // Given / When
        let plan = makePlan()

        // Then
        let y = try #require(control(.button(.y), in: plan)).offset
        let a = try #require(control(.button(.a), in: plan)).offset
        let x = try #require(control(.button(.x), in: plan)).offset
        let b = try #require(control(.button(.b), in: plan)).offset
        #expect(y.y < a.y)
        #expect(x.x < b.x)
        #expect(abs(y.x - a.x) < 0.001)
    }

    @Test
    func planWhenAControlIsAdjustedThenMovesAndScalesOnlyThatControl() throws {
        // Given
        let original = makePlan()
        let leftStick = try #require(control(.leftStick, in: original))
        var adjustments = TouchLayoutAdjustments()
        adjustments.controls[leftStick.id] = .init(offset: CGPoint(x: 20, y: -10), scale: 1.2)

        // When
        let adjusted = makePlan(adjustments: adjustments)

        // Then
        let moved = try #require(control(.leftStick, in: adjusted))
        #expect(moved.offset == CGPoint(x: leftStick.offset.x + 20, y: leftStick.offset.y - 10))
        #expect(moved.diameter == leftStick.diameter * 1.2)
        #expect(control(.button(.a), in: adjusted) == control(.button(.a), in: original))
    }

    @Test
    func planWhenTheTopEdgeHasCenterAndRightCenterRowsThenCentresOneAndPutsTheOtherBesideIt() throws
    {
        // Given
        let size = CGSize(width: 800, height: 400)
        let top = TouchEdge(center: [button(.view)], rightCenter: [button(.menu)])

        // When
        let plan = TouchLayoutPlanner(metrics: .dummy, adjustments: .init(), sticks: .init())
            .plan(for: TouchLayer(upper: top))

        // Then
        let view = try #require(control(.button(.view), in: plan)).position(in: size)
        let menu = try #require(control(.button(.menu), in: plan)).position(in: size)
        #expect(view.x == size.width / 2)
        #expect(menu.x - view.x >= TouchMetrics.dummy.smallButtonDiameter)
    }
}

private extension TouchLayoutPlannerTests {
    func makePlan(adjustments: TouchLayoutAdjustments = .init()) -> TouchControlPlan {
        TouchLayoutPlanner(metrics: .dummy, adjustments: adjustments, sticks: .init())
            .plan(for: StandardTouchLayout().layout.base)
    }

    func button(_ output: TouchGamepadOutput) -> TouchSlot {
        .control(.init(kind: .button(.init(actions: [.output(.gamepad(output))]))))
    }

    func control(_ input: TouchInput, in plan: TouchControlPlan) -> TouchControlPlacement? {
        plan.controls.first { $0.input == input }
    }
}
