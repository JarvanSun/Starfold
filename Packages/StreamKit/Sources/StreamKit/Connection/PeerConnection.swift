//
//  PeerConnection.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import CoreVideo
import Foundation
@preconcurrency import LiveKitWebRTC
import XboxKit
import os

final class PeerConnection: NSObject, @unchecked Sendable {
    let frameReceiver = FrameReceiver()

    private let factory: LKRTCPeerConnectionFactory
    private let connection: LKRTCPeerConnection
    private let delegateProxy: DelegateProxy
    private let events: @Sendable (PeerEvent) -> Void
    private let lock = NSLock()
    private let log = Logger(category: .webRTC)

    private var channels: [DataChannelLabel: LKRTCDataChannel] = [:]
    private var videoTrack: LKRTCVideoTrack?
    private var hasAudio = false
    private var hasVideo = false

    init?(
        runtime: StreamRuntime,
        stunServers: [String],
        events: @escaping @Sendable (PeerEvent) -> Void
    ) {
        let factory = runtime.peerConnectionFactory()
        let delegateProxy = DelegateProxy()
        guard
            let connection = factory.peerConnection(
                with: PeerConfiguration(stunServers: stunServers).rtcConfiguration,
                constraints: LKRTCMediaConstraints(
                    mandatoryConstraints: nil,
                    optionalConstraints: nil
                ),
                delegate: delegateProxy
            )
        else { return nil }

        self.factory = factory
        self.events = events
        self.connection = connection
        self.delegateProxy = delegateProxy

        super.init()

        delegateProxy.owner = self

        addTransceivers()

        openDataChannels()
    }

    func createOffer(videoBitrateKbps: Int?) async throws -> String {
        let offer = try await makeOffer()
        let sdp = munged(offer.sdp, videoBitrateKbps: videoBitrateKbps)
        let description = LKRTCSessionDescription(type: .offer, sdp: sdp)
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            connection.setLocalDescription(description) { error in
                switch error {
                case let error?: continuation.resume(throwing: error)
                case nil: continuation.resume()
                }
            }
        }

        return sdp
    }

    func setAnswer(_ sdp: String) async throws {
        let answer = LKRTCSessionDescription(type: .answer, sdp: sdp)
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            connection.setRemoteDescription(answer) { error in
                switch error {
                case let error?: continuation.resume(throwing: error)
                case nil: continuation.resume()
                }
            }
        }
    }

    func addRemoteCandidate(_ candidate: RemoteICECandidate) async {
        let iceCandidate = LKRTCIceCandidate(
            sdp: candidate.candidate,
            sdpMLineIndex: Int32(candidate.sdpMLineIndex),
            sdpMid: candidate.sdpMid
        )
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            connection.add(iceCandidate) { [log] error in
                if let error {
                    log.info(
                        "Remote candidate rejected (\(candidate.candidate)): \(error.localizedDescription)"
                    )
                }

                continuation.resume()
            }
        }
    }

    @discardableResult
    func send(_ data: Data, on label: DataChannelLabel) -> Bool {
        guard let channel = channels[label], channel.readyState == .open else { return false }

        return channel.sendData(LKRTCDataBuffer(data: data, isBinary: true))
    }

    func bufferedAmount(on label: DataChannelLabel) -> UInt64 {
        channels[label]?.bufferedAmount ?? 0
    }

    func statistics() async -> [String: LKRTCStatistics] {
        await withCheckedContinuation { continuation in
            connection.statistics { report in
                continuation.resume(returning: report.statistics)
            }
        }
    }

    func close() {
        lock.withLock {
            videoTrack?.remove(frameReceiver)
            videoTrack = nil
        }

        for channel in channels.values {
            channel.close()
        }

        connection.close()
    }
}

// MARK: - Private

private extension PeerConnection {
    func addTransceivers() {
        let audio = LKRTCRtpTransceiverInit()
        audio.direction = .sendRecv
        connection.addTransceiver(of: .audio, init: audio)

        let video = LKRTCRtpTransceiverInit()
        video.direction = .recvOnly

        if let transceiver = connection.addTransceiver(of: .video, init: video) {
            preferH264(on: transceiver)
        }
    }

    func preferH264(on transceiver: LKRTCRtpTransceiver) {
        let codecs = factory.rtpReceiverCapabilities(forKind: "video").codecs
        let order = SDPMunger().preferredH264Order(
            mimeTypes: codecs.map(\.mimeType),
            profileLevelIDs: codecs.map { $0.parameters["profile-level-id"] }
        )

        do {
            try transceiver.setCodecPreferences(order.map { codecs[$0] }, error: ())
        } catch {
            log.error("setCodecPreferences failed: \(error.localizedDescription)")
        }
    }

    func openDataChannels() {
        for label in DataChannelLabel.allCases {
            let configuration = LKRTCDataChannelConfiguration()
            configuration.isOrdered = true
            configuration.protocol = label.protocolName

            if let channel = connection.dataChannel(
                forLabel: label.rawValue,
                configuration: configuration
            ) {
                channel.delegate = delegateProxy
                channels[label] = channel
            }
        }
    }

    func makeOffer() async throws -> LKRTCSessionDescription {
        let constraints = LKRTCMediaConstraints(
            mandatoryConstraints: ["OfferToReceiveAudio": "true", "OfferToReceiveVideo": "true"],
            optionalConstraints: nil
        )
        return try await withCheckedThrowingContinuation { continuation in
            connection.offer(for: constraints) { description, error in
                switch (description, error) {
                case (let description?, _):
                    continuation.resume(returning: description)
                case (nil, let error):
                    continuation.resume(
                        throwing: error ?? StreamError.webRTC("createOffer returned nothing")
                    )
                }
            }
        }
    }

    func munged(_ sdp: String, videoBitrateKbps: Int?) -> String {
        let munger = SDPMunger()
        let stereo = munger.forcingStereoOpus(sdp)

        return switch videoBitrateKbps {
        case let kbps?: munger.limitingVideoBitrate(stereo, kbps: kbps)
        case nil: stereo
        }
    }

    func handleICEState(_ state: LKRTCIceConnectionState) {
        log.info("ICE state \(state.rawValue)")
    }

    func handleGathering(_ state: LKRTCIceGatheringState) {
        if state == .complete {
            events(.gatheringComplete)
        }
    }

    func handleCandidate(_ candidate: LKRTCIceCandidate) {
        let local = LocalICECandidate(
            candidate: candidate.sdp,
            sdpMid: candidate.sdpMid,
            sdpMLineIndex: candidate.sdpMLineIndex
        )
        events(.localCandidate(local))
    }

    func handleConnectionState(_ state: LKRTCPeerConnectionState) {
        let mapped: PeerConnectionState =
            switch state {
            case .new: .new
            case .connecting: .connecting
            case .connected: .connected
            case .disconnected: .disconnected
            case .failed: .failed
            case .closed: .closed
            @unknown default: .failed
            }
        events(.connectionState(mapped))
    }

    func handleReceiver(_ receiver: LKRTCRtpReceiver) {
        let hasBothTracks = lock.withLock {
            switch receiver.track {
            case let track as LKRTCVideoTrack:
                videoTrack = track
                track.add(frameReceiver)
                hasVideo = true
            case is LKRTCAudioTrack:
                hasAudio = true
            default:
                break
            }

            return hasAudio && hasVideo
        }

        if hasBothTracks {
            events(.mediaTracksReady)
        }
    }

    func handleChannelState(_ channel: LKRTCDataChannel) {
        guard let label = DataChannelLabel(rawValue: channel.label) else { return }

        switch channel.readyState {
        case .open: events(.channelOpen(label))
        case .closed: events(.channelClosed(label))
        default: break
        }
    }

    func handleMessage(_ channel: LKRTCDataChannel, _ buffer: LKRTCDataBuffer) {
        guard let label = DataChannelLabel(rawValue: channel.label) else { return }

        events(.channelMessage(label, buffer.data))
    }
}

private struct PeerConfiguration {
    let stunServers: [String]

    var rtcConfiguration: LKRTCConfiguration {
        let configuration = LKRTCConfiguration()
        configuration.sdpSemantics = .unifiedPlan
        configuration.bundlePolicy = .maxBundle
        configuration.rtcpMuxPolicy = .require
        configuration.continualGatheringPolicy = .gatherOnce
        configuration.disableLinkLocalNetworks = true
        configuration.tcpCandidatePolicy = .disabled
        configuration.enableDscp = true
        configuration.audioJitterBufferFastAccelerate = true
        configuration.iceServers =
            stunServers.isEmpty ? [] : [LKRTCIceServer(urlStrings: stunServers)]

        return configuration
    }
}

private final class DelegateProxy: NSObject, LKRTCPeerConnectionDelegate, LKRTCDataChannelDelegate,
    @unchecked Sendable
{
    weak var owner: PeerConnection?

    func peerConnection(
        _ peerConnection: LKRTCPeerConnection,
        didChange stateChanged: LKRTCSignalingState
    ) {}

    func peerConnection(_ peerConnection: LKRTCPeerConnection, didAdd stream: LKRTCMediaStream) {}

    func peerConnection(_ peerConnection: LKRTCPeerConnection, didRemove stream: LKRTCMediaStream) {
    }

    func peerConnectionShouldNegotiate(_ peerConnection: LKRTCPeerConnection) {}

    func peerConnection(
        _ peerConnection: LKRTCPeerConnection,
        didChange newState: LKRTCIceConnectionState
    ) {
        owner?.handleICEState(newState)
    }

    func peerConnection(
        _ peerConnection: LKRTCPeerConnection,
        didChange newState: LKRTCIceGatheringState
    ) {
        owner?.handleGathering(newState)
    }

    func peerConnection(
        _ peerConnection: LKRTCPeerConnection,
        didGenerate candidate: LKRTCIceCandidate
    ) {
        owner?.handleCandidate(candidate)
    }

    func peerConnection(
        _ peerConnection: LKRTCPeerConnection,
        didRemove candidates: [LKRTCIceCandidate]
    ) {}

    func peerConnection(
        _ peerConnection: LKRTCPeerConnection,
        didOpen dataChannel: LKRTCDataChannel
    ) {}

    func peerConnection(
        _ peerConnection: LKRTCPeerConnection,
        didChange newState: LKRTCPeerConnectionState
    ) {
        owner?.handleConnectionState(newState)
    }

    func peerConnection(
        _ peerConnection: LKRTCPeerConnection,
        didAdd rtpReceiver: LKRTCRtpReceiver,
        streams mediaStreams: [LKRTCMediaStream]
    ) {
        owner?.handleReceiver(rtpReceiver)
    }

    func dataChannelDidChangeState(_ dataChannel: LKRTCDataChannel) {
        owner?.handleChannelState(dataChannel)
    }

    func dataChannel(_ dataChannel: LKRTCDataChannel, didReceiveMessageWith buffer: LKRTCDataBuffer)
    {
        owner?.handleMessage(dataChannel, buffer)
    }
}
