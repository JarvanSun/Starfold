//
//  RunningTitleParsingTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Testing

@testable import StreamKit

struct RunningTitleParsingTests {
    @Test
    func initWhenTitleIDAndFocusThenKeepsTheHexIDAsSent() {
        // Given / When
        let title = RunningTitle(content: ["titleid": "5d3c5a7d", "focus": true])

        // Then
        #expect(title == RunningTitle(titleID: "5d3c5a7d", isFocused: true))
    }

    @Test
    func initWhenKeysUseOtherCaseThenStillReadsThem() {
        // Given / When
        let title = RunningTitle(content: ["TitleId": "1A2B", "Focus": false])

        // Then
        #expect(title == RunningTitle(titleID: "1A2B", isFocused: false))
    }

    @Test
    func initWhenTitleIDIsANumberThenWritesItInHex() {
        // Given / When
        let title = RunningTitle(content: ["titleId": 1_563_449_981])

        // Then
        #expect(title == RunningTitle(titleID: "5D305A7D", isFocused: true))
    }

    @Test
    func initWhenTitleIDMissingThenIsNil() {
        #expect(RunningTitle(content: ["focus": true]) == nil)
    }
}
