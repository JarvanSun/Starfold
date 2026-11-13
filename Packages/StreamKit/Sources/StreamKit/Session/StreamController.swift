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
    private let client: GSSVClient
    private let target: StreamTarget
    private let options: StreamOptions
    private let transferToken: @Sendable () async throws -> String
    private let input: InputState
    private let sender: InputSender
    private let clockOrigin: CFTimeInterval
    private let log = Logger(category: .stream)

    private var session: GSSVSession?
    private var peer: PeerConnection?
    private var channels: HostChannels
    private var phase: StreamPhase = .provisioning
    private var tasks: [Task<Void, Never>] = []
    private var eventTask: Task<Void, Never>?
    private var gathering = CandidateGathering()
    private var connectedContinuation: CheckedContinuation<Void, Error>?
    private var isConnected = false
    private var keepAliveInterval: Duration = .seconds(20)
    private var statisticsCollector = StatisticsCollector()
    private var startedAt = ContinuousClock.now

    public init(
        client: GSSVClient,
        target: StreamTarget,
        options: StreamOptions,
        transferToken: @escaping @Sendable () async throws -> String
    ) {
        self.client = client
        self.target = target
        self.options = options
        self.transferToken = transferToken
        channels = HostChannels(options: options)

        (updates, updateContinuation) = AsyncStream.makeStream(
            bufferingPolicy: .bufferingNewest(64)
        )

        let origin = CACurrentMediaTime()
        let input = InputState()
        clockOrigin = origin
        self.input = input
        sender = InputSender(state: input, clockOrigin: origin)
    }

    public func start(sink: VideoFrameReceiving, runtime: StreamRuntime) async {
        startedAt = .now

        do {
            let peer = try makePeer(sink: sink, runtime: runtime)
            async let offer = peer.createOffer(videoBitrateKbps: options.maxBitrateKbps)

            try await provision()

            try await connect(peer: peer, offer: try await offer)

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

    private func makePeer(sink: VideoFrameReceiving, runtime: StreamRuntime) throws
        -> PeerConnection
    {
        let (events, continuation) = AsyncStream<PeerEvent>.makeStream()
        guard
            let peer = PeerConnection(
                runtime: runtime,
                stunServers: options.stunServers,
                events: { continuation.yield($0) }
            )
        else { throw StreamError.webRTC("Could not create the peer connection") }

        self.peer = peer
        peer.frameReceiver.setSink(sink)

        let input = input
        let origin = clockOrigin
        peer.frameReceiver.setFrameTimingHandler { timing in
            input.recordFrame(
                rtpTimestamp: timing.rtpTimestamp,
                at: (timing.arrival - origin) * 1000
            )
        }

        eventTask = Task { [weak self] in
            for await event in events {
                await self?.handle(event)
            }
        }

        return peer
    }

    private func handle(_ event: PeerEvent) async {
        switch event {
        case .localCandidate(let candidate):
            gathering.add(candidate, at: .now)
        case .gatheringComplete:
            gathering.complete()
        case .connectionState(let state):
            await handleConnectionState(state)
        case .channelOpen(let label):
            await perform(channels.opened(label))
        case .channelMessage(let label, let data):
            await perform(channels.received(data, on: label, timestamp: currentTimestamp))
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
            case .send(let data, let label): peer?.send(data, on: label)
            case .update(let update): updateContinuation.yield(update)
            case .announceGamepad: scheduleGamepadAnnouncement()
            case .end(let reason): await stop(reason: reason)
            case .trace(let text): log.debug("\(text)")
            }
        }
    }

    private func scheduleGamepadAnnouncement() {
        let delay = gamepadAnnouncementDelay

        tasks.append(
            Task { [weak self] in
                try? await Task.sleep(for: delay)

                await self?.announceFirstGamepad()
            }
        )
    }

    private var gamepadAnnouncementDelay: Duration { .milliseconds(500) }

    private func announceFirstGamepad() {
        guard let peer else { return }

        peer.send(ControlMessage.gamepadChanged(index: 0, isAdded: true).json, on: .control)
        sender.start(peer: peer, announced: [0])
    }

    private var currentTimestamp: Double {
        (CACurrentMediaTime() - clockOrigin) * 1000
    }

    private func mark(_ stage: StaticString) {
        let milliseconds = Int((ContinuousClock.now - startedAt) / .milliseconds(1))
        log.info("Startup \(stage) +\(milliseconds) ms")
    }

    private func provision() async throws {
        setPhase(.provisioning)

        let session =
            switch target {
            case .console(let id, _):
                try await client.startSession(
                    consoleID: id,
                    quality: options.quality,
                    locale: options.gameLocale
                )
            case .cloud(let titleID, _):
                try await client.startSession(
                    titleID: titleID,
                    quality: options.quality,
                    locale: options.gameLocale
                )
            }
        self.session = session
        mark("session created")

        let timeout =
            switch target {
            case .console: consoleProvisioningTimeout
            case .cloud: cloudProvisioningTimeout
            }
        try await session.waitUntilProvisioned(transferToken: transferToken, timeout: timeout) {
            [weak self] wait in
            await self?.setPhase(.queued(estimatedWait: wait))
        }
    }

    private var consoleProvisioningTimeout: Duration { .seconds(90) }

    private var cloudProvisioningTimeout: Duration { .seconds(15 * 60) }

    private func connect(peer: PeerConnection, offer: String) async throws {
        guard let session else { return }

        mark("provisioned")

        setPhase(.connecting)

        async let configuredKeepAlive: Duration? = try? await session.keepAliveInterval()
        let answer = try await session.exchangeSDP(offer: offer)
        mark("SDP answered")
        log.info(
            "Negotiated channels chat \(answer.versions.chat) control \(answer.versions.control) input \(answer.versions.input) message \(answer.versions.message)"
        )

        try await peer.setAnswer(answer.sdp)

        try await waitForLocalCandidates()

        let remote = try await session.exchangeICE(gathering.candidates)
        mark("ICE answered")
        log.info("Host sent \(remote.count) candidates")

        for candidate in remote {
            await peer.addRemoteCandidate(candidate)
        }

        try await waitUntilConnected(timeout: connectionTimeout)
        mark("connected")

        keepAliveInterval = await configuredKeepAlive ?? keepAliveInterval
    }

    private func setPhase(_ phase: StreamPhase) {
        guard self.phase != phase else { return }

        self.phase = phase

        updateContinuation.yield(.phase(phase))
    }

    private func waitForLocalCandidates() async throws {
        let deadline = ContinuousClock.now + gatheringTimeout

        while ContinuousClock.now < deadline,
            !gathering.isSettled(at: .now, quietPeriod: gatheringQuietPeriod)
        {
            try await Task.sleep(for: gatheringPollInterval)
        }

        log.info(
            "Gathered \(self.gathering.candidates.count) local candidates (complete: \(self.gathering.isComplete))"
        )
    }

    private var gatheringTimeout: Duration { .seconds(3) }

    private var gatheringQuietPeriod: Duration { .milliseconds(300) }

    private var gatheringPollInterval: Duration { .milliseconds(50) }

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

    private var connectionTimeout: Duration { .seconds(20) }

    private func startKeepAlive() {
        guard let session else { return }

        let interval = keepAliveInterval
        tasks.append(
            Task { [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(for: interval)

                    guard !Task.isCancelled else { return }

                    do {
                        try await session.keepAlive()
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
        let interval = statisticsInterval
        tasks.append(
            Task { [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(for: interval)

                    await self?.publishStatistics()
                }
            }
        )
    }

    private var statisticsInterval: Duration { .seconds(1) }

    private func publishStatistics() async {
        guard let peer else { return }

        let statistics = statisticsCollector.collect(await peer.statistics())
        updateContinuation.yield(.statistics(statistics))
    }

    public func stop(reason: StreamEndReason) async {
        if case .ended = phase { return }

        setPhase(.ended(reason))

        for task in tasks {
            task.cancel()
        }

        tasks.removeAll()

        resolveConnection(.failure(CancellationError()))

        removeAnnouncedPads(sender.stop())

        peer?.frameReceiver.setSink(nil)
        peer?.frameReceiver.setFrameTimingHandler(nil)
        peer?.close()
        peer = nil

        eventTask?.cancel()
        eventTask = nil

        await session?.stop()
        session = nil

        updateContinuation.finish()
    }

    private func removeAnnouncedPads(_ announcedPads: Set<UInt8>) {
        guard let peer else { return }

        for index in announcedPads.sorted() {
            peer.send(
                ControlMessage.gamepadChanged(index: Int(index), isAdded: false).json,
                on: .control
            )
        }
    }

    public nonisolated func setGamepad(_ index: UInt8, state: GamepadState?) {
        input.setGamepad(index, state: state)
    }

    public func pressGuide() {
        input.pulse(.nexus, on: 0, duration: guideTapDuration)
    }

    private var guideTapDuration: TimeInterval { 0.12 }

    public func requestKeyframe() {
        peer?.send(ControlMessage.keyframeRequest.json, on: .control)
    }

    public func answerDialog(id: String, buttonIndex: Int) async {
        await perform([channels.answerDialog(id: id, buttonIndex: buttonIndex)])
    }

    public func answerKeyboard(id: String, text: String?) async {
        await perform([channels.answerKeyboard(id: id, text: text)])
    }
}
