//
//  HostChannelsTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import StreamKit

struct HostChannelsTests {
    @Test
    func openedWhenMessageChannelOpensThenSendsHandshake() throws {
        // Given
        var channels = makeChannels()

        // When
        let actions = channels.opened(.message)

        // Then
        let data = try #require(sentData(in: actions, on: .message).first)
        #expect(actions.count == 1)
        #expect(try object(data)["type"] as? String == "Handshake")
    }

    @Test
    func openedWhenControlChannelOpensThenRequestsKeyframe() {
        // Given
        var channels = makeChannels()

        // When
        let actions = channels.opened(.control)

        // Then
        #expect(actions == [.send(ControlMessage.keyframeRequest.json, on: .control)])
    }

    @Test
    func receivedWhenHandshakeAcknowledgedThenAuthorizesConfiguresAndAnnouncesGamepad() throws {
        // Given
        var channels = makeChannels()
        let acknowledgement = try envelope(type: "HandshakeAck")

        // When
        let actions = channels.received(acknowledgement, on: .message, timestamp: 0)

        // Then
        let configuration = Array(repeating: DataChannelLabel.message, count: 6)
        #expect(labels(of: actions) == [.control, .input] + configuration + [.control])
        #expect(actions.first == .send(ControlMessage.authorizationRequest.json, on: .control))
        #expect(actions.last == .announceGamepad)
    }

    @Test
    func receivedWhenHandshakeAcknowledgedTwiceThenHandshakesOnce() throws {
        // Given
        var channels = makeChannels()
        let acknowledgement = try envelope(type: "HandshakeAck")
        channels.received(acknowledgement, on: .message, timestamp: 0)

        // When
        let actions = channels.received(acknowledgement, on: .message, timestamp: 0)

        // Then
        #expect(actions.isEmpty)
    }

    @Test
    func receivedWhenHostDisconnectsThenEndsStream() throws {
        // Given
        var channels = makeChannels()
        let disconnect = try envelope(
            type: "Message",
            target: "/streaming/sessionLifetimeManagement/serverInitiatedDisconnect"
        )

        // When
        let actions = channels.received(disconnect, on: .message, timestamp: 0)

        // Then
        #expect(actions == [.end(.hostEnded)])
    }

    @Test
    func receivedWhenControlChannelSpeaksThenOnlyTracesIt() {
        // Given
        var channels = makeChannels()

        // When
        let actions = channels.received(Data("{}".utf8), on: .control, timestamp: 0)

        // Then
        #expect(actions == [.trace("control: {}")])
    }
}

private extension HostChannelsTests {
    func makeChannels() -> HostChannels {
        .init(
            options: .init(clientAppInstallID: UUID()),
            messageChannel: .init(correlationBase: "abc")
        )
    }

    func envelope(type: String, target: String = "") throws -> Data {
        try JSONSerialization.data(withJSONObject: [
            "type": type, "id": "1", "target": target, "content": "{}",
        ])
    }

    func sentData(in actions: [HostChannelAction], on label: DataChannelLabel) -> [Data] {
        actions.compactMap { action in
            switch action {
            case .send(let data, let sentOn) where sentOn == label: data
            default: nil
            }
        }
    }

    func labels(of actions: [HostChannelAction]) -> [DataChannelLabel] {
        actions.compactMap { action in
            switch action {
            case .send(_, let label): label
            default: nil
            }
        }
    }

    func object(_ data: Data) throws -> [String: Any] {
        try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
    }
}
