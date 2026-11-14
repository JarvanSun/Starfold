//
//  MessageChannelTests.swift
//  StreamKitTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import Testing

@testable import StreamKit

struct MessageChannelTests {
    @Test
    func initialConfigurationThenSendsTargetsInRequiredOrderWithStringContent() throws {
        // Given
        var channel = MessageChannel(correlationBase: "abc")

        // When
        let packets = channel.initialConfiguration(
            videoWidth: 1920,
            videoHeight: 1080,
            clientAppInstallID: UUID(),
            touch: nil
        )

        // Then
        let targets = try packets.map { try object($0)["target"] as? String }
        let content = try #require(try object(packets[0])["content"] as? String)
        #expect(
            targets == [
                "/streaming/systemUi/configuration",
                "/streaming/properties/clientappinstallidchanged",
                "/streaming/characteristics/orientationchanged",
                "/streaming/characteristics/touchinputenabledchanged",
                "/streaming/characteristics/clientdevicecapabilities",
                "/streaming/characteristics/dimensionschanged",
            ]
        )
        #expect(content == #"{"systemUis":[10,19],"version":[0,2,0]}"#)
    }

    @Test

    func receiveWhenMessageDialogThenReportsDialog() throws {
        // Given
        var channel = MessageChannel(correlationBase: "abc")

        // When
        let events = channel.receive(try messageDialogRequest())

        // Then
        let kind = SystemDialogRequest.Kind.message(
            title: "Quit?",
            text: "Progress will be lost",
            buttons: ["Yes", "No"],
            defaultIndex: 0,
            cancelIndex: 1
        )
        #expect(events == [.dialog(SystemDialogRequest(id: "42", kind: kind))])
    }

    @Test

    func completeMessageDialogThenAnswersWithTheRequestID() throws {
        // Given
        var channel = MessageChannel(correlationBase: "abc")
        channel.receive(try messageDialogRequest())

        // When
        let reply = try object(channel.completeMessageDialog(id: "42", buttonIndex: 1))

        // Then
        #expect(reply["type"] as? String == "TransactionComplete")
        #expect(reply["id"] as? String == "42")
        #expect(reply["content"] as? String == #"{"Result":1}"#)
    }

    @Test

    func receiveWhenUnknownTargetWithPaddingThenRepliesUnhandled() throws {
        // Given
        var channel = MessageChannel(correlationBase: "abc")
        var data = try JSONSerialization.data(
            withJSONObject: [
                "type": "Message", "id": "7", "target": "/streaming/new/thing", "content": "{}",
            ]
        )
        data.append(0)

        // When
        let events = channel.receive(data)

        // Then
        guard case .reply(let reply)? = events.first else {
            Issue.record("Expected a reply")

            return
        }

        #expect(try object(reply)["type"] as? String == "Unhandled")
    }

    @Test

    func receiveWhenHandshakeAcknowledgedThenReportsIt() {
        // Given
        var channel = MessageChannel()
        let acknowledgement = Data(
            #"{"type":"HandshakeAck","version":"messageV1","id":"1","cv":"0"}"#.utf8
        )

        // When / Then
        #expect(channel.receive(acknowledgement) == [.handshakeAcknowledged])
    }

    @Test
    func initialConfigurationWhenNoTouchThenKeepsTouchOffWithEmptyCapabilities() throws {
        // Given
        var channel = MessageChannel(correlationBase: "abc")

        // When
        let packets = channel.initialConfiguration(
            videoWidth: 1280,
            videoHeight: 720,
            clientAppInstallID: UUID(),
            touch: nil
        )

        // Then
        #expect(try object(packets[3])["content"] as? String == #"{"touchInputEnabled":false}"#)
        #expect(try object(packets[4])["content"] as? String == "{}")
    }

    @Test
    func initialConfigurationWhenTouchSupportedThenEnablesTouchAndNamesBundleVersions() throws {
        // Given
        var channel = MessageChannel(correlationBase: "abc")
        let touchCapabilities = TouchCapabilities(
            maxTouchPoints: 5,
            maxLayoutVersion: "4.1.0.0",
            maxManifestVersion: "2.0.0.0"
        )

        // When
        let packets = channel.initialConfiguration(
            videoWidth: 1280,
            videoHeight: 720,
            clientAppInstallID: UUID(),
            touch: touchCapabilities
        )

        // Then
        #expect(try object(packets[3])["content"] as? String == #"{"touchInputEnabled":true}"#)
        #expect(
            try object(packets[4])["content"] as? String
                == #"{"maxTouchBundleLayoutVersion":"4.1.0.0","maxTouchBundleManifestVersion":"2.0.0.0"}"#
        )
    }

    @Test
    func touchBundleMetadataChangedThenSendsMessageWithVersionAndName() throws {
        // Given
        var channel = MessageChannel(correlationBase: "abc")

        // When
        let packet = try object(
            channel.touchBundleMetadataChanged(version: "1.4.0.0", versionName: "Launch")
        )

        // Then
        #expect(packet["type"] as? String == "Message")
        #expect(
            packet["target"] as? String == "/streaming/characteristics/touchBundleMetadataChanged"
        )
        #expect(packet["content"] as? String == #"{"version":"1.4.0.0","versionName":"Launch"}"#)
        #expect(packet["cv"] as? String == "abc.1")
    }

    @Test
    func receiveWhenTouchControlsMessageThenReportsCommandWithoutReply() throws {
        // Given
        var channel = MessageChannel(correlationBase: "abc")
        let message = try envelope(type: "Message", target: "/streaming/touchcontrols/hide")

        // When / Then
        #expect(channel.receive(message) == [.touchControls(.hide)])
    }

    @Test
    func receiveWhenTouchControlsTransactionThenCancelsAndReportsCommand() throws {
        // Given
        var channel = MessageChannel(correlationBase: "abc")
        let transaction = try envelope(
            type: "TransactionStart",
            target: "/streaming/touchcontrols/showtitledefault"
        )

        // When
        let events = channel.receive(transaction)

        // Then
        guard case .reply(let reply)? = events.first else {
            Issue.record("Expected a reply")

            return
        }

        #expect(try object(reply)["type"] as? String == "ReceiverCancel")
        #expect(try object(reply)["id"] as? String == "9")
        #expect(events.dropFirst() == [.touchControls(.showLayout(.titleDefault, statePatch: nil))])
    }

    @Test
    func receiveWhenUnknownTouchControlsMessageThenIgnoresIt() throws {
        // Given
        var channel = MessageChannel(correlationBase: "abc")
        let message = try envelope(type: "Message", target: "/streaming/touchcontrols/sensor")

        // When / Then
        #expect(channel.receive(message).isEmpty)
    }

    @Test
    func receiveWhenTitleInfoThenReportsRunningTitle() throws {
        // Given
        var channel = MessageChannel(correlationBase: "abc")
        let message = try envelope(
            type: "Message",
            target: "/streaming/properties/titleinfo",
            content: #"{"titleid":"5D3C5A7D","focus":false}"#
        )

        // When / Then
        #expect(
            channel.receive(message)
                == [.runningTitle(RunningTitle(titleID: "5D3C5A7D", isFocused: false))]
        )
    }
}

private extension MessageChannelTests {
    func envelope(type: String, target: String, content: String = "{}") throws -> Data {
        try JSONSerialization.data(withJSONObject: [
            "type": type, "id": "9", "target": target, "content": content,
        ])
    }

    func object(_ data: Data) throws -> [String: Any] {
        try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    func messageDialogRequest() throws -> Data {
        let content =
            #"{"TitleText":"Quit?","ContentText":"Progress will be lost","CommandLabel1":"Yes","CommandLabel2":"No","CommandLabel3":"","DefaultIndex":0,"CancelIndex":1}"#
        return try JSONSerialization.data(withJSONObject: [
            "type": "TransactionStart",
            "id": "42",
            "target": "/streaming/systemUi/messages/ShowMessageDialog",
            "content": content,
            "cv": "x.1",
        ])
    }
}
