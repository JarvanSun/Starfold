//
//  OutputTarget.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import CoreVideo
import Metal

struct OutputTarget {
    let pixelBuffer: CVPixelBuffer
    let metalTexture: CVMetalTexture
    let texture: MTLTexture

    func tagColor(from source: CVPixelBuffer, isToneMappingHDR: Bool) {
        switch isToneMappingHDR {
        case true: tagAsPQ()
        case false: copyColorAttachments(from: source)
        }
    }

    private func tagAsPQ() {
        CVBufferSetAttachment(
            pixelBuffer,
            kCVImageBufferColorPrimariesKey,
            kCVImageBufferColorPrimaries_ITU_R_2020,
            .shouldPropagate
        )
        CVBufferSetAttachment(
            pixelBuffer,
            kCVImageBufferTransferFunctionKey,
            kCVImageBufferTransferFunction_SMPTE_ST_2084_PQ,
            .shouldPropagate
        )
    }

    private func copyColorAttachments(from source: CVPixelBuffer) {
        let keys: [(CFString, CFString)] = [
            (kCVImageBufferColorPrimariesKey, kCVImageBufferColorPrimaries_ITU_R_709_2),
            (kCVImageBufferTransferFunctionKey, kCVImageBufferTransferFunction_ITU_R_709_2),
        ]

        for (key, fallback) in keys {
            let value = CVBufferCopyAttachment(source, key, nil) ?? fallback
            CVBufferSetAttachment(pixelBuffer, key, value, .shouldPropagate)
        }
    }
}
