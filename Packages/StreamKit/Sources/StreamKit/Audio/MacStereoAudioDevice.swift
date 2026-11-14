//
//  MacStereoAudioDevice.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/30.
//

#if os(macOS)
import AudioToolbox
import AVFAudio
import CoreAudio
import Foundation
@preconcurrency import LiveKitWebRTC
import os

final class MacStereoAudioDevice: NSObject, LKRTCAudioDevice, @unchecked Sendable {
    let stereoPlayout = StereoPlayout(meter: PlayoutMeter())

    private let log = Logger(category: .audio)
    private let lock = NSLock()

    private var deviceDelegate: LKRTCAudioDeviceDelegate?
    private var audioEngine: AVAudioEngine?
    private var isPlayoutReady = false
    private var isPlayoutWanted = false
    private var grantedIOBufferDuration: TimeInterval?
    private var observer: NSObjectProtocol?
    private var meterTimer: DispatchSourceTimer?

    var deviceInputSampleRate: Double { stereoPlayout.sampleRate }

    var inputIOBufferDuration: TimeInterval { 0.01 }

    var inputNumberOfChannels: Int { 1 }

    var inputLatency: TimeInterval { 0 }

    var deviceOutputSampleRate: Double { stereoPlayout.sampleRate }

    var outputIOBufferDuration: TimeInterval {
        lock.withLock { grantedIOBufferDuration ?? preferredIOBufferDuration }
    }

    var outputNumberOfChannels: Int { 2 }

    var outputLatency: TimeInterval {
        lock.withLock {
            (audioEngine?.outputNode.presentationLatency ?? 0)
                + (grantedIOBufferDuration ?? preferredIOBufferDuration)
        }
    }

    var isInitialized: Bool { lock.withLock { deviceDelegate != nil } }

    var isPlayoutInitialized: Bool { lock.withLock { isPlayoutReady } }

    var isPlaying: Bool { lock.withLock { isPlayoutWanted } }

    var isRecordingInitialized: Bool { false }

    var isRecording: Bool { false }

    private var preferredIOBufferDuration: TimeInterval { 0.005 }

    private var watchdogInterval: Int { 5 }

    func initialize(with deviceDelegate: LKRTCAudioDeviceDelegate) -> Bool {
        lock.withLock { self.deviceDelegate = deviceDelegate }

        observeConfigurationChanges()

        return true
    }

    private func observeConfigurationChanges() {
        let observer = NotificationCenter.default.addObserver(
            forName: .AVAudioEngineConfigurationChange,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            self?.rebuildIfCurrent(notification.object as? AVAudioEngine)
        }
        let previous = lock.withLock {
            defer { self.observer = observer }
            return self.observer
        }

        if let previous {
            NotificationCenter.default.removeObserver(previous)
        }
    }

    private func rebuildIfCurrent(_ audioEngine: AVAudioEngine?) {
        guard let audioEngine, lock.withLock({ audioEngine === self.audioEngine }) else { return }

        rebuild("configuration change")
    }

    private func rebuild(_ reason: String) {
        guard let deviceDelegate = lock.withLock({ self.deviceDelegate }) else { return }

        deviceDelegate.dispatchAsync { [weak self] in
            self?.rebuildOnAudioThread(reason)
        }
    }

    private func rebuildOnAudioThread(_ reason: String) {
        let (isWanted, current) = lock.withLock { (isPlayoutWanted, audioEngine) }
        guard isWanted else { return }

        lock.withLock {
            if self.audioEngine === current { self.audioEngine = nil }
        }
        current?.stop()

        switch startEngine() {
        case true: log.info("Audio engine rebuilt: \(reason, privacy: .public)")
        case false:
            log.error("Audio still unavailable after \(reason, privacy: .public); will retry")
        }
    }

    @discardableResult
    private func startEngine() -> Bool {
        guard let deviceDelegate = lock.withLock({ self.deviceDelegate }),
            let audioEngine = makeEngine(pulling: deviceDelegate.getPlayoutData)
        else { return false }

        let ioBuffer = applyIOBuffer(to: audioEngine)
        let previous = lock.withLock {
            defer {
                self.audioEngine = audioEngine

                if let ioBuffer { grantedIOBufferDuration = ioBuffer }
            }
            return self.audioEngine
        }
        previous?.stop()

        deviceDelegate.dispatchSync { deviceDelegate.notifyAudioOutputParametersChange() }

        do {
            try audioEngine.start()
        } catch {
            log.error("Audio engine start failed: \(String(describing: error), privacy: .public)")

            lock.withLock {
                if self.audioEngine === audioEngine { self.audioEngine = nil }
            }

            return false
        }

        let hardware = audioEngine.outputNode.outputFormat(forBus: 0)
        log.info(
            "Stereo playout at \(hardware.sampleRate) Hz, \(hardware.channelCount) output channels, IO buffer \(self.outputIOBufferDuration * 1000) ms, output latency \(self.outputLatency * 1000) ms"
        )

        return true
    }

    private func makeEngine(pulling pull: @escaping LKRTCAudioDeviceGetPlayoutDataBlock)
        -> AVAudioEngine?
    {
        guard let (source, stereo) = stereoPlayout.makeSource(pulling: pull) else { return nil }

        let audioEngine = AVAudioEngine()
        audioEngine.attach(source)
        audioEngine.connect(source, to: audioEngine.mainMixerNode, format: stereo)
        audioEngine.connect(audioEngine.mainMixerNode, to: audioEngine.outputNode, format: nil)
        audioEngine.prepare()
        return audioEngine
    }

    private func applyIOBuffer(to audioEngine: AVAudioEngine) -> TimeInterval? {
        guard let unit = audioEngine.outputNode.audioUnit else { return nil }

        let rate = audioEngine.outputNode.outputFormat(forBus: 0).sampleRate
        guard rate > 0 else { return nil }

        var requested = UInt32((rate * preferredIOBufferDuration).rounded())
        let size = UInt32(MemoryLayout<UInt32>.size)
        let setStatus = AudioUnitSetProperty(
            unit,
            kAudioDevicePropertyBufferFrameSize,
            kAudioUnitScope_Global,
            0,
            &requested,
            size
        )

        var granted: UInt32 = 0
        var grantedSize = size
        let getStatus = AudioUnitGetProperty(
            unit,
            kAudioDevicePropertyBufferFrameSize,
            kAudioUnitScope_Global,
            0,
            &granted,
            &grantedSize
        )
        guard getStatus == noErr, granted > 0 else {
            log.error("Audio IO buffer unknown: set \(setStatus), get \(getStatus)")

            return nil
        }

        log.info(
            "Audio IO buffer: asked \(requested) frames, granted \(granted) at \(rate) Hz (set status \(setStatus))"
        )

        return Double(granted) / rate
    }

    func terminateDevice() -> Bool {
        stopPlayout()

        let observer = lock.withLock {
            defer {
                isPlayoutReady = false
                deviceDelegate = nil
                self.observer = nil
            }
            return self.observer
        }

        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }

        return true
    }

    func initializePlayout() -> Bool {
        lock.withLock {
            isPlayoutReady = deviceDelegate != nil
            return isPlayoutReady
        }
    }

    func startPlayout() -> Bool {
        lock.withLock { isPlayoutWanted = true }

        startWatchdog()

        startEngine()

        return true
    }

    private func startWatchdog() {
        let timer = DispatchSource.makeTimerSource(queue: .global(qos: .utility))
        timer.schedule(
            deadline: .now() + .seconds(watchdogInterval),
            repeating: .seconds(watchdogInterval)
        )
        timer.setEventHandler { [weak self] in
            self?.checkPlayout()
        }
        let previous = lock.withLock {
            defer { meterTimer = timer }
            return meterTimer
        }
        previous?.cancel()

        stereoPlayout.meter.take()

        timer.resume()
    }

    private func checkPlayout() {
        let (pulls, frames, peak) = stereoPlayout.meter.take()
        let (audioEngine, isWanted) = lock.withLock { (self.audioEngine, isPlayoutWanted) }
        log.info(
            "Playout \(self.watchdogInterval)s: \(pulls / self.watchdogInterval) pulls/s, \(frames / self.watchdogInterval) frames/s, peak \(peak) of \(Int16.max)"
        )

        guard isWanted, pulls == 0 else { return }

        let reason =
            switch (audioEngine, audioEngine?.isRunning ?? false) {
            case (nil, _): "no engine"
            case (_, true): "engine not pulling"
            case (_, false): "engine stopped"
            }
        rebuild(reason)
    }

    @discardableResult
    func stopPlayout() -> Bool {
        let audioEngine = lock.withLock {
            defer {
                self.audioEngine = nil
                isPlayoutWanted = false
            }
            return self.audioEngine
        }
        audioEngine?.stop()

        stopWatchdog()

        return true
    }

    private func stopWatchdog() {
        let timer = lock.withLock {
            defer { meterTimer = nil }
            return meterTimer
        }
        timer?.cancel()
    }

    func initializeRecording() -> Bool { false }

    func startRecording() -> Bool { false }

    func stopRecording() -> Bool { true }
}
#endif
