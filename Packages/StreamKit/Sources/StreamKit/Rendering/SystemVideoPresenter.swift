//
//  SystemVideoPresenter.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/30.
//

import AVFoundation
import CoreMedia
import CoreVideo
import os

public final class SystemVideoPresenter: @unchecked Sendable {
    public struct PacingCounters: Sendable {
        public var pacingDelayMs: Double
        public var lateFrames: Int
    }

    private struct State {
        var format: CMVideoFormatDescription?
        var pacer: FramePacer?
    }

    public let layer = AVSampleBufferDisplayLayer()

    private let videoRenderer: AVSampleBufferVideoRenderer
    private let lock = OSAllocatedUnfairLock<State>(initialState: State())
    private let log = Logger(category: .render)

    @MainActor
    init() {
        videoRenderer = layer.sampleBufferRenderer
        layer.videoGravity = .resizeAspect
        layer.backgroundColor = CGColor(gray: 0, alpha: 1)
        layer.controlTimebase = hostClockTimebase()
    }

    public func setPacing(_ mode: PacingMode) {
        lock.withLock { state in
            switch state.pacer {
            case nil: state.pacer = FramePacer(mode: mode)
            case .some: state.pacer?.setMode(mode)
            }
        }
    }

    public func takeCounters() -> PacingCounters {
        lock.withLock { state in
            PacingCounters(
                pacingDelayMs: (state.pacer?.delay ?? 0) * 1000,
                lateFrames: state.pacer?.takeLateFrames() ?? 0
            )
        }
    }

    func enqueue(_ pixelBuffer: CVPixelBuffer, timing: DecodedFrameTiming) -> CFTimeInterval {
        let presentAt = presentationTime(of: timing)
        guard let sample = sampleBuffer(for: pixelBuffer, presentAt: presentAt) else {
            return timing.arrival
        }

        flushIfFailed()

        videoRenderer.enqueue(sample)

        return presentAt
    }

    func clear() {
        videoRenderer.flush(removingDisplayedImage: true, completionHandler: nil)
    }
}

private extension SystemVideoPresenter {
    func hostClockTimebase() -> CMTimebase? {
        var timebase: CMTimebase?
        CMTimebaseCreateWithSourceClock(
            allocator: nil,
            sourceClock: CMClockGetHostTimeClock(),
            timebaseOut: &timebase
        )
        guard let timebase else { return nil }

        CMTimebaseSetTime(timebase, time: CMClockGetTime(CMClockGetHostTimeClock()))
        CMTimebaseSetRate(timebase, rate: 1)

        return timebase
    }

    func presentationTime(of timing: DecodedFrameTiming) -> CFTimeInterval {
        let paced = lock.withLock {
            $0.pacer?.presentationTime(arrival: timing.arrival, rtp: timing.rtpTimestamp)
        }
        return paced ?? timing.arrival
    }

    func sampleBuffer(for pixelBuffer: CVPixelBuffer, presentAt: Double) -> CMSampleBuffer? {
        guard let format = formatDescription(for: pixelBuffer) else { return nil }

        var timing = CMSampleTimingInfo(
            duration: .invalid,
            presentationTimeStamp: CMTime(seconds: presentAt, preferredTimescale: 1_000_000),
            decodeTimeStamp: .invalid
        )
        var sample: CMSampleBuffer?
        let status = CMSampleBufferCreateReadyWithImageBuffer(
            allocator: nil,
            imageBuffer: pixelBuffer,
            formatDescription: format,
            sampleTiming: &timing,
            sampleBufferOut: &sample
        )
        guard status == noErr else { return nil }

        return sample
    }

    func formatDescription(for pixelBuffer: CVPixelBuffer) -> CMVideoFormatDescription? {
        let cached = lock.withLock { $0.format }

        if let cached, CMVideoFormatDescriptionMatchesImageBuffer(cached, imageBuffer: pixelBuffer)
        {
            return cached
        }

        var created: CMVideoFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: nil,
            imageBuffer: pixelBuffer,
            formatDescriptionOut: &created
        )
        let fresh = created
        lock.withLock { $0.format = fresh }
        return created
    }

    func flushIfFailed() {
        guard videoRenderer.status == .failed else { return }

        log.error(
            "System video renderer failed: \(String(describing: self.videoRenderer.error), privacy: .public)"
        )
        videoRenderer.flush()
    }
}
