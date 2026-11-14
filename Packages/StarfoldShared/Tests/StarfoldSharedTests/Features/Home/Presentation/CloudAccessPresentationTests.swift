//
//  CloudAccessPresentationTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/14.
//

import Foundation
import Testing

@testable import StarfoldShared

struct CloudAccessPresentationTests {
    @Test(arguments: [CloudAccess.gamePass, .freeToPlay, .unavailable])
    func rowStatusWhenAccessIsKnownThenIsTheCardSubtitle(access: CloudAccess) throws {
        // Given
        let subtitle = try #require(access.cardSubtitle(gameCount: 11))

        // When / Then
        #expect(String(localized: access.rowStatus(gameCount: 11)) == String(localized: subtitle))
    }

    @Test
    func rowStatusWhenAccessIsUnknownThenIsTheLoadingStatus() {
        // Given
        let access = CloudAccess.unknown

        // When / Then
        #expect(
            String(localized: access.rowStatus(gameCount: 0))
                == String(localized: access.statusText)
        )
    }
}
