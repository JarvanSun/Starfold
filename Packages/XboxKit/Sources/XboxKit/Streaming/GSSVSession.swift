//
//  GSSVSession.swift
//  XboxKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation

#if os(tvOS)
import os
#endif

public struct GSSVSession: Sendable {
    let gssvClient: GSSVClient
    let url: URL
    let titleID: String?

    private var backoff: PollingBackoff {
        .init()
    }

    public func waitUntilProvisioned(
        transferToken: @Sendable () async throws -> String,
        pollInterval: Duration? = nil,
        timeout: Duration = .seconds(15 * 60),
        onQueued: @Sendable (Duration?) async -> Void = { _ in }
    ) async throws {
        var hasSentTransferToken = false
        var hasReportedQueue = false
        let clock = ContinuousClock()
        let start = clock.now
        let deadline = start + timeout

        while clock.now < deadline {
            try Task.checkCancellation()

            switch try await state() {
            case .provisioned: return
            case .readyToConnect where !hasSentTransferToken:
                try await connect(userToken: try await transferToken())

                hasSentTransferToken = true
            case .waitingForResources where !hasReportedQueue:
                hasReportedQueue = true

                await onQueued(await estimatedQueueWait())
            case .failed(let code, let message):
                throw GSSVSessionError.failed(code: code, message: message)
            case .provisioning, .readyToConnect, .waitingForResources, .other: break
            }

            try await Task.sleep(for: pollInterval ?? backoff.delay(after: clock.now - start))
        }

        throw GSSVSessionError.timedOut("state")
    }

    private func state() async throws -> SessionState {
        let response = try await gssvClient.send(to: url.appending(path: "state"))
        let fields =
            (try JSONSerialization.jsonObject(with: response.body) as? [String: Any]) ?? [:]
        return .init(fields: fields)
    }

    private func connect(userToken: String) async throws {
        _ = try await gssvClient.send(
            to: url.appending(path: "connect"),
            method: "POST",
            body: try JSONSerialization.data(withJSONObject: ["userToken": userToken])
        )
    }

    private func estimatedQueueWait() async -> Duration? {
        guard let titleID else {
            return nil
        }

        return try? await gssvClient.estimatedWait(titleID: titleID)
    }

    public func keepAliveInterval() async throws -> Duration {
        let response = try await gssvClient.send(to: url.appending(path: "configuration"))
        let configuration =
            (try JSONSerialization.jsonObject(with: response.body) as? [String: Any]) ?? [:]

        let defaultKeepAlivePulse = 20
        let pulse =
            (configuration["keepAlivePulseInSeconds"] as? NSNumber)?.intValue
            ?? defaultKeepAlivePulse

        let shortestKeepAlivePulse = 5
        let longestKeepAlivePulse = 30

        return .seconds(max(shortestKeepAlivePulse, min(longestKeepAlivePulse, pulse)))
    }

    public func exchangeSDP(
        offer: String,
        timeout: Duration = .seconds(30)
    ) async throws -> (sdp: String, versions: ChannelVersions) {
        _ = try await gssvClient.send(
            to: url.appending(path: "sdp"),
            method: "POST",
            body: try JSONSerialization.data(
                withJSONObject: sdpOfferBody(offer),
                options: [.withoutEscapingSlashes]
            )
        )

        return try await poll("sdp", timeout: timeout) { body in
            try SignalingAnswerParser().sdpAnswer(from: body)
        }
    }

    private func sdpOfferBody(_ offer: String) -> [String: Any] {
        [
            "messageType": "offer",
            "sdp": offer,
            "configuration": [
                "chatConfiguration": [
                    "bytesPerSample": 2,
                    "expectedClipDurationMs": 20,
                    "format": ["codec": "opus", "container": "webm"],
                    "numChannels": 1,
                    "sampleFrequencyHz": 24000,
                ],
                "chat": ["minVersion": 1, "maxVersion": 1],
                "control": ["minVersion": 1, "maxVersion": 3],
                "input": ["minVersion": 1, "maxVersion": 8],
                "message": ["minVersion": 1, "maxVersion": 1],
            ],
        ]
    }

    public func exchangeICE(
        _ candidates: [LocalICECandidate],
        timeout: Duration = .seconds(30)
    ) async throws -> [RemoteICECandidate] {
        let candidateEntries: [[String: Any]] = candidates.map { candidate in
            [
                "candidate": candidate.candidate,
                "sdpMid": candidate.sdpMid ?? "0",
                "sdpMLineIndex": Int(candidate.sdpMLineIndex),
            ]
        }
        _ = try await gssvClient.send(
            to: url.appending(path: "ice"),
            method: "POST",
            body: try JSONSerialization.data(
                withJSONObject: ["messageType": "iceCandidate", "candidate": candidateEntries],
                options: [.withoutEscapingSlashes]
            )
        )

        return try await poll("ice", timeout: timeout) { body in
            try SignalingAnswerParser().iceCandidates(from: body)
        }
    }

    private func poll<Answer: Sendable>(
        _ resource: String,
        timeout: Duration,
        parse: (Data) throws -> Answer?
    ) async throws -> Answer {
        let clock = ContinuousClock()
        let start = clock.now
        let deadline = start + timeout

        while clock.now < deadline {
            let response = try await gssvClient.send(to: url.appending(path: resource))
            let hasAnswerBody = response.statusCode != 204 && !response.body.isEmpty

            if hasAnswerBody, let answer = try parse(response.body) {
                return answer
            }

            try await Task.sleep(for: backoff.delay(after: clock.now - start))
        }

        throw GSSVSessionError.timedOut(resource)
    }

    public func keepAlive() async throws {
        _ = try await gssvClient.send(
            to: url.appending(path: "keepalive"),
            method: "POST",
            body: Data("{}".utf8)
        )
    }

    public func stop() async {
        #if os(tvOS)
        let log = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "Starfold",
            category: "TVSessionCleanup"
        )

        do {
            let response = try await gssvClient.send(to: url, method: "DELETE")
            log.info("Remote session DELETE returned HTTP \(response.statusCode)")
        } catch {
            log.error("Remote session DELETE failed: \(String(describing: error))")
        }
        #else
        _ = try? await gssvClient.send(to: url, method: "DELETE")
        #endif
    }
}
