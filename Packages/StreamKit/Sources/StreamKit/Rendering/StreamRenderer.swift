//
//  StreamRenderer.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import CoreImage
import CoreVideo
import Foundation
import Metal
import QuartzCore
import os

public final class StreamRenderer: VideoFrameReceiving, @unchecked Sendable {
    private struct PendingState {
        var onFirstFrame: (@Sendable () -> Void)?

        var frames: [DecodedFrame] = []
        var isDrainScheduled = false
        var enhancements = RenderEnhancements(
            isUpscaling: false,
            sharpening: 0,
            fit: .fit,
            isToneMappingHDR: false
        )
        var drawableSize = CGSize.zero
        var displayMs: Double?
        var upscaledTo: CGSize?
        var lastFrame: LastFrame?
    }

    public let systemVideo: SystemVideoPresenter

    private let keepsLastFrame: Bool
    private let frameEnhancer: FrameEnhancer
    private let queue = DispatchQueue(label: "StreamKit.render", qos: .userInteractive)
    private let lock = OSAllocatedUnfairLock<PendingState>(initialState: PendingState())

    public var upscaledTo: CGSize? {
        lock.withLock { $0.upscaledTo }
    }

    public var isToneMapping: Bool {
        lock.withLock { $0.enhancements.isToneMappingHDR }
    }

    public var displayLatencyMs: Double? {
        lock.withLock { $0.displayMs }
    }

    @MainActor
    public init?(keepsLastFrame: Bool) {
        guard let device = MTLCreateSystemDefaultDevice(),
            let frameEnhancer = FrameEnhancer(metalDevice: device)
        else { return nil }

        systemVideo = SystemVideoPresenter()
        self.keepsLastFrame = keepsLastFrame
        self.frameEnhancer = frameEnhancer
    }

    public func notifyFirstFrame(_ handler: @escaping @Sendable () -> Void) {
        lock.withLock { $0.onFirstFrame = handler }
    }

    public func setEnhancements(_ enhancements: RenderEnhancements) {
        lock.withLock { $0.enhancements = enhancements }
    }

    public func setDrawableSize(_ size: CGSize) {
        guard size.width >= 1, size.height >= 1 else { return }

        lock.withLock { $0.drawableSize = size }
    }

    public func render(_ pixelBuffer: CVPixelBuffer, timing: DecodedFrameTiming) {
        if keepsLastFrame {
            let lastFrame = LastFrame(pixelBuffer: pixelBuffer)
            lock.withLock { $0.lastFrame = lastFrame }
        }

        #if os(visionOS) || os(tvOS)
        let shownAt = systemVideo.enqueue(pixelBuffer, timing: timing)
        recordDisplayLatency((shownAt - timing.arrival) * 1000)

        fireFirstFrame()
        #else
        schedule(DecodedFrame(pixelBuffer: pixelBuffer, timing: timing))
        #endif
    }

    private func recordDisplayLatency(_ milliseconds: Double) {
        guard milliseconds >= 0, milliseconds < 1000 else { return }

        let latencySmoothing = 0.1

        lock.withLock { state in
            state.displayMs =
                state.displayMs.map { $0 + (milliseconds - $0) * latencySmoothing } ?? milliseconds
        }
    }

    private func fireFirstFrame() {
        let onFirstFrame = lock.withLock { state in
            defer { state.onFirstFrame = nil }

            return state.onFirstFrame
        }
        onFirstFrame?()
    }

    private func schedule(_ frame: DecodedFrame) {
        let maximumPendingFrames = maximumPendingFrames
        let shouldSchedule = lock.withLock { state in
            state.frames.append(frame)

            if state.frames.count > maximumPendingFrames {
                state.frames.removeFirst()
            }

            guard !state.isDrainScheduled else { return false }

            state.isDrainScheduled = true
            return true
        }

        if shouldSchedule {
            queue.async { [self] in drainPending() }
        }
    }

    private func drainPending() {
        while let (frame, enhancements, drawableSize) = nextPendingFrame() {
            autoreleasepool {
                present(frame, enhancements: enhancements, drawableSize: drawableSize)
            }
        }
    }

    private func nextPendingFrame() -> (DecodedFrame, RenderEnhancements, CGSize)? {
        lock.withLock { state in
            guard !state.frames.isEmpty else {
                state.isDrainScheduled = false

                return nil
            }

            return (state.frames.removeFirst(), state.enhancements, state.drawableSize)
        }
    }

    private func present(
        _ frame: DecodedFrame,
        enhancements: RenderEnhancements,
        drawableSize: CGSize
    ) {
        guard
            let output = enhanced(
                frame.pixelBuffer,
                enhancements: enhancements,
                drawableSize: drawableSize
            )
        else { return }

        recordUpscaledSize(of: output, from: frame.pixelBuffer)

        let ready = DecodedFrameTiming(
            rtpTimestamp: frame.timing.rtpTimestamp,
            arrival: CACurrentMediaTime()
        )
        let shownAt = systemVideo.enqueue(output, timing: ready)
        recordDisplayLatency((shownAt - frame.timing.arrival) * 1000)

        fireFirstFrame()
    }

    private func enhanced(
        _ pixelBuffer: CVPixelBuffer,
        enhancements: RenderEnhancements,
        drawableSize: CGSize
    ) -> CVPixelBuffer? {
        let isUpscaling = enhancements.isUpscaling && frameEnhancer.supportsUpscaling
        let sharpeningThreshold: Float = 0.001
        let isSharpening = enhancements.sharpening > sharpeningThreshold
        let isEnhancing = isUpscaling || isSharpening || enhancements.isToneMappingHDR
        guard isEnhancing else { return pixelBuffer }

        let request = EnhancementRequest(
            isUpscaling: isUpscaling,
            sharpening: isSharpening ? enhancements.sharpening : 0,
            fit: enhancements.fit,
            isToneMappingHDR: enhancements.isToneMappingHDR,
            drawableSize: drawableSize
        )
        return frameEnhancer.enhance(pixelBuffer, request: request)
    }

    private func recordUpscaledSize(of output: CVPixelBuffer, from input: CVPixelBuffer) {
        let size = CGSize(
            width: CVPixelBufferGetWidth(output),
            height: CVPixelBufferGetHeight(output)
        )
        let upscaledTo = size.width > CGFloat(CVPixelBufferGetWidth(input)) ? size : nil
        lock.withLock { $0.upscaledTo = upscaledTo }
    }

    private var maximumPendingFrames: Int { 6 }

    public func lastFrameImage() -> CGImage? {
        guard let buffer = lock.withLock({ $0.lastFrame })?.pixelBuffer else { return nil }

        let image = CIImage(cvPixelBuffer: buffer)
        let lastFrameMaximumWidth: CGFloat = 640
        let scale = min(1, lastFrameMaximumWidth / image.extent.width)
        let scaled = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        return CIContext().createCGImage(scaled, from: scaled.extent)
    }

    public func clear() {
        lock.withLock { $0.lastFrame = nil }
        #if os(visionOS) || os(tvOS)
        systemVideo.clear()
        #else
        lock.withLock { $0.frames.removeAll() }

        queue.async { [self] in
            systemVideo.clear()
            frameEnhancer.clear()
        }
        #endif
    }
}
