//
//  PreferencesTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation
import StreamKit
import Testing
import XboxKit

@testable import StarfoldShared

@MainActor
struct PreferencesTests {
    @Test
    func initWhenNothingIsStoredThenUsesFactorySettings() {
        // Given / When
        let preferences = Preferences(defaults: .dummyEmpty)

        // Then
        #expect(preferences.consoleQuality == .automatic)
        #expect(preferences.cloudQuality == .automatic)
        #expect(preferences.cellularQuality == .fixed(.standard))
        #expect(preferences.maxBitrateMbps == 0)
        #expect(preferences.isUpscalingEnabled)
        #expect(preferences.sharpening == 0.3)
        #expect(!preferences.shouldShowStatistics)
        #expect(preferences.isKeyboardControllerEnabled)
        #expect(preferences.isRumbleEnabled)
        #expect(preferences.isTouchHapticsEnabled)
        #expect(preferences.pacingMode == .standard)
        #expect(preferences.soundStage == .window)
        #expect(preferences.pictureFit == .fit)
        #expect(!preferences.isHDRToneMappingEnabled)
        #expect(preferences.palette == .nebula)
        #expect(preferences.librarySort == .name)
    }

    @Test
    func initWhenRelaunchedThenRestoresEverySetting() {
        // Given
        let defaults = UserDefaults.dummyEmpty
        let preferences = Preferences(defaults: defaults)
        preferences.consoleQuality = .fixed(.highest)
        preferences.cloudQuality = .fixed(.standard)
        preferences.cellularQuality = .automatic
        preferences.maxBitrateMbps = 40
        preferences.isUpscalingEnabled = false
        preferences.sharpening = 1
        preferences.shouldShowStatistics = true
        preferences.gameLanguage = "ja-JP"
        preferences.isKeyboardControllerEnabled = false
        preferences.isRumbleEnabled = false
        preferences.isTouchHapticsEnabled = false
        preferences.pacingMode = .lowLatency
        preferences.soundStage = .direct
        preferences.pictureFit = .fill
        preferences.isHDRToneMappingEnabled = true
        preferences.palette = .sunrise
        preferences.librarySort = .recent

        // When
        let relaunched = Preferences(defaults: defaults)

        // Then
        #expect(relaunched.consoleQuality == .fixed(.highest))
        #expect(relaunched.cloudQuality == .fixed(.standard))
        #expect(relaunched.cellularQuality == .automatic)
        #expect(relaunched.maxBitrateMbps == 40)
        #expect(!relaunched.isUpscalingEnabled)
        #expect(relaunched.sharpening == 1)
        #expect(relaunched.shouldShowStatistics)
        #expect(relaunched.gameLanguage == "ja-JP")
        #expect(!relaunched.isKeyboardControllerEnabled)
        #expect(!relaunched.isRumbleEnabled)
        #expect(!relaunched.isTouchHapticsEnabled)
        #expect(relaunched.pacingMode == .lowLatency)
        #expect(relaunched.soundStage == .direct)
        #expect(relaunched.pictureFit == .fill)
        #expect(relaunched.isHDRToneMappingEnabled)
        #expect(relaunched.palette == .sunrise)
        #expect(relaunched.librarySort == .recent)
    }

    @Test
    func initWhenStoredBufferModeWasRemovedThenFallsBackToStandard() {
        // Given
        let defaults = UserDefaults.dummyEmpty
        defaults.set("smooth", forKey: "pacingMode")

        // When
        let preferences = Preferences(defaults: defaults)

        // Then
        #expect(preferences.pacingMode == .standard)
    }

    @Test
    func effectiveGameLanguageWhenNoneIsChosenThenIsSystemLanguageAndRegion() {
        // Given / When
        let preferences = Preferences(defaults: .dummyEmpty)

        // Then
        #expect(preferences.effectiveGameLanguage.split(separator: "-").count == 2)
    }

    @Test
    func effectiveGameLanguageWhenOneIsChosenThenIsThatLanguage() {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)

        // When
        preferences.gameLanguage = "de-DE"

        // Then
        #expect(preferences.effectiveGameLanguage == "de-DE")
    }

    @Test
    func clientAppInstallIDWhenReadAfterRelaunchThenStaysTheSame() {
        // Given
        let defaults = UserDefaults.dummyEmpty
        let firstID = Preferences(defaults: defaults).clientAppInstallID

        // When
        let relaunchedID = Preferences(defaults: defaults).clientAppInstallID

        // Then
        #expect(relaunchedID == firstID)
    }

    @Test
    func touchLayoutAdjustmentsWhenRelaunchedThenRestoresEachOrientationSeparately() {
        // Given
        let defaults = UserDefaults.dummyEmpty
        var landscape = TouchLayoutAdjustments()
        landscape.opacity = 0.5
        landscape.controls["gamepadA"] = .init(offset: .init(x: 10, y: -4), scale: 1.2)
        Preferences(defaults: defaults).setTouchLayoutAdjustments(landscape, for: .landscape)

        // When
        let relaunched = Preferences(defaults: defaults)

        // Then
        #expect(relaunched.touchLayoutAdjustments(for: .landscape) == landscape)
        #expect(relaunched.touchLayoutAdjustments(for: .portrait) == TouchLayoutAdjustments())
    }

    @Test
    func touchSticksWhenRelaunchedThenRestoresEachStick() {
        // Given
        let defaults = UserDefaults.dummyEmpty
        Preferences(defaults: defaults).touchSticks.setVisibility(.off, of: .rightStick)

        // When
        let relaunched = Preferences(defaults: defaults)

        // Then
        #expect(relaunched.touchSticks.visibility(of: .rightStick) == .off)
        #expect(relaunched.touchSticks.visibility(of: .leftStick) == .always)
    }

    @Test
    func favoritesWhenOneAccountTogglesThenOtherAccountIsUnaffected() {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)

        // When
        preferences.makeFavoritesStore(for: "1111").toggle("ALPHA")

        // Then
        #expect(preferences.makeFavoritesStore(for: "2222").titleIDs.isEmpty)
        #expect(preferences.makeFavoritesStore(for: "1111").contains("ALPHA"))
    }
}
