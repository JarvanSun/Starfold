//
//  DecodedFrame.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreVideo

struct DecodedFrame: @unchecked Sendable {
    let pixelBuffer: CVPixelBuffer
    let timing: DecodedFrameTiming
}
