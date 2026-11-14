//
//  TouchControlPlacementTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import CoreGraphics
import Testing

@testable import StarfoldShared

struct TouchControlPlacementTests {
    @Test(
        arguments: [
            (TouchAnchor.topLeading, CGPoint(x: 10, y: 20)),
            (.bottomTrailing, CGPoint(x: 810, y: 420)),
            (.top, CGPoint(x: 410, y: 20)),
            (.center, CGPoint(x: 410, y: 220)),
        ]
    )
    func positionThenOffsetsFromTheAnchor(anchor: TouchAnchor, expected: CGPoint) {
        // Given
        let placement = TouchControlPlacement(
            id: "id",
            input: .leftStick,
            anchor: anchor,
            offset: CGPoint(x: 10, y: 20),
            diameter: 60,
            symbol: "l.joystick"
        )

        // When / Then
        #expect(placement.position(in: CGSize(width: 800, height: 400)) == expected)
    }
}
