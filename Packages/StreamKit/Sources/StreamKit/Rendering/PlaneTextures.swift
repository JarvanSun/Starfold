//
//  PlaneTextures.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreVideo
import Metal

struct PlaneTextures {
    let luma: MTLTexture
    let chroma: MTLTexture

    private let lumaBacking: CVMetalTexture
    private let chromaBacking: CVMetalTexture

    init?(luma lumaBacking: CVMetalTexture, chroma chromaBacking: CVMetalTexture) {
        guard let luma = CVMetalTextureGetTexture(lumaBacking),
            let chroma = CVMetalTextureGetTexture(chromaBacking)
        else { return nil }

        self.luma = luma
        self.chroma = chroma
        self.lumaBacking = lumaBacking
        self.chromaBacking = chromaBacking
    }
}
