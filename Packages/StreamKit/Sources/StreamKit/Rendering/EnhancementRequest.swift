//
//  EnhancementRequest.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import CoreGraphics

struct EnhancementRequest {
    let isUpscaling: Bool
    let sharpening: Float
    let fit: PictureFit
    let isToneMappingHDR: Bool
    let drawableSize: CGSize
}
