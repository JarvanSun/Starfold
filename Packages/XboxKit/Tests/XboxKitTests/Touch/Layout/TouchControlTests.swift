//
//  TouchControlTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import XboxKit

struct TouchControlTests {
    @Test
    func initWhenVisibilityIsOmittedThenIsVisibleAndEnabled() throws {
        // Given / When
        let control = try JSONFixtureDecoder().decode(
            TouchControl.self,
            from: #"{"type":"button","action":"menu"}"#
        )

        // Then
        #expect(control.isVisible)
        #expect(control.isEnabled)
        #expect(control.styles.isEmpty)
    }

    @Test
    func initThenReadsVisibilityEnabledAndStyles() throws {
        // Given / When
        let control = try JSONFixtureDecoder().decode(
            TouchControl.self,
            from: """
                {"type":"button","action":"menu","visible":false,"enabled":false,
                 "styles":{"idle":{"opacity":0.5}}}
                """
        )

        // Then
        #expect(!control.isVisible)
        #expect(!control.isEnabled)
        #expect(control.styles == [.idle: .init(opacity: 0.5)])
    }
}
