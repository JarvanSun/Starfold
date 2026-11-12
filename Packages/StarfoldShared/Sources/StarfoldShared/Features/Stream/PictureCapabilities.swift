//
//  PictureCapabilities.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct PictureCapabilities {
    let canFit: Bool
    let canEnhance: Bool
    let shouldKeepLastFrame: Bool
    let isHDRDisplayAvailable: (() -> Bool)?

    public init(
        canFit: Bool,
        canEnhance: Bool,
        shouldKeepLastFrame: Bool,
        isHDRDisplayAvailable: (() -> Bool)?
    ) {
        self.canFit = canFit
        self.canEnhance = canEnhance
        self.shouldKeepLastFrame = shouldKeepLastFrame
        self.isHDRDisplayAvailable = isHDRDisplayAvailable
    }
}
