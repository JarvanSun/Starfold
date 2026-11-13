//
//  TouchpadTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchpadTests {
    @Test
    func initWhenOptionsAreOmittedThenHasNoActionAndIsNotAButton() throws {
        // Given / When
        let touchpad = try JSONFixtureDecoder().decode(
            Touchpad.self,
            from: #"{"axis":{"input":"axisXY","output":"relativeMouse"}}"#
        )

        // Then
        #expect(touchpad == .init(axes: [.init(input: .xy, output: .relativeMouse(.movement))]))
    }
}
