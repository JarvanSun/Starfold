//
//  FrameEnhancer.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import CoreGraphics
import CoreVideo
import Metal
import os

#if canImport(MetalFX)
import MetalFX
#endif

final class FrameEnhancer {
    private struct ScalerKey: Equatable {
        var inputWidth: Int
        var inputHeight: Int
        var outputWidth: Int
        var outputHeight: Int
    }

    private let metalDevice: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let renderPipelines: RenderPipelines
    private let textureCache: CVMetalTextureCache
    private let outputPool: OutputBufferPool
    private let intermediateTextures: IntermediateTextures
    private let log = Logger(category: .render)

    #if canImport(MetalFX)
    private var spatialScaler: MTLFXSpatialScaler?
    #endif
    private var scalerKey: ScalerKey?

    var supportsUpscaling: Bool {
        #if canImport(MetalFX)
        MTLFXSpatialScalerDescriptor.supportsDevice(metalDevice)
        #else
        false
        #endif
    }

    init?(metalDevice: MTLDevice) {
        guard let commandQueue = metalDevice.makeCommandQueue(),
            let library = try? metalDevice.makeDefaultLibrary(bundle: .module)
        else { return nil }

        var cache: CVMetalTextureCache?
        guard CVMetalTextureCacheCreate(nil, nil, metalDevice, nil, &cache) == kCVReturnSuccess,
            let textureCache = cache,
            let renderPipelines = try? RenderPipelines(device: metalDevice, library: library)
        else { return nil }

        self.metalDevice = metalDevice
        self.commandQueue = commandQueue
        self.renderPipelines = renderPipelines
        self.textureCache = textureCache
        outputPool = OutputBufferPool(textureCache: textureCache)
        intermediateTextures = IntermediateTextures(metalDevice: metalDevice)
    }

    func enhance(_ frame: CVPixelBuffer, request: EnhancementRequest) -> CVPixelBuffer? {
        guard let planes = makePlaneTextures(from: frame),
            let commands = commandQueue.makeCommandBuffer()
        else { return nil }

        let frameSize = CGSize(width: planes.luma.width, height: planes.luma.height)
        let geometry = PictureGeometry(content: frameSize, container: request.drawableSize)
        let size = request.isUpscaling ? geometry.upscaledSize(for: request.fit) : frameSize
        let outputWidth = Int(size.width)
        let outputHeight = Int(size.height)
        guard
            let target = outputPool.target(
                width: outputWidth,
                height: outputHeight,
                isHDR: request.isToneMappingHDR
            )
        else { return nil }

        target.tagColor(from: frame, isToneMappingHDR: request.isToneMappingHDR)

        guard var current = convert(frame, planes: planes, commands: commands) else { return nil }

        if request.isUpscaling,
            outputWidth > planes.luma.width,
            let scaled = upscale(
                current,
                commands: commands,
                width: outputWidth,
                height: outputHeight
            )
        {
            current = scaled
        }

        if request.sharpening > 0,
            let sharpened = sharpen(current, strength: request.sharpening, commands: commands)
        {
            current = sharpened
        }

        let source = current
        encodeFullScreen(
            commands,
            target: target.texture,
            pipeline: request.isToneMappingHDR ? renderPipelines.pq : renderPipelines.rgb,
            viewport: CGRect(x: 0, y: 0, width: outputWidth, height: outputHeight)
        ) { encoder in
            encoder.setFragmentTexture(source, index: 0)
        }

        commands.commit()
        commands.waitUntilCompleted()

        withExtendedLifetime((planes, target.metalTexture)) {}

        guard commands.status == .completed else {
            log.error("Render failed: \(String(describing: commands.error), privacy: .public)")

            return nil
        }

        return target.pixelBuffer
    }

    private func makePlaneTextures(from frame: CVPixelBuffer) -> PlaneTextures? {
        guard CVPixelBufferGetPlaneCount(frame) == 2 else {
            log.error("Unsupported pixel format \(CVPixelBufferGetPixelFormatType(frame))")

            return nil
        }

        let format = CVPixelBufferGetPixelFormatType(frame)
        let isTenBit =
            format == kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange
            || format == kCVPixelFormatType_420YpCbCr10BiPlanarFullRange
        guard let luma = planeTexture(frame, plane: 0, format: isTenBit ? .r16Unorm : .r8Unorm),
            let chroma = planeTexture(frame, plane: 1, format: isTenBit ? .rg16Unorm : .rg8Unorm)
        else { return nil }

        return PlaneTextures(luma: luma, chroma: chroma)
    }

    private func planeTexture(_ frame: CVPixelBuffer, plane: Int, format: MTLPixelFormat)
        -> CVMetalTexture?
    {
        var texture: CVMetalTexture?
        let status = CVMetalTextureCacheCreateTextureFromImage(
            nil,
            textureCache,
            frame,
            nil,
            format,
            CVPixelBufferGetWidthOfPlane(frame, plane),
            CVPixelBufferGetHeightOfPlane(frame, plane),
            plane,
            &texture
        )
        return status == kCVReturnSuccess ? texture : nil
    }

    private func convert(
        _ frame: CVPixelBuffer,
        planes: PlaneTextures,
        commands: MTLCommandBuffer
    ) -> MTLTexture? {
        guard
            let converted = intermediateTextures.texture(
                .converted,
                width: planes.luma.width,
                height: planes.luma.height,
                format: .rgba16Float,
                usage: [.renderTarget, .shaderRead]
            )
        else { return nil }

        var conversion = VideoColorConversion(pixelBuffer: frame)
        encodeFullScreen(
            commands,
            target: converted,
            pipeline: renderPipelines.yuvToTexture,
            viewport: CGRect(x: 0, y: 0, width: planes.luma.width, height: planes.luma.height)
        ) { encoder in
            encoder.setFragmentTexture(planes.luma, index: 0)
            encoder.setFragmentTexture(planes.chroma, index: 1)
            encoder.setFragmentBytes(
                &conversion,
                length: MemoryLayout<VideoColorConversion>.stride,
                index: 0
            )
        }

        return converted
    }

    private func encodeFullScreen(
        _ commands: MTLCommandBuffer,
        target: MTLTexture,
        pipeline: MTLRenderPipelineState,
        viewport: CGRect,
        configure: (MTLRenderCommandEncoder) -> Void
    ) {
        let pass = MTLRenderPassDescriptor()
        pass.colorAttachments[0].texture = target
        pass.colorAttachments[0].loadAction = .clear
        pass.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        pass.colorAttachments[0].storeAction = .store

        guard let encoder = commands.makeRenderCommandEncoder(descriptor: pass) else { return }

        encoder.setRenderPipelineState(pipeline)
        encoder.setViewport(
            MTLViewport(
                originX: viewport.minX,
                originY: viewport.minY,
                width: viewport.width,
                height: viewport.height,
                znear: 0,
                zfar: 1
            )
        )
        configure(encoder)

        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        encoder.endEncoding()
    }

    private func upscale(_ input: MTLTexture, commands: MTLCommandBuffer, width: Int, height: Int)
        -> MTLTexture?
    {
        #if canImport(MetalFX)
        let key = ScalerKey(
            inputWidth: input.width,
            inputHeight: input.height,
            outputWidth: width,
            outputHeight: height
        )

        if scalerKey != key {
            spatialScaler = makeScaler(for: input, width: width, height: height)
            scalerKey = key
        }

        guard let spatialScaler,
            let output = intermediateTextures.texture(
                .upscaled,
                width: width,
                height: height,
                format: .rgba16Float,
                usage: spatialScaler.outputTextureUsage.union(.shaderRead)
            )
        else { return nil }

        spatialScaler.colorTexture = input
        spatialScaler.outputTexture = output
        spatialScaler.encode(commandBuffer: commands)
        return output
        #else
        return nil
        #endif
    }

    private func sharpen(_ input: MTLTexture, strength: Float, commands: MTLCommandBuffer)
        -> MTLTexture?
    {
        guard
            let sharpened = intermediateTextures.texture(
                .sharpened,
                width: input.width,
                height: input.height,
                format: .rgba16Float,
                usage: [.shaderRead, .shaderWrite]
            ),
            let encoder = commands.makeComputeCommandEncoder()
        else { return nil }

        var strength = strength
        encoder.setComputePipelineState(renderPipelines.sharpen)
        encoder.setTexture(input, index: 0)
        encoder.setTexture(sharpened, index: 1)
        encoder.setBytes(&strength, length: MemoryLayout<Float>.stride, index: 0)
        encoder.dispatchThreads(
            MTLSize(width: input.width, height: input.height, depth: 1),
            threadsPerThreadgroup: MTLSize(width: 16, height: 16, depth: 1)
        )
        encoder.endEncoding()

        return sharpened
    }

    func clear() {
        intermediateTextures.removeAll()
    }
}

// MARK: - Private

private extension FrameEnhancer {
    #if canImport(MetalFX)
    func makeScaler(for input: MTLTexture, width: Int, height: Int) -> MTLFXSpatialScaler? {
        let descriptor = MTLFXSpatialScalerDescriptor()
        descriptor.inputWidth = input.width
        descriptor.inputHeight = input.height
        descriptor.outputWidth = width
        descriptor.outputHeight = height
        descriptor.colorTextureFormat = input.pixelFormat
        descriptor.outputTextureFormat = .rgba16Float
        descriptor.colorProcessingMode = .perceptual

        guard let spatialScaler = descriptor.makeSpatialScaler(device: metalDevice) else {
            log.error(
                "MetalFX spatial scaler unavailable for \(input.width)x\(input.height) → \(width)x\(height)"
            )

            return nil
        }

        return spatialScaler
    }
    #endif
}
