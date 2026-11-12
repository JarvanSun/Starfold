//
//  AudioDeviceDelegateStub.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import AVFAudio
import Foundation
@preconcurrency import LiveKitWebRTC
import Synchronization

final class AudioDeviceDelegateStub: NSObject, LKRTCAudioDeviceDelegate, @unchecked Sendable {
    let counter = PlayoutPullCounter()
    let outputParameterChanges = Atomic<Int>(0)

    private let queue = DispatchQueue(label: "test.stub-adm")
    private let queueKey = DispatchSpecificKey<Bool>()

    var preferredInputSampleRate: Double { 48_000 }

    var preferredInputIOBufferDuration: TimeInterval { 0.01 }

    var preferredOutputSampleRate: Double { 48_000 }

    var preferredOutputIOBufferDuration: TimeInterval { 0.01 }

    var deliverRecordedData: LKRTCAudioDeviceDeliverRecordedDataBlock {
        { _, _, _, _, _, _, _ in noErr }
    }

    var getPlayoutData: LKRTCAudioDeviceGetPlayoutDataBlock {
        { [counter] flags, _, _, frameCount, output in
            counter.pulls.wrappingAdd(1, ordering: .relaxed)
            counter.frames.wrappingAdd(Int(frameCount), ordering: .relaxed)
            counter.largestPull.max(Int(frameCount), ordering: .relaxed)

            for buffer in UnsafeMutableAudioBufferListPointer(output) {
                if let data = buffer.mData {
                    memset(data, 0, Int(buffer.mDataByteSize))
                }
            }

            flags.pointee.insert(.unitRenderAction_OutputIsSilence)

            return noErr
        }
    }

    override init() {
        super.init()

        queue.setSpecific(key: queueKey, value: true)
    }

    @discardableResult
    func onQueue<Result>(_ body: () -> Result) -> Result {
        guard DispatchQueue.getSpecific(key: queueKey) != true else { return body() }

        return queue.sync(execute: body)
    }

    func notifyAudioInputParametersChange() {}

    func notifyAudioOutputParametersChange() {
        outputParameterChanges.wrappingAdd(1, ordering: .relaxed)
    }

    func notifyAudioInputInterrupted() {}

    func notifyAudioOutputInterrupted() {}

    func dispatchAsync(_ block: @escaping () -> Void) {
        nonisolated(unsafe) let block = block
        queue.async { block() }
    }

    func dispatchSync(_ block: @escaping () -> Void) {
        onQueue { block() }
    }
}
