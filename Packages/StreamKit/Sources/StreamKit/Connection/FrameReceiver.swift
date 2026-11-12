//
//  FrameReceiver.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreGraphics
import Foundation
@preconcurrency import LiveKitWebRTC
import QuartzCore

final class FrameReceiver: NSObject, LKRTCVideoRenderer, @unchecked Sendable {
    typealias FrameTimingHandler = @Sendable (DecodedFrameTiming) -> Void

    private let lock = NSLock()
    private weak var sink: VideoFrameReceiving?
    private var onFrame: FrameTimingHandler?

    func setSink(_ sink: VideoFrameReceiving?) {
        lock.withLock { self.sink = sink }
    }

    func setFrameTimingHandler(_ handler: FrameTimingHandler?) {
        lock.withLock { onFrame = handler }
    }

    func setSize(_ size: CGSize) {}

    func renderFrame(_ frame: LKRTCVideoFrame?) {
        guard let frame, let buffer = frame.buffer as? LKRTCCVPixelBuffer else { return }

        let timing = DecodedFrameTiming(
            rtpTimestamp: UInt32(bitPattern: frame.timeStamp),
            arrival: CACurrentMediaTime()
        )
        let (sink, onFrame) = lock.withLock { (sink, onFrame) }
        sink?.render(buffer.pixelBuffer, timing: timing)

        onFrame?(timing)
    }
}
