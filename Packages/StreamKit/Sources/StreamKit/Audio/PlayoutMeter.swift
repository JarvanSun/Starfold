//
//  PlayoutMeter.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AVFAudio
import Synchronization

final class PlayoutMeter: Sendable {
    private let pulls = Atomic<Int>(0)
    private let frames = Atomic<Int>(0)
    private let peak = Atomic<Int>(0)

    func record(_ output: UnsafeMutablePointer<AudioBufferList>, frames count: Int) {
        pulls.wrappingAdd(1, ordering: .relaxed)

        frames.wrappingAdd(count, ordering: .relaxed)

        var loudest = 0

        for buffer in UnsafeMutableAudioBufferListPointer(output) {
            guard let samples = buffer.mData?.assumingMemoryBound(to: Int16.self) else { continue }

            for index in 0..<Int(buffer.mDataByteSize) / MemoryLayout<Int16>.size {
                loudest = max(loudest, Int(samples[index].magnitude))
            }
        }

        peak.max(loudest, ordering: .relaxed)
    }

    @discardableResult
    func take() -> (pulls: Int, frames: Int, peak: Int) {
        (
            pulls.exchange(0, ordering: .relaxed),
            frames.exchange(0, ordering: .relaxed),
            peak.exchange(0, ordering: .relaxed)
        )
    }
}
