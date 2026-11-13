//
//  StereoAudioDevice.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/30.
//

#if !os(macOS)
import AVFAudio
import Foundation
@preconcurrency import LiveKitWebRTC
import os
import UIKit

final class StereoAudioDevice: NSObject, LKRTCAudioDevice, @unchecked Sendable {
    private let playout = StereoPlayout(meter: PlayoutMeter())
    private let log = Logger(category: .audio)
    private let lock = NSLock()

    private var delegate: LKRTCAudioDeviceDelegate?
    private var engine: AVAudioEngine?
    private var isPlayoutReady = false
    private var isPlayoutWanted = false
    private var observers: [NSObjectProtocol] = []
    private var meterTimer: DispatchSourceTimer?
    private var bypassesSpatialAudio = false

    var deviceInputSampleRate: Double { playout.sampleRate }

    var inputIOBufferDuration: TimeInterval { 0.01 }

    var inputNumberOfChannels: Int { 1 }

    var inputLatency: TimeInterval { 0 }

    var deviceOutputSampleRate: Double { playout.sampleRate }

    var outputIOBufferDuration: TimeInterval { 0.01 }

    var outputNumberOfChannels: Int { 2 }

    var outputLatency: TimeInterval { AVAudioSession.sharedInstance().outputLatency }

    var isInitialized: Bool { lock.withLock { delegate != nil } }

    var isPlayoutInitialized: Bool { lock.withLock { isPlayoutReady } }

    var isPlaying: Bool { lock.withLock { isPlayoutWanted } }

    var isRecordingInitialized: Bool { false }

    var isRecording: Bool { false }

    private var watchdogInterval: Int { 5 }

    func initialize(with delegate: LKRTCAudioDeviceDelegate) -> Bool {
        lock.withLock { self.delegate = delegate }

        observeSystemChanges()

        return true
    }

    private func observeSystemChanges() {
        let observers = [
            observe(.AVAudioEngineConfigurationChange) { [weak self] notification in
                self?.rebuildIfCurrent(notification.object as? AVAudioEngine)
            },
            observe(AVAudioSession.mediaServicesWereResetNotification) { [weak self] _ in
                self?.recover(.replace)
            },
            observe(AVAudioSession.interruptionNotification) { [weak self] notification in
                self?.handleInterruption(notification.userInfo)
            },
            observe(UIScene.didActivateNotification) { [weak self] _ in
                self?.recover(.resume("scene activated"))
            },
        ]
        let resumptions = resumptionObservers()
        lock.withLock { self.observers = observers + resumptions }
    }

    private func rebuildIfCurrent(_ engine: AVAudioEngine?) {
        guard let engine, lock.withLock({ engine === self.engine }) else { return }

        recover(.rebuild("configuration change"))
    }

    private func handleInterruption(_ userInfo: [AnyHashable: Any]?) {
        let type = (userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt)
            .flatMap(AVAudioSession.InterruptionType.init)
        let reason = (userInfo?[AVAudioSessionInterruptionReasonKey] as? UInt) ?? 0
        log.info(
            "Audio interruption \(type == .ended ? "ended" : "began", privacy: .public), reason \(reason)"
        )

        if type == .ended {
            recover(.resume("interruption ended"))
        }
    }

    private func recover(_ recovery: PlayoutRecovery) {
        guard let delegate = lock.withLock({ self.delegate }) else { return }

        delegate.dispatchAsync { [weak self] in
            self?.recoverOnAudioThread(recovery)
        }
    }

    private func recoverOnAudioThread(_ recovery: PlayoutRecovery) {
        let (isWanted, current) = lock.withLock { (isPlayoutWanted, engine) }
        guard isWanted else { return }

        let isResumed = resume(current, after: recovery)

        if !isResumed {
            rebuild(replacing: current, after: recovery)
        }
    }

    private func resumptionObservers() -> [NSObjectProtocol] {
        guard #available(iOS 27, tvOS 27, visionOS 27, *) else { return [] }

        let observer = observe(AVAudioSession.resumptionRecommendationNotification) {
            [weak self] _ in
            self?.recover(.resume("resumption recommended"))
        }
        return [observer]
    }

    private func observe(
        _ name: Notification.Name,
        using block: @escaping @Sendable (Notification) -> Void
    ) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: block)
    }

    func terminateDevice() -> Bool {
        stopPlayout()

        let observers = lock.withLock {
            defer {
                isPlayoutReady = false
                delegate = nil
                self.observers = []
            }
            return self.observers
        }

        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }

        return true
    }

    func initializePlayout() -> Bool {
        lock.withLock {
            isPlayoutReady = delegate != nil
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

        playout.meter.take()

        timer.resume()
    }

    private func checkPlayout() {
        let (pulls, frames, peak) = playout.meter.take()
        let (engine, isWanted) = lock.withLock { (self.engine, isPlayoutWanted) }
        log.info(
            "Playout \(self.watchdogInterval)s: \(pulls / self.watchdogInterval) pulls/s, \(frames / self.watchdogInterval) frames/s, peak \(peak) of \(Int16.max)"
        )

        guard isWanted, pulls == 0 else { return }

        let reason =
            switch (engine, engine?.isRunning ?? false) {
            case (nil, _): "no engine"
            case (_, true): "engine not pulling"
            case (_, false): "engine stopped"
            }
        recover(.rebuild(reason))
    }

    @discardableResult
    func stopPlayout() -> Bool {
        let engine = lock.withLock {
            defer {
                self.engine = nil
                isPlayoutWanted = false
            }
            return self.engine
        }

        if let engine {
            engine.stop()

            deactivateSession()
        }

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

    func setBypassesSpatialAudio(_ bypassesSpatialAudio: Bool) {
        let hasChanged = lock.withLock {
            defer { self.bypassesSpatialAudio = bypassesSpatialAudio }
            return self.bypassesSpatialAudio != bypassesSpatialAudio
        }

        if hasChanged {
            recover(.rebuild("sound stage change"))
        }
    }

    func initializeRecording() -> Bool { false }

    func startRecording() -> Bool { false }

    func stopRecording() -> Bool { true }

    fileprivate func resume(_ engine: AVAudioEngine?, after recovery: PlayoutRecovery) -> Bool {
        guard case .resume = recovery, let engine else { return false }
        guard !engine.isRunning else { return true }

        do {
            try AVAudioSession.sharedInstance().setActive(true)

            try engine.start()
            log.info("Audio resumed: \(recovery.description, privacy: .public)")

            return true
        } catch {
            log.info(
                "Audio restart failed, rebuilding: \(String(describing: error), privacy: .public)"
            )

            return false
        }
    }

    fileprivate func rebuild(replacing current: AVAudioEngine?, after recovery: PlayoutRecovery) {
        lock.withLock {
            if self.engine === current { self.engine = nil }
        }

        stopUnlessReplaced(current, recovery: recovery)

        switch startEngine() {
        case true:
            log.info("Audio engine rebuilt: \(recovery.description, privacy: .public)")
        case false:
            log.error(
                "Audio still unavailable after \(recovery.description, privacy: .public); will retry"
            )
        }
    }

    private func stopUnlessReplaced(_ engine: AVAudioEngine?, recovery: PlayoutRecovery) {
        switch recovery {
        case .replace: break
        case .resume, .rebuild: engine?.stop()
        }
    }

    @discardableResult
    private func startEngine() -> Bool {
        guard let delegate = lock.withLock({ self.delegate }) else { return false }

        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try? session.setPreferredSampleRate(playout.sampleRate)
            try? session.setPreferredIOBufferDuration(preferredIOBufferDuration)
            try session.setActive(true)
        } catch {
            log.error(
                "Audio session activation failed: \(String(describing: error), privacy: .public)"
            )

            return false
        }

        guard let engine = makeEngine(pulling: delegate.getPlayoutData) else { return false }

        let previous = lock.withLock {
            defer { self.engine = engine }
            return self.engine
        }
        previous?.stop()

        do {
            try engine.start()
        } catch {
            log.error("Audio engine start failed: \(String(describing: error), privacy: .public)")

            lock.withLock {
                if self.engine === engine { self.engine = nil }
            }

            deactivateSession()

            return false
        }

        log.info(
            "Stereo playout at \(session.sampleRate) Hz, \(session.outputNumberOfChannels) output channels, IO buffer \(session.ioBufferDuration * 1000) ms, output latency \(session.outputLatency * 1000) ms, spatial \(self.spatialExperience(of: engine), privacy: .public)"
        )

        return true
    }

    private var preferredIOBufferDuration: TimeInterval { 0.005 }

    private func makeEngine(pulling pull: @escaping LKRTCAudioDeviceGetPlayoutDataBlock)
        -> AVAudioEngine?
    {
        guard let (source, stereo) = playout.makeSource(pulling: pull) else { return nil }

        let engine = AVAudioEngine()
        bypassSpatialAudioIfChosen(on: engine)

        engine.attach(source)
        engine.connect(source, to: engine.mainMixerNode, format: stereo)
        engine.connect(engine.mainMixerNode, to: engine.outputNode, format: nil)
        engine.prepare()
        return engine
    }

    private func bypassSpatialAudioIfChosen(on engine: AVAudioEngine) {
        #if os(visionOS)
        if lock.withLock({ bypassesSpatialAudio }) {
            engine.outputNode.intendedSpatialExperience = .bypassed
        }
        #endif
    }

    private func deactivateSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(
                false,
                options: .notifyOthersOnDeactivation
            )
        } catch {
            log.error(
                "Audio session deactivation failed: \(String(describing: error), privacy: .public)"
            )
        }
    }

    private func spatialExperience(of engine: AVAudioEngine) -> String {
        #if os(visionOS)
        String(describing: engine.outputNode.intendedSpatialExperience)
        #else
        "n/a"
        #endif
    }
}

private enum PlayoutRecovery: CustomStringConvertible {
    case resume(String)
    case rebuild(String)
    case replace

    var description: String {
        switch self {
        case .resume(let reason): reason
        case .rebuild(let reason): reason
        case .replace: "media services reset"
        }
    }
}
#endif
