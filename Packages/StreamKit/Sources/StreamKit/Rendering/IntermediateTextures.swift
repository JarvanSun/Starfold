//
//  IntermediateTextures.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Metal

final class IntermediateTextures {
    enum Role {
        case converted
        case upscaled
        case sharpened
    }

    private let device: MTLDevice
    private var textures: [Role: MTLTexture] = [:]

    init(device: MTLDevice) {
        self.device = device
    }

    func texture(
        _ role: Role,
        width: Int,
        height: Int,
        format: MTLPixelFormat,
        usage: MTLTextureUsage
    ) -> MTLTexture? {
        if let existing = textures[role],
            existing.width == width,
            existing.height == height,
            existing.usage.contains(usage)
        {
            return existing
        }

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: format,
            width: width,
            height: height,
            mipmapped: false
        )
        descriptor.usage = usage
        descriptor.storageMode = .private
        let texture = device.makeTexture(descriptor: descriptor)
        textures[role] = texture
        return texture
    }

    func removeAll() {
        textures.removeAll()
    }
}
