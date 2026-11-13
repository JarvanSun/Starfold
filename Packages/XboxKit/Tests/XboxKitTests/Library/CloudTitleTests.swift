//
//  CloudTitleTests.swift
//  XboxKitTests
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import Testing

@testable import XboxKit

struct CloudTitleTests {
    @Test
    func initWhenACacheHasNoTouchBundlesThenDecodesWithNone() throws {
        // Given
        let cached = """
            {"id":"FORTNITE","productID":"9NBLGGH4RR2Z","hasEntitlement":true,"isFreeInStore":true,
             "supportedInputTypes":["Controller"],"userSubscriptions":[]}
            """

        // When
        let title = try JSONDecoder().decode(CloudTitle.self, from: Data(cached.utf8))

        // Then
        #expect(title.touchBundleIDs.isEmpty)
        #expect(title.isPlayable)
    }

    @Test
    func encodeThenRoundTripsEveryField() throws {
        // Given
        let title = CloudTitle(
            id: "FORTNITE",
            productID: "9NBLGGH4RR2Z",
            hasEntitlement: false,
            isFreeInStore: true,
            supportedInputTypes: ["Controller", "CustomTouchOverlay"],
            touchBundleIDs: ["7c1e2f-touch"],
            lastPlayed: .dummyTestStart,
            userSubscriptions: ["GamePass"]
        )

        // When
        let decoded = try JSONDecoder().decode(CloudTitle.self, from: JSONEncoder().encode(title))

        // Then
        #expect(decoded == title)
    }

    @Test(
        arguments: [
            (["Controller"], [String](), false),
            (["Controller", "NativeTouch"], [], true),
            (["Controller", "CustomTouchOverlay"], [], true),
            (["Controller"], ["7c1e2f-touch"], true),
        ]
    )
    func supportsTouchThenCountsTouchInputAndTouchLayouts(
        inputTypes: [String],
        touchBundleIDs: [String],
        supportsTouch: Bool
    ) {
        // Given / When
        let title = CloudTitle(
            id: "FORTNITE",
            productID: "9NBLGGH4RR2Z",
            hasEntitlement: true,
            isFreeInStore: false,
            supportedInputTypes: inputTypes,
            touchBundleIDs: touchBundleIDs,
            lastPlayed: nil,
            userSubscriptions: []
        )

        // Then
        #expect(title.supportsTouch == supportsTouch)
    }
}
