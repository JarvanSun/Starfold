//
//  VideoColorConversion.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import CoreVideo
import simd

struct VideoColorConversion: Equatable, Sendable {
    enum Matrix: Sendable {
        case bt601
        case bt709
        case bt2020
    }

    var matrix: simd_float3x3
    var offset: SIMD3<Float>

    init(matrix: Matrix, isFullRange: Bool, bitDepth: Int) {
        let levels = SampleLevels(bitDepth: bitDepth)
        let step = Float(1 << (bitDepth - 8))
        let lumaBlack = isFullRange ? 0 : levels.normalized(16 * step)
        let lumaWhite =
            isFullRange ? levels.normalized(levels.maximumCode) : levels.normalized(235 * step)
        let chromaCenter = levels.normalized(128 * step)
        let chromaHalfRange =
            isFullRange
            ? chromaCenter : levels.normalized(128 * step) - levels.normalized(16 * step)
        let lumaScale = 1 / (lumaWhite - lumaBlack)
        let chromaScale = 0.5 / chromaHalfRange
        let coefficients = matrix.coefficients
        self.matrix = simd_float3x3(
            columns: (
                SIMD3<Float>(1, 1, 1) * lumaScale,
                SIMD3<Float>(0, coefficients.cbToG, coefficients.cbToB) * chromaScale,
                SIMD3<Float>(coefficients.crToR, coefficients.crToG, 0) * chromaScale
            )
        )
        offset = SIMD3<Float>(lumaBlack, chromaCenter, chromaCenter)
    }

    init(pixelBuffer: CVPixelBuffer) {
        let format = CVPixelBufferGetPixelFormatType(pixelBuffer)
        let isFullRange =
            format == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
            || format == kCVPixelFormatType_420YpCbCr10BiPlanarFullRange
        let isTenBit =
            format == kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange
            || format == kCVPixelFormatType_420YpCbCr10BiPlanarFullRange
        let matrixKey =
            CVBufferCopyAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, nil) as? String
        let matrix: Matrix =
            switch matrixKey {
            case String(kCVImageBufferYCbCrMatrix_ITU_R_601_4),
                String(kCVImageBufferYCbCrMatrix_SMPTE_240M_1995):
                .bt601
            case String(kCVImageBufferYCbCrMatrix_ITU_R_2020):
                .bt2020
            default:
                .bt709
            }
        self.init(matrix: matrix, isFullRange: isFullRange, bitDepth: isTenBit ? 10 : 8)
    }
}

private struct SampleLevels {
    let bitDepth: Int

    var maximumCode: Float {
        Float((1 << bitDepth) - 1)
    }

    func normalized(_ code: Float) -> Float {
        switch bitDepth {
        case 8: code / maximumCode
        default: code * Float(1 << (16 - bitDepth)) / 65535
        }
    }
}

private extension VideoColorConversion.Matrix {
    var coefficients: (crToR: Float, cbToG: Float, crToG: Float, cbToB: Float) {
        switch self {
        case .bt601: (1.402, -0.344136, -0.714136, 1.772)
        case .bt709: (1.5748, -0.187324, -0.468124, 1.8556)
        case .bt2020: (1.4746, -0.164553, -0.571353, 1.8814)
        }
    }
}
