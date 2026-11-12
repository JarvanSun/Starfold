//
//  StreamPlaybackSettings.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AVFoundation
import QuartzCore
import StreamKit

struct StreamPlaybackSettings: Equatable {
    let pacing: PacingMode
    let videoGravity: AVLayerVideoGravity
    let dynamicRange: CALayer.DynamicRange?
    let enhancements: RenderEnhancements?
    let isDirectStereo: Bool

    init(preferences: Preferences, picture: PictureCapabilities) {
        let fit = picture.canFit ? preferences.pictureFit : .fit
        let isToneMappingHDR =
            preferences.isHDRToneMappingEnabled && (picture.isHDRDisplayAvailable?() ?? false)

        pacing = preferences.pacingMode
        videoGravity = fit.videoGravity
        isDirectStereo = preferences.soundStage == .direct

        dynamicRange =
            if picture.isHDRDisplayAvailable == nil {
                nil
            } else {
                isToneMappingHDR ? .high : .standard
            }

        enhancements =
            if picture.canEnhance {
                .init(
                    isUpscaling: preferences.isUpscalingEnabled,
                    sharpening: Float(preferences.sharpening),
                    fit: preferences.pictureFit,
                    isToneMappingHDR: isToneMappingHDR
                )
            } else {
                nil
            }
    }
}

private extension PictureFit {
    var videoGravity: AVLayerVideoGravity {
        switch self {
        case .fit: .resizeAspect
        case .fill: .resizeAspectFill
        case .scale: .resize
        }
    }
}
