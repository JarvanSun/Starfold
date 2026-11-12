//
//  RenderPipelines.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Metal

struct RenderPipelines {
    let rgb: MTLRenderPipelineState
    let pq: MTLRenderPipelineState
    let yuvToTexture: MTLRenderPipelineState
    let sharpen: MTLComputePipelineState

    init(device: MTLDevice, library: MTLLibrary) throws {
        let builder = PipelineBuilder(device: device, library: library)
        rgb = try builder.renderPipeline(fragment: .rgb, format: .bgra8Unorm)
        pq = try builder.renderPipeline(fragment: .toneMapPQ, format: .rgba16Float)
        yuvToTexture = try builder.renderPipeline(fragment: .yuv, format: .rgba16Float)
        sharpen = try builder.computePipeline(kernel: .sharpen)
    }
}

private enum ShaderFunction: String {
    case vertex = "streamVertex"
    case rgb = "streamRGBFragment"
    case toneMapPQ = "streamToneMapPQFragment"
    case yuv = "streamYUVFragment"
    case sharpen = "streamSharpen"
}

private enum PipelineError: Error {
    case missingFunction(String)
}

private struct PipelineBuilder {
    let device: MTLDevice
    let library: MTLLibrary

    func renderPipeline(fragment: ShaderFunction, format: MTLPixelFormat) throws
        -> MTLRenderPipelineState
    {
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: ShaderFunction.vertex.rawValue)
        descriptor.fragmentFunction = library.makeFunction(name: fragment.rawValue)
        descriptor.colorAttachments[0].pixelFormat = format
        return try device.makeRenderPipelineState(descriptor: descriptor)
    }

    func computePipeline(kernel: ShaderFunction) throws -> MTLComputePipelineState {
        guard let function = library.makeFunction(name: kernel.rawValue) else {
            throw PipelineError.missingFunction(kernel.rawValue)
        }

        return try device.makeComputePipelineState(function: function)
    }
}
