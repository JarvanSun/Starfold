//
//  VideoColorConversionTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Testing
import simd

@testable import StreamKit

struct VideoColorConversionTests {
    @Test
    func rgbWhenBT709VideoRangeThenMapsSixteenToBlackAndTwoThirtyFiveToWhite() {
        // Given
        let conversion = VideoColorConversion(matrix: .bt709, isFullRange: false, bitDepth: 8)

        // When
        let black = rgb(conversion, y: 16 / 255, cb: 128 / 255, cr: 128 / 255)
        let white = rgb(conversion, y: 235 / 255, cb: 128 / 255, cr: 128 / 255)

        // Then
        #expect(black.max() < 0.001)
        #expect(white.min() > 0.999)
    }

    @Test

    func rgbWhenBT709RedCodeValuesThenDecodesRed() {
        // Given
        let conversion = VideoColorConversion(matrix: .bt709, isFullRange: false, bitDepth: 8)

        // When
        let red = rgb(conversion, y: 63 / 255, cb: 102 / 255, cr: 240 / 255)

        // Then
        #expect(red.x > 0.97)
        #expect(red.y < 0.03)
        #expect(red.z < 0.03)
    }

    @Test

    func rgbWhenTenBitSamplesInSixteenBitWordsThenKeepsTheSameEndpoints() {
        // Given
        let conversion = VideoColorConversion(matrix: .bt2020, isFullRange: false, bitDepth: 10)
        let scale: Float = 64 / 65535

        // When
        let black = rgb(conversion, y: 64 * scale, cb: 512 * scale, cr: 512 * scale)
        let white = rgb(conversion, y: 940 * scale, cb: 512 * scale, cr: 512 * scale)

        // Then
        #expect(black.max() < 0.002)
        #expect(white.min() > 0.998)
    }
}

private extension VideoColorConversionTests {
    func rgb(_ conversion: VideoColorConversion, y: Float, cb: Float, cr: Float) -> SIMD3<Float> {
        let converted = conversion.matrix * (SIMD3<Float>(y, cb, cr) - conversion.offset)
        return simd_clamp(converted, SIMD3<Float>(repeating: 0), SIMD3<Float>(repeating: 1))
    }
}
