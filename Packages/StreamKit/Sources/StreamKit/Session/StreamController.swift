//
//  StreamController.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation
import QuartzCore
import XboxKit
import os

public actor StreamController {
    public nonisolated let updates: AsyncStream<StreamUpdate>

    private let updateContinuation: AsyncStream<StreamUpdate>.Continuation
    private let gssvClient: GSSVClient
    private let target: StreamTarget
    private let options: StreamOptions
    private let transferToken: @Sendable () async throws -> String
    private let inputState: InputState
    private let inputSender: InputSender
    private let clockOrigin: CFTimeInterval
    private let log = Logger(category: .stream)

    private var gssvSession: GSSVSession?
    private var peerConnection: PeerConnection?
    private var hostChannels: HostChannels
    private var phase: StreamPhase = .provisioning
    private var periodicTasks: [Task<Void, Never>] = []
    private var eventTask: Task<Void, Never>?
    private var candidateGathering = CandidateGathering()
    private var connectedContinuation: CheckedContinuation<Void, Error>?
    private var isConnected = false
    private var keepAliveInterval: Duration = .seconds(20)
    private var statisticsCollector = StatisticsCollector()
    private var startedAt = ContinuousClock.now

    public init(
        gssvClient: GSSVClient,
        target: StreamTarget,
        options: StreamOptions,
        transferToken: @escaping @Sendable () async throws -> String
    ) {
        self.gssvClient = gssvClient
        self.target = target
        self.options = options
        self.transferToken = transferToken
        hostChannels = HostChannels(options: options)

        (updates, updateContinuation) = AsyncStream.makeStream(
            bufferingPolicy: .bufferingNewest(64)
        )

        let origin = CACurrentMediaTime()
        let inputState = InputState()
        clockOrigin = origin
        self.inputState = inputState
        inputSender = InputSender(inputState: inputState, clockOrigin: origin)
    }

    public func start(sink: VideoFrameReceiving, runtime: StreamRuntime) async {
        startedAt = .now

        do {
            let peerConnection = try makePeerConnection(sink: sink, runtime: runtime)
            async let offer = peerConnection.createOffer(videoBitrateKbps: options.maxBitrateKbps)

            try await provision()

            try await connect(peerConnection: peerConnection, offer: try await offer)

            setPhase(.streaming)

            startKeepAlive()

            startStatisticsLoop()
        } catch is CancellationError {
            await stop(reason: .userStopped)
        } catch {
            log.error("Stream failed: \(String(describing: error))")

            await stop(reason: .init(failure: error))
        }
    }

    private func makePeerConnection(sink: VideoFrameReceiving, runtime: StreamRuntime) throws
        -> PeerConnection
    {
        let (events, continuation) = AsyncStream<PeerEvent>.makeStream()
        guard
            let peerConnection = PeerConnection(
                runtime: runtime,
                stunServers: options.stunServers,
                events: { continuation.yield($0) }
            )
        else { throw StreamError.webRTC("Could not create the peer connection") }

        self.peerConnection = peerConnection
        peerConnection.frameReceiver.setSink(sink)

        let inputState = inputState
        let origin = clockOrigin
        peerConnection.frameReceiver.setFrameTimingHandler { timing in
            inputState.recordFrame(
                rtpTimestamp: timing.rtpTimestamp,
                at: (timing.arrival - origin) * 1000
            )
        }

        eventTask = Task { [weak self] in
            for await event in events {
                await self?.respond(to: event)
            }
        }

        return peerConnection
    }

    private func respond(to event: PeerEvent) async {
        switch event {
        case .localCandidate(let candidate):
            candidateGathering.add(candidate, at: .now)
        case .gatheringComplete:
            candidateGathering.complete()
        case .connectionState(let state):
            await handleConnectionState(state)
        case .channelOpen(let label):
            await perform(hostChannels.opened(label))
        case .channelMessage(let label, let data):
            await perform(hostChannels.received(data, on: label, timestamp: currentTimestamp))
        case .channelClosed(let label):
            log.info("Channel \(label.rawValue) closed")
        case .mediaTracksReady:
            mark("media tracks ready")
            requestKeyframe()
        }
    }

    private func handleConnectionState(_ state: PeerConnectionState) async {
        log.info("Peer connection \(state.rawValue)")

        switch state {
        case .connected:
            isConnected = true
            resolveConnection(.success(()))
        case .failed:
            resolveConnection(.failure(StreamError.webRTC("ICE failed")))

            if case .streaming = phase {
                await stop(reason: .connectionLost)
            }
        case .closed, .disconnected, .new, .connecting:
            break
        }
    }

    private func resolveConnection(_ result: Result<Void, Error>) {
        connectedContinuation?.resume(with: result)
        connectedContinuation = nil
    }

    private func perform(_ actions: [HostChannelAction]) async {
        for action in actions {
            switch action {
            case .send(let data, let label): peerConnection?.send(data, on: label)
            case .update(let update): updateContinuation.yield(update)
            case .announceGamepad: scheduleGamepadAnnouncement()
            case .end(let reason): await stop(reason: reason)
            case .trace(let text): log.debug("\(text)")
            }
        }
    }

    private func scheduleGamepadAnnouncement() {
        let gamepadAnnouncementDelay: Duration = .milliseconds(500)

        periodicTasks.append(
            Task { [weak self] in
                try? await Task.sleep(for: gamepadAnnouncementDelay)

                await self?.announceFirstGamepad()
            }
        )
    }

    private func announceFirstGamepad() {
        guard let peerConnection else { return }

        peerConnection.send(
            ControlMessage.gamepadChanged(index: 0, isAdded: true).json,
            on: .control
        )
        inputSender.start(peerConnection: peerConnection, announcedPads: [0])
    }

    private func mark(_ stage: StaticString) {
        let milliseconds = Int((ContinuousClock.now - startedAt) / .milliseconds(1))
        log.info("Startup \(stage) +\(milliseconds) ms")
    }

    private func provision() async throws {
        setPhase(.provisioning)

        let gssvSession =
            switch target {
            case .console(let id, _):
                try await gssvClient.startSession(
                    consoleID: id,
                    quality: options.quality,
                    locale: options.gameLocale
                )
            case .cloud(let titleID, _):
                try await gssvClient.startSession(
                    titleID: titleID,
                    quality: options.quality,
                    locale: options.gameLocale
                )
            }
        self.gssvSession = gssvSession
        mark("session created")

        let consoleProvisioningTimeout: Duration = .seconds(90)
        let cloudProvisioningTimeout: Duration = .seconds(15 * 60)
        let timeout =
            switch target {
            case .console: consoleProvisioningTimeout
            case .cloud: cloudProvisioningTimeout
            }
        try await gssvSession.waitUntilProvisioned(transferToken: transferToken, timeout: timeout) {
            [weak self] wait in
            await self?.setPhase(.queued(estimatedWait: wait))
        }
    }

    private func setPhase(_ phase: StreamPhase) {
        guard self.phase != phase else { return }

        self.phase = phase

        updateContinuation.yield(.phase(phase))
    }

    private func connect(peerConnection: PeerConnection, offer: String) async throws {
        guard let gssvSession else { return }

        mark("provisioned")

        setPhase(.connecting)

        async let configuredKeepAlive: Duration? = try? await gssvSession.keepAliveInterval()
        let answer = try await gssvSession.exchangeSDP(offer: offer)
        mark("SDP answered")
        log.info(
            "Negotiated channels chat \(answer.versions.chat) control \(answer.versions.control) input \(answer.versions.input) message \(answer.versions.message)"
        )

        try await peerConnection.setAnswer(answer.sdp)

        try await waitForLocalCandidates()

        let remote = try await gssvSession.exchangeICE(candidateGathering.candidates)
        mark("ICE answered")
        log.info("Host sent \(remote.count) candidates")

        for candidate in remote {
            await peerConnection.addRemoteCandidate(candidate)
        }

        let connectionTimeout: Duration = .seconds(20)

        try await waitUntilConnected(timeout: connectionTimeout)
        mark("connected")

        keepAliveInterval = await configuredKeepAlive ?? keepAliveInterval
    }

    private func waitForLocalCandidates() async throws {
        let gatheringTimeout: Duration = .seconds(3)
        let gatheringQuietPeriod: Duration = .milliseconds(300)
        let gatheringPollInterval: Duration = .milliseconds(50)
        let deadline = ContinuousClock.now + gatheringTimeout

        while ContinuousClock.now < deadline,
            !candidateGathering.isSettled(at: .now, quietPeriod: gatheringQuietPeriod)
        {
            try await Task.sleep(for: gatheringPollInterval)
        }

        log.info(
            "Gathered \(self.candidateGathering.candidates.count) local candidates (complete: \(self.candidateGathering.isComplete))"
        )
    }

    private func waitUntilConnected(timeout: Duration) async throws {
        guard !isConnected else { return }

        try Task.checkCancellation()

        let timer = Task { [weak self] in
            try await Task.sleep(for: timeout)
            await self?.resolveConnection(.failure(StreamError.connectionTimedOut))
        }
        defer { timer.cancel() }

        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                connectedContinuation = continuation
            }
        } onCancel: {
            Task { await self.resolveConnection(.failure(CancellationError())) }
        }
    }

    private func startKeepAlive() {
        guard let gssvSession else { return }

        let interval = keepAliveInterval
        periodicTasks.append(
            Task { [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(for: interval)

                    guard !Task.isCancelled else { return }

                    do {
                        try await gssvSession.keepAlive()
                    } catch let error as XboxHTTPError where error.isSessionGone {
                        await self?.stop(reason: .hostEnded)

                        return
                    } catch {
                        continue
                    }
                }
            }
        )
    }

    private func startStatisticsLoop() {
        let statisticsInterval: Duration = .seconds(1)

        periodicTasks.append(
            Task { [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(for: statisticsInterval)

                    await self?.publishStatistics()
                }
            }
        )
    }

    private func publishStatistics() async {
        guard let peerConnection else { return }

        let statistics = statisticsCollector.collect(await peerConnection.statistics())
        updateContinuation.yield(.statistics(statistics))
    }

    private var currentTimestamp: Double {
        (CACurrentMediaTime() - clockOrigin) * 1000
    }

    public func stop(reason: StreamEndReason) async {
        if case .ended = phase { return }

        setPhase(.ended(reason))

        for task in periodicTasks {
            task.cancel()
        }

        periodicTasks.removeAll()

        resolveConnection(.failure(CancellationError()))

        removeAnnouncedPads(inputSender.stop())

        peerConnection?.frameReceiver.setSink(nil)
        peerConnection?.frameReceiver.setFrameTimingHandler(nil)
        peerConnection?.close()
        peerConnection = nil

        eventTask?.cancel()
        eventTask = nil

        await gssvSession?.stop()
        gssvSession = nil

        updateContinuation.finish()
    }

    private func removeAnnouncedPads(_ announcedPads: Set<UInt8>) {
        guard let peerConnection else { return }

        for index in announcedPads.sorted() {
            peerConnection.send(
                ControlMessage.gamepadChanged(index: Int(index), isAdded: false).json,
                on: .control
            )
        }
    }

    public nonisolated func setGamepad(_ index: UInt8, state: GamepadState?) {
        inputState.setGamepad(index, state: state)
    }

    public func pressGuide() {
        let guideTapDuration: TimeInterval = 0.12

        inputState.pulse(.nexus, on: 0, duration: guideTapDuration)
    }

    public func requestKeyframe() {
        peerConnection?.send(ControlMessage.keyframeRequest.json, on: .control)
    }

    public func answerDialog(id: String, buttonIndex: Int) async {
        await perform([hostChannels.answerDialog(id: id, buttonIndex: buttonIndex)])
    }

    public func answerKeyboard(id: String, text: String?) async {
        await perform([hostChannels.answerKeyboard(id: id, text: text)])
    }

    public func announceTouchBundle(version: String, versionName: String) async {
        await perform([hostChannels.announceTouchBundle(version: version, versionName: versionName)]
        )
    }
}
