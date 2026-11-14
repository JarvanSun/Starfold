//
//  StreamPlatformOniOS.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StarfoldShared
import StreamKit

extension StreamPlatform {
    init() {
        self.init(
            controllerRouting: .gated,
            pictureCapabilities: .init(
                canFit: true,
                canEnhance: false,
                shouldKeepLastFrame: true,
                isHDRDisplayAvailable: nil
            ),
            overlays: .init(
                statisticsRows: [
                    .resolution,
                    .lowered,
                    .frameRate,
                    .bitrate,
                    .network,
                    .roundTrip,
                    .packetLoss,
                ],
                controlsHideDelay: .seconds(3)
            ),
            touchPlatform: TouchPlatform()
        )
    }
}
