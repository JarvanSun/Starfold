//
//  StreamPlaybackSettings.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AVFoundation
import QuartzCore
import StreamKit

struct StreamPlaybackSettings: Equatable, Sendable {
    let pacing: PacingMode
    let fit: PictureFit
    let isUpscalingEnabled: Bool
    let sharpening: Double
    let isToneMappingEnabled: Bool
    let soundStage: SoundStage
    let canFit: Bool
    let canEnhance: Bool
    let isHDRDisplay: Bool?
    let isDeviceRumbleEnabled: Bool

    var shownFit: PictureFit {
        canFit ? fit : .fit
    }

    var videoGravity: AVLayerVideoGravity {
        switch shownFit {
        case .fit: .resizeAspect
        case .fill: .resizeAspectFill
        case .scale: .resize
        }
    }

    var isToneMappingHDR: Bool {
        isToneMappingEnabled && isHDRDisplay == true
    }

    var dynamicRange: CALayer.DynamicRange? {
        guard isHDRDisplay != nil else { return nil }

        return isToneMappingHDR ? .high : .standard
    }

    var enhancements: RenderEnhancements? {
        guard canEnhance else { return nil }

        return .init(
            isUpscaling: isUpscalingEnabled,
            sharpening: Float(sharpening),
            fit: fit,
            isToneMappingHDR: isToneMappingHDR
        )
    }

    var isDirectStereo: Bool {
        soundStage == .direct
    }

    init(preferences: Preferences, picture: PictureCapabilities, touch: TouchPlatform?) {
        pacing = preferences.pacingMode
        fit = preferences.pictureFit
        isUpscalingEnabled = preferences.isUpscalingEnabled
        sharpening = preferences.sharpening
        isToneMappingEnabled = preferences.isHDRToneMappingEnabled
        soundStage = preferences.soundStage
        canFit = picture.canFit
        canEnhance = picture.canEnhance
        isHDRDisplay = picture.isHDRDisplayAvailable?()
        isDeviceRumbleEnabled = preferences.isTouchHapticsEnabled && touch?.hasDeviceHaptics == true
    }
}
