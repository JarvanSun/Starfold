//
//  HostChannelsTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing
import XboxKit

@testable import StreamKit

struct HostChannelsTests {
    @Test
    func openedWhenMessageChannelOpensThenSendsHandshake() throws {
        // Given
        var channels = makeChannels()

        // When
        let actions = channels.opened(.message, timestamp: 0)

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
        let actions = channels.opened(.control, timestamp: 0)

        // Then
        #expect(actions == [.send(ControlMessage.keyframeRequest.json, on: .control)])
    }

    @Test
    func receivedWhenHandshakeAcknowledgedThenAuthorizesConfiguresAndAnnouncesGamepad() throws {
        // Given
        var channels = makeChannels(opening: [.control, .input])
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
    func receivedWhenHandshakeAcknowledgedBeforeControlOpensThenWaitsToAuthorize() throws {
        // Given
        var channels = makeChannels(opening: [.input])
        let acknowledgement = try envelope(type: "HandshakeAck")

        // When
        let actions = channels.received(acknowledgement, on: .message, timestamp: 0)

        // Then
        let configuration = Array(repeating: DataChannelLabel.message, count: 6)
        #expect(labels(of: actions) == [.input] + configuration)
        #expect(!actions.contains(.announceGamepad))
    }

    @Test
    func openedWhenControlOpensAfterHandshakeThenAuthorizesAndAnnouncesGamepad() throws {
        // Given
        var channels = makeChannels(opening: [.input])
        channels.received(try envelope(type: "HandshakeAck"), on: .message, timestamp: 0)

        // When
        let actions = channels.opened(.control, timestamp: 0)

        // Then
        #expect(
            actions == [
                .send(ControlMessage.keyframeRequest.json, on: .control),
                .send(ControlMessage.authorizationRequest.json, on: .control),
                .send(ControlMessage.gamepadChanged(index: 0, isAdded: false).json, on: .control),
                .announceGamepad,
            ]
        )
    }

    @Test
    func openedWhenInputOpensAfterHandshakeThenSendsClientMetadataAndAnnouncesGamepad() throws {
        // Given
        var channels = makeChannels(opening: [.control])
        let handshakeActions = channels.received(
            try envelope(type: "HandshakeAck"),
            on: .message,
            timestamp: 0
        )

        // When
        let actions = channels.opened(.input, timestamp: 0)

        // Then
        #expect(sentData(in: handshakeActions, on: .input).isEmpty)
        #expect(!handshakeActions.contains(.announceGamepad))
        #expect(labels(of: actions) == [.input, .control])
        #expect(actions.last == .announceGamepad)
    }

    @Test(
        arguments: [
            (StreamQuality.standard, 1280, 720),
            (.high, 1920, 1080),
            (.highest, 2560, 1440),
        ]
    )
    func receivedWhenResolutionFixedThenRequestsItRightAfterAuthorizing(
        quality: StreamQuality,
        width: Int,
        height: Int
    ) throws {
        // Given
        var channels = makeChannels(
            quality: quality,
            isResolutionFixed: true,
            opening: [.control, .input]
        )

        // When
        let actions = channels.received(
            try envelope(type: "HandshakeAck"),
            on: .message,
            timestamp: 0
        )

        // Then
        let control = try sentData(in: actions, on: .control).map(object)
        let dimensions = try #require(sentData(in: actions, on: .message).last)
        let content = try #require(try object(dimensions)["content"] as? String)
        let announced = try object(Data(content.utf8))
        let size = ["width": width, "height": height]
        #expect(
            control.compactMap { $0["message"] as? String } == [
                "authorizationRequest", "VideoPreference", "userRequestedResolutionUpdate",
                "gamepadChanged",
            ]
        )
        #expect(control[1]["resolution"] as? [String: Int] == size)
        #expect(control[1]["dimensions"] as? [String: Int] == size)
        #expect(control[1]["maxFPS"] as? Int == 60)
        #expect(control[2]["resolutionAlias"] as? String == String(height))
        #expect(announced["preferredWidth"] as? Int == width)
        #expect(announced["preferredHeight"] as? Int == height)
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

    @Test
    func receivedWhenHandshakeAcknowledgedWithoutTouchThenAnnouncesNoTouchPoints() throws {
        // Given
        var channels = makeChannels(opening: [.input])

        // When
        let actions = channels.received(
            try envelope(type: "HandshakeAck"),
            on: .message,
            timestamp: 0
        )

        // Then
        let metadata = try #require(sentData(in: actions, on: .input).first)
        #expect([UInt8](metadata).last == 0)
    }

    @Test
    func receivedWhenHandshakeAcknowledgedWithTouchThenAnnouncesTouchPointsAndTouchInput() throws {
        // Given
        let touchCapabilities = TouchCapabilities(
            maxTouchPoints: 5,
            maxLayoutVersion: "4.1.0.0",
            maxManifestVersion: "2.0.0.0"
        )
        var channels = makeChannels(touchCapabilities: touchCapabilities, opening: [.input])

        // When
        let actions = channels.received(
            try envelope(type: "HandshakeAck"),
            on: .message,
            timestamp: 0
        )

        // Then
        let metadata = try #require(sentData(in: actions, on: .input).first)
        let configuration = sentData(in: actions, on: .message)
        #expect([UInt8](metadata).last == 5)
        #expect(
            try object(configuration[3])["content"] as? String == #"{"touchInputEnabled":true}"#
        )
    }

    @Test
    func receivedWhenTouchControlsCommandThenUpdatesStream() throws {
        // Given
        var channels = makeChannels()
        let hide = try envelope(type: "Message", target: "/streaming/touchcontrols/hide")

        // When
        let actions = channels.received(hide, on: .message, timestamp: 0)

        // Then
        #expect(actions == [.update(.touchControls(.hide))])
    }

    @Test
    func receivedWhenTitleInfoThenUpdatesStreamWithRunningTitle() throws {
        // Given
        var channels = makeChannels()
        let titleInfo = try envelope(
            type: "Message",
            target: "/streaming/properties/titleinfo",
            content: #"{"titleid":"ABCD1234","focus":true}"#
        )

        // When
        let actions = channels.received(titleInfo, on: .message, timestamp: 0)

        // Then
        let title = RunningTitle(titleID: "ABCD1234", isFocused: true)
        #expect(actions == [.update(.runningTitle(title))])
    }

    @Test
    func announceTouchBundleThenSendsMetadataOnMessageChannel() throws {
        // Given
        var channels = makeChannels()

        // When
        let action = channels.announceTouchBundle(version: "2.0.0.0", versionName: "Season")

        // Then
        let data = try #require(sentData(in: [action], on: .message).first)
        #expect(
            try object(data)["target"] as? String
                == "/streaming/characteristics/touchBundleMetadataChanged"
        )
    }
}

private extension HostChannelsTests {
    func makeChannels(
        quality: StreamQuality = .high,
        isResolutionFixed: Bool = false,
        touchCapabilities: TouchCapabilities? = nil,
        opening labels: [DataChannelLabel] = []
    ) -> HostChannels {
        var channels = HostChannels(
            options: .init(
                quality: quality,
                isResolutionFixed: isResolutionFixed,
                clientAppInstallID: UUID(),
                touchCapabilities: touchCapabilities
            ),
            messageChannel: .init(correlationBase: "abc")
        )

        for label in labels {
            channels.opened(label, timestamp: 0)
        }

        return channels
    }

    func envelope(type: String, target: String = "", content: String = "{}") throws -> Data {
        try JSONSerialization.data(withJSONObject: [
            "type": type, "id": "1", "target": target, "content": content,
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
