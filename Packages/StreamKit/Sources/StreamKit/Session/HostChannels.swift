//
//  HostChannels.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct HostChannels {
    private let options: StreamOptions

    private var messageChannel: MessageChannel
    private var hasStartedHandshake = false

    init(options: StreamOptions, messageChannel: MessageChannel = .init()) {
        self.options = options
        self.messageChannel = messageChannel
    }

    mutating func opened(_ label: DataChannelLabel) -> [HostChannelAction] {
        switch label {
        case .message: [.send(messageChannel.handshake(), on: .message)]
        case .control: [.send(ControlMessage.keyframeRequest.json, on: .control)]
        case .input, .chat: []
        }
    }

    @discardableResult
    mutating func received(
        _ data: Data,
        on label: DataChannelLabel,
        timestamp: Double
    ) -> [HostChannelAction] {
        switch label {
        case .message:
            messageChannel.receive(data).flatMap { actions(for: $0, timestamp: timestamp) }
        case .input:
            ServerInputPacket(data: data).events.map(action(for:))
        case .control, .chat:
            [.trace("\(label.rawValue): \(String(decoding: data, as: UTF8.self))")]
        }
    }

    private mutating func actions(
        for event: MessageChannelEvent,
        timestamp: Double
    ) -> [HostChannelAction] {
        switch event {
        case .handshakeAcknowledged: completeHandshake(timestamp: timestamp)
        case .reply(let reply): [.send(reply, on: .message)]
        case .dialog(let request): [.update(.dialog(request))]
        case .dialogCancelled(let id): [.update(.dialogDismissed(id: id))]
        case .serverDisconnect: [.end(.hostEnded)]
        case .touchControls(let command): [.update(.touchControls(command))]
        case .runningTitle(let title): [.update(.runningTitle(title))]
        }
    }

    private mutating func completeHandshake(timestamp: Double) -> [HostChannelAction] {
        guard !hasStartedHandshake else { return [] }

        hasStartedHandshake = true

        let size = options.quality.nominalSize
        let configuration = messageChannel.initialConfiguration(
            videoWidth: size.width,
            videoHeight: size.height,
            clientAppInstallID: options.clientAppInstallID,
            touch: options.touchCapabilities
        )
        let metadata = ClientMetadata(
            maxTouchPoints: options.touchCapabilities?.maxTouchPoints ?? 0
        )

        let authorization: [HostChannelAction] = [
            .send(ControlMessage.authorizationRequest.json, on: .control),
            .send(metadata.encoded(timestamp: timestamp), on: .input),
        ]
        let firstGamepad: [HostChannelAction] = [
            .send(ControlMessage.gamepadChanged(index: 0, isAdded: false).json, on: .control),
            .announceGamepad,
        ]

        return authorization + configuration.map { .send($0, on: .message) } + firstGamepad
    }

    private func action(for event: ServerInputEvent) -> HostChannelAction {
        switch event {
        case .videoSize(let width, let height): .update(.videoSize(width: width, height: height))
        case .vibration(let effect): .update(.vibration(effect))
        }
    }

    mutating func answerDialog(id: String, buttonIndex: Int) -> HostChannelAction {
        .send(messageChannel.completeMessageDialog(id: id, buttonIndex: buttonIndex), on: .message)
    }

    mutating func answerKeyboard(id: String, text: String?) -> HostChannelAction {
        let reply =
            switch text {
            case let text?: messageChannel.completeKeyboard(id: id, text: text)
            case nil: messageChannel.cancel(id: id)
            }

        return .send(reply, on: .message)
    }

    mutating func announceTouchBundle(version: String, versionName: String) -> HostChannelAction {
        let announcement = messageChannel.touchBundleMetadataChanged(
            version: version,
            versionName: versionName
        )
        return .send(announcement, on: .message)
    }
}
