//
//  StreamPlatformOnTV.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import StreamKit

extension StreamPlatform {
    init() {
        self.init(
            controllerRouting: .gated,
            picture: .init(
                canFit: true,
                canEnhance: false,
                shouldKeepLastFrame: false,
                isHDRDisplayAvailable: nil
            ),
            overlays: .init(
                statisticsRows: [.resolution, .frameRate, .bitrate, .codec, .lowered],
                controlsHideDelay: nil
            ),
            touch: nil
        )
    }
}
