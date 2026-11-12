//
//  StreamFailureAdvicePresentationTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import StarfoldShared

@MainActor
struct StreamFailureAdvicePresentationTests {
    @Test
    func textWhenUnrecognizedThenIsHostMessage() {
        #expect(String(localized: StreamFailureAdvice.unrecognized("New").text) == "New")
    }

    @Test
    func textWhenGamePassIsNeededThenNamesGamePass() {
        #expect(String(localized: StreamFailureAdvice.needsGamePass.text).contains("Game Pass"))
    }

    @Test
    func textWhenRecognizedThenEachAdviceIsDistinct() {
        // Given
        let recognized: [StreamFailureAdvice] = [
            .consoleOffline,
            .remotePlayOff,
            .consoleStillClosingLastStream,
            .consoleNotAnswering,
            .gameStillStarting,
            .needsGamePass,
            .networkDropped,
        ]

        // When
        let texts = recognized.map { String(localized: $0.text) }

        // Then
        #expect(Set(texts).count == recognized.count)
        #expect(!texts.contains(""))
    }
}
