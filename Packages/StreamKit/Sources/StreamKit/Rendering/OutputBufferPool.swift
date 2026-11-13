//
//  OutputBufferPool.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import CoreVideo
import Metal
import os

final class OutputBufferPool {
    private let textureCache: CVMetalTextureCache
    private let log = Logger(category: .render)

    private var pool: CVPixelBufferPool?
    private var size = (width: 0, height: 0)
    private var isHDR = false
    private var hasLoggedExhaustion = false

    init(textureCache: CVMetalTextureCache) {
        self.textureCache = textureCache
    }

    func target(width: Int, height: Int, isHDR: Bool) -> OutputTarget? {
        let isPoolCurrent = pool != nil && size == (width, height) && self.isHDR == isHDR

        if !isPoolCurrent {
            replacePool(width: width, height: height, isHDR: isHDR)
        }

        guard let buffer = makeBuffer() else { return nil }

        return makeTarget(on: buffer)
    }

    private func replacePool(width: Int, height: Int, isHDR: Bool) {
        let bufferAttributes: [CFString: Any] = [
            kCVPixelBufferPixelFormatTypeKey: isHDR
                ? kCVPixelFormatType_64RGBAHalf : kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey: width,
            kCVPixelBufferHeightKey: height,
            kCVPixelBufferIOSurfacePropertiesKey: [CFString: Any](),
            kCVPixelBufferMetalCompatibilityKey: true,
        ]

        let minimumBuffers = 4
        let poolAttributes: [CFString: Any] = [
            kCVPixelBufferPoolMinimumBufferCountKey: minimumBuffers
        ]
        var pool: CVPixelBufferPool?
        CVPixelBufferPoolCreate(
            nil,
            poolAttributes as CFDictionary,
            bufferAttributes as CFDictionary,
            &pool
        )
        self.pool = pool
        size = (width, height)
        self.isHDR = isHDR
        hasLoggedExhaustion = false
    }

    private func makeBuffer() -> CVPixelBuffer? {
        guard let pool else { return nil }

        let maximumBuffers = 12
        var buffer: CVPixelBuffer?
        let limit = [kCVPixelBufferPoolAllocationThresholdKey: maximumBuffers] as CFDictionary
        let status = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(nil, pool, limit, &buffer)
        guard status == kCVReturnSuccess, let buffer else {
            logExhaustion(status: status)

            return nil
        }

        return buffer
    }

    private func logExhaustion(status: CVReturn) {
        guard !hasLoggedExhaustion else { return }

        hasLoggedExhaustion = true
        log.error(
            "Dropping frames: no output buffer (\(status)) at \(self.size.width)x\(self.size.height)"
        )
    }

    private func makeTarget(on buffer: CVPixelBuffer) -> OutputTarget? {
        var texture: CVMetalTexture?
        let textureStatus = CVMetalTextureCacheCreateTextureFromImage(
            nil,
            textureCache,
            buffer,
            nil,
            isHDR ? .rgba16Float : .bgra8Unorm,
            size.width,
            size.height,
            0,
            &texture
        )
        guard textureStatus == kCVReturnSuccess,
            let texture,
            let metalTexture = CVMetalTextureGetTexture(texture)
        else { return nil }

        return .init(pixelBuffer: buffer, metalTexture: texture, texture: metalTexture)
    }
}
