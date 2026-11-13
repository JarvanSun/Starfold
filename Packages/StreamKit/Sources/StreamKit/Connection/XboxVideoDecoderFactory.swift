//
//  XboxVideoDecoderFactory.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
@preconcurrency import LiveKitWebRTC

final class XboxVideoDecoderFactory: NSObject, LKRTCVideoDecoderFactory {
    private let base = LKRTCDefaultVideoDecoderFactory()

    func supportedCodecs() -> [LKRTCVideoCodecInfo] {
        [h264Main] + base.supportedCodecs()
    }

    private var h264Main: LKRTCVideoCodecInfo {
        .init(
            name: kLKRTCVideoCodecH264Name,
            parameters: [
                "profile-level-id": "4d001f",
                "level-asymmetry-allowed": "1",
                "packetization-mode": "1",
            ]
        )
    }

    func createDecoder(_ info: LKRTCVideoCodecInfo) -> LKRTCVideoDecoder? {
        base.createDecoder(info)
    }
}
