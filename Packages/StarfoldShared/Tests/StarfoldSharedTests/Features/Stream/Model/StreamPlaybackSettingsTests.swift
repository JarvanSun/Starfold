//
//  StreamPlaybackSettingsTests.swift
//  StarfoldSharedTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AVFoundation
import StreamKit
import Testing

@testable import StarfoldShared

struct StreamPlaybackSettingsTests {
    @Test(arguments: [
        (PictureFit.fit, AVLayerVideoGravity.resizeAspect),
        (.fill, .resizeAspectFill),
        (.scale, .resize),
    ])
    func videoGravityThenFollowsTheChosenFit(fit: PictureFit, gravity: AVLayerVideoGravity) {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        preferences.pictureFit = fit

        // When
        let settings = StreamPlaybackSettings(
            preferences: preferences,
            picture: picture(),
            touch: nil
        )

        // Then
        #expect(settings.videoGravity == gravity)
    }

    @Test(arguments: [(true, true, true), (true, false, false), (false, true, false)])
    func isDeviceRumbleEnabledThenNeedsTouchHapticsAndDeviceHaptics(
        isTouchHapticsEnabled: Bool,
        hasDeviceHaptics: Bool,
        isEnabled: Bool
    ) {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        preferences.isTouchHapticsEnabled = isTouchHapticsEnabled
        let touchPlatform = TouchPlatform(
            controllerCategory: "Touch Controller",
            hasDeviceHaptics: hasDeviceHaptics,
            capabilities: TouchPlatform.dummy.capabilities
        )

        // When
        let settings = StreamPlaybackSettings(
            preferences: preferences,
            picture: picture(),
            touch: touchPlatform
        )

        // Then
        #expect(settings.isDeviceRumbleEnabled == isEnabled)
    }

    @Test
    func videoGravityWhenThePlatformCannotFitThenFitsTheWholePicture() {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        preferences.pictureFit = .fill

        // When
        let settings = StreamPlaybackSettings(
            preferences: preferences,
            picture: picture(canFit: false),
            touch: nil
        )

        // Then
        #expect(settings.videoGravity == .resizeAspect)
    }

    @Test(arguments: [(true, true, true), (true, false, false), (false, true, false)])
    func toneMappingThenNeedsThePreferenceAndAnHDRDisplay(
        isEnabled: Bool,
        isHDRDisplay: Bool,
        isToneMapping: Bool
    ) {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        preferences.isHDRToneMappingEnabled = isEnabled

        // When
        let settings = StreamPlaybackSettings(
            preferences: preferences,
            picture: picture(isHDRDisplayAvailable: { isHDRDisplay }),
            touch: nil
        )

        // Then
        #expect(settings.dynamicRange == (isToneMapping ? .high : .standard))
        #expect(
            settings.enhancements
                == RenderEnhancements(
                    isUpscaling: preferences.isUpscalingEnabled,
                    sharpening: Float(preferences.sharpening),
                    fit: preferences.pictureFit,
                    isToneMappingHDR: isToneMapping
                )
        )
    }

    @Test
    func dynamicRangeWhenThePlatformCannotTellThenIsLeftAlone() {
        // When
        let settings = StreamPlaybackSettings(
            preferences: Preferences(defaults: .dummyEmpty),
            picture: picture(isHDRDisplayAvailable: nil),
            touch: nil
        )

        // Then
        #expect(settings.dynamicRange == nil)
    }

    @Test
    func enhancementsThenCarryUpscalingAndSharpening() {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        preferences.isUpscalingEnabled = true
        preferences.sharpening = 0.5

        // When
        let settings = StreamPlaybackSettings(
            preferences: preferences,
            picture: picture(),
            touch: nil
        )

        // Then
        #expect(
            settings.enhancements
                == RenderEnhancements(
                    isUpscaling: true,
                    sharpening: 0.5,
                    fit: preferences.pictureFit,
                    isToneMappingHDR: preferences.isHDRToneMappingEnabled
                )
        )
    }

    @Test
    func enhancementsWhenThePlatformCannotEnhanceThenAreNone() {
        // When
        let settings = StreamPlaybackSettings(
            preferences: Preferences(defaults: .dummyEmpty),
            picture: picture(canEnhance: false),
            touch: nil
        )

        // Then
        #expect(settings.enhancements == nil)
    }

    @Test(arguments: [(SoundStage.direct, true), (.window, false)])
    func isDirectStereoThenFollowsTheSoundStage(stage: SoundStage, isDirect: Bool) {
        // Given
        let preferences = Preferences(defaults: .dummyEmpty)
        preferences.soundStage = stage

        // When
        let settings = StreamPlaybackSettings(
            preferences: preferences,
            picture: picture(),
            touch: nil
        )

        // Then
        #expect(settings.isDirectStereo == isDirect)
    }
}

private extension StreamPlaybackSettingsTests {
    func picture(
        canFit: Bool = true,
        canEnhance: Bool = true,
        isHDRDisplayAvailable: (() -> Bool)? = { true }
    ) -> PictureCapabilities {
        .init(
            canFit: canFit,
            canEnhance: canEnhance,
            shouldKeepLastFrame: false,
            isHDRDisplayAvailable: isHDRDisplayAvailable
        )
    }
}
