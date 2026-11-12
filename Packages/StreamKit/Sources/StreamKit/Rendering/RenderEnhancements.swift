//
//  RenderEnhancements.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct RenderEnhancements: Equatable, Sendable {
    var isUpscaling: Bool
    var sharpening: Float
    var fit: PictureFit
    var isToneMappingHDR: Bool

    public init(isUpscaling: Bool, sharpening: Float, fit: PictureFit, isToneMappingHDR: Bool) {
        self.isUpscaling = isUpscaling
        self.sharpening = sharpening
        self.fit = fit
        self.isToneMappingHDR = isToneMappingHDR
    }
}
