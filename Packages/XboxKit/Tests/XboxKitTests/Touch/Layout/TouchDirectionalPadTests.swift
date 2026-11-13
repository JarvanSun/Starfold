//
//  TouchDirectionalPadTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchDirectionalPadTests {
    @Test
    func initWhenOptionsAreOmittedThenAllowsNeighboursWithTheSchemaDeadzone() throws {
        // Given / When
        let pad = try JSONFixtureDecoder().decode(TouchDirectionalPad.self, from: "{}")

        // Then
        #expect(pad == .init(activation: .allowNeighboring, deadzone: 0.25, scale: 1))
    }

    @Test
    func initThenReadsActivationDeadzoneAndScale() throws {
        // Given / When
        let pad = try JSONFixtureDecoder().decode(
            TouchDirectionalPad.self,
            from: #"{"interaction":{"activationType":"exclusive"},"deadzone":0.4,"scale":1.3}"#
        )

        // Then
        #expect(pad == .init(activation: .exclusive, deadzone: 0.4, scale: 1.3))
    }
}
