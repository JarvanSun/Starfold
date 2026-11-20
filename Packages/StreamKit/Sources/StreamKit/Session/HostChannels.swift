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
    private var isControlOpen = false

    private let qhdSize = (width: 2560, height: 1440)

    init(options: StreamOptions, messageChannel: MessageChannel = .init()) {
        self.options = options
        self.messageChannel = messageChannel
    }

    mutating func opened(_ label: DataChannelLabel) -> [HostChannelAction] {
        switch label {
        case .message:
            return [.send(messageChannel.handshake(), on: .message)]
        case .control:
            let request = options.requestsConsole1440p && hasStartedHandshake && !isControlOpen
            isControlOpen = true
            let keyframe: HostChannelAction = .send(
                ControlMessage.keyframeRequest.json,
                on: .control
            )
            return request
                ? authorizationActions() + [keyframe] + firstGamepadActions() : [keyframe]
        case .input, .chat:
            return []
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

        let size = options.requestsConsole1440p ? qhdSize : options.quality.nominalSize
        let configuration = messageChannel.initialConfiguration(
            videoWidth: size.width,
            videoHeight: size.height,
            clientAppInstallID: options.clientAppInstallID,
            touch: options.touchCapabilities
        )
        let metadata = ClientMetadata(
            maxTouchPoints: options.touchCapabilities?.maxTouchPoints ?? 0
        )

        let canInitializeControl = !options.requestsConsole1440p || isControlOpen
        let authorization = canInitializeControl ? authorizationActions() : []
        let inputMetadata: [HostChannelAction] = [
            .send(metadata.encoded(timestamp: timestamp), on: .input)
        ]
        let firstGamepad = canInitializeControl ? firstGamepadActions() : []

        return authorization + inputMetadata + configuration.map { .send($0, on: .message) }
            + firstGamepad
    }

    private func authorizationActions() -> [HostChannelAction] {
        var messages: [ControlMessage] = [.authorizationRequest]
        if options.requestsConsole1440p {
            // The Remote Play control messages are also documented in Greenlight PR #1752.
            messages.append(.videoPreference(width: qhdSize.width, height: qhdSize.height))
            messages.append(.requestedResolution(height: qhdSize.height))
        }
        return messages.map { .send($0.json, on: .control) }
    }

    private func firstGamepadActions() -> [HostChannelAction] {
        [
            .send(ControlMessage.gamepadChanged(index: 0, isAdded: false).json, on: .control),
            .announceGamepad,
        ]
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
