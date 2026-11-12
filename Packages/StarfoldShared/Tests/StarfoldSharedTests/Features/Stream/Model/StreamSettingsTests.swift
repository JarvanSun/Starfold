//
//  StreamSettingsTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StreamKit
import Testing
import XboxKit

@testable import StarfoldShared

@MainActor
struct StreamSettingsTests {
    @Test
    func initWhenOtherKindsQualityChangesThenStaysEqual() {
        // Given
        let preferences = makePreferences()
        let started = StreamSettings(target: livingRoom, preferences: preferences)

        // When
        preferences.cloudQuality = .fixed(.standard)

        // Then
        #expect(StreamSettings(target: livingRoom, preferences: preferences) == started)
    }

    @Test
    func initWhenRunningKindsQualityChangesThenDiffers() {
        // Given
        let preferences = makePreferences()
        let started = StreamSettings(target: livingRoom, preferences: preferences)

        // When
        preferences.consoleQuality = .automatic

        // Then
        #expect(StreamSettings(target: livingRoom, preferences: preferences) != started)
    }

    @Test
    func initWhenQualityChangesBackThenIsEqualAgain() {
        // Given
        let preferences = makePreferences()
        let started = StreamSettings(target: livingRoom, preferences: preferences)
        preferences.consoleQuality = .automatic

        // When
        preferences.consoleQuality = .fixed(.highest)

        // Then
        #expect(StreamSettings(target: livingRoom, preferences: preferences) == started)
    }

    @Test
    func initWhenBitrateChangesThenDiffers() {
        // Given
        let preferences = makePreferences()
        let started = StreamSettings(target: livingRoom, preferences: preferences)

        // When
        preferences.maxBitrateMbps = 20

        // Then
        #expect(StreamSettings(target: livingRoom, preferences: preferences) != started)
    }

    @Test(arguments: [(0, nil), (20, 20_000)] as [(Int, Int?)])
    func maxBitrateKbpsThenIsKilobitsOrNilForAutomatic(megabits: Int, expected: Int?) {
        // Given
        let preferences = makePreferences()

        // When
        preferences.maxBitrateMbps = megabits

        // Then
        #expect(
            StreamSettings(target: livingRoom, preferences: preferences).maxBitrateKbps == expected
        )
    }
}

private extension StreamSettingsTests {
    var livingRoom: StreamTarget {
        .console(id: "X", name: "Living room")
    }

    func makePreferences() -> Preferences {
        let preferences = Preferences(defaults: .dummyEmpty)
        preferences.consoleQuality = .fixed(.highest)
        return preferences
    }
}
