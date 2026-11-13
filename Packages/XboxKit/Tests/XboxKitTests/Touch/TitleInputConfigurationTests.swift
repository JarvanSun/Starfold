//
//  TitleInputConfigurationTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import Testing

@testable import XboxKit

struct TitleInputConfigurationTests {
    @Test
    func initThenReadsTouchBundlesAndInputTypes() throws {
        // Given / When
        let configurations = try JSONDecoder().decode(
            [TitleInputConfiguration].self,
            from: Data(String.dummyInputConfigurations.utf8)
        )

        // Then
        let expected = [
            TitleInputConfiguration(
                touchBundleIDs: ["7c1e2f-touch"],
                inputTypes: [.controller, .customTouchOverlay, .unrecognized("HandheldGyro")]
            ),
            TitleInputConfiguration(
                touchBundleIDs: [],
                inputTypes: [.controller, .mouseAndKeyboard]
            ),
        ]
        #expect(configurations == expected)
    }

    @Test
    func initWhenFieldsAreMissingThenIsEmpty() throws {
        // Given / When
        let configuration = try JSONDecoder().decode(
            TitleInputConfiguration.self,
            from: Data("{}".utf8)
        )

        // Then
        #expect(!configuration.hasTouchLayout)
        #expect(configuration.inputTypes.isEmpty)
    }
}
