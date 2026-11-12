//
//  StreamPlatformOnVision.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import StarfoldShared
import StreamKit

extension StreamPlatform {
    init() {
        self.init(
            controllerRouting: .direct,
            picture: .init(
                canFit: false,
                canEnhance: true,
                shouldKeepLastFrame: true,
                isHDRDisplayAvailable: nil
            ),
            overlays: .init(
                statisticsRows: [
                    .resolution,
                    .lowered,
                    .frameRate,
                    .bitrate,
                    .roundTrip,
                    .decode,
                    .jitterBuffer,
                    .packetLoss,
                ],
                controlsHideDelay: nil
            )
        )
    }
}
