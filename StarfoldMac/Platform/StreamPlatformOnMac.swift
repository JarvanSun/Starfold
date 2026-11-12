//
//  StreamPlatformOnMac.swift
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
                canFit: true,
                canEnhance: true,
                shouldKeepLastFrame: true,
                isHDRDisplayAvailable: { HDRDisplay().isAvailable }
            ),
            overlays: .init(
                statisticsRows: [
                    .resolution,
                    .codec,
                    .upscaled,
                    .dynamicRange,
                    .lowered,
                    .frameRate,
                    .bitrate,
                    .network,
                    .roundTrip,
                    .decode,
                    .jitterBuffer,
                    .display,
                    .packetLoss,
                ],
                controlsHideDelay: .seconds(3)
            )
        )
    }
}
