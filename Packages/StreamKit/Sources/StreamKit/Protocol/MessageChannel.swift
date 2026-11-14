//
//  MessageChannel.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation

struct MessageChannel: Sendable {
    private let correlationBase: String

    private var correlationCount = 0

    init() {
        self.init(
            correlationBase: UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        )
    }

    init(correlationBase: String) {
        self.correlationBase = correlationBase
    }

    mutating func handshake() -> Data {
        encode([
            "type": MessageEnvelopeType.handshake.rawValue,
            "version": "messageV1",
            "id": newMessageID(),
            "cv": nextCorrelationVector(),
        ])
    }

    private func encode(_ object: [String: Any]) -> Data {
        let options: JSONSerialization.WritingOptions = [.sortedKeys, .withoutEscapingSlashes]
        return (try? JSONSerialization.data(withJSONObject: object, options: options)) ?? Data()
    }

    private func newMessageID() -> String {
        UUID().uuidString.lowercased()
    }

    private mutating func nextCorrelationVector() -> String {
        correlationCount += 1
        return "\(correlationBase).\(correlationCount)"
    }

    mutating func initialConfiguration(
        videoWidth: Int,
        videoHeight: Int,
        clientAppInstallID: UUID,
        touch: TouchCapabilities?
    ) -> [Data] {
        [
            message(
                .systemUIConfiguration,
                ["version": [0, 2, 0], "systemUis": supportedSystemUIs]
            ),
            message(
                .clientAppInstallIDChanged,
                ["clientAppInstallId": clientAppInstallID.uuidString.lowercased()]
            ),
            message(.orientationChanged, ["orientation": 0]),
            message(.touchInputEnabledChanged, ["touchInputEnabled": touch != nil]),
            message(.clientDeviceCapabilities, deviceCapabilities(touch: touch)),
            dimensionsChanged(width: videoWidth, height: videoHeight),
        ]
    }

    private mutating func message(_ target: MessageTarget, _ content: [String: Any]) -> Data {
        encode([
            "type": MessageEnvelopeType.message.rawValue,
            "id": newMessageID(),
            "target": target.rawValue,
            "content": jsonString(content),
            "cv": nextCorrelationVector(),
        ])
    }

    private func jsonString(_ content: [String: Any]) -> String {
        let options: JSONSerialization.WritingOptions = [.sortedKeys, .withoutEscapingSlashes]
        let data = try? JSONSerialization.data(withJSONObject: content, options: options)
        return data.map { String(decoding: $0, as: UTF8.self) } ?? "{}"
    }

    private func deviceCapabilities(touch: TouchCapabilities?) -> [String: Any] {
        switch touch {
        case let touch?:
            [
                "maxTouchBundleLayoutVersion": touch.maxLayoutVersion,
                "maxTouchBundleManifestVersion": touch.maxManifestVersion,
            ]
        case nil:
            [:]
        }
    }

    private mutating func dimensionsChanged(width: Int, height: Int) -> Data {
        message(
            .dimensionsChanged,
            [
                "horizontal": width,
                "vertical": height,
                "preferredWidth": width,
                "preferredHeight": height,
                "safeAreaLeft": 0,
                "safeAreaTop": 0,
                "safeAreaRight": width,
                "safeAreaBottom": height,
                "supportsCustomResolution": true,
            ]
        )
    }

    private var supportedSystemUIs: [Int] { [10, 19] }

    mutating func touchBundleMetadataChanged(version: String, versionName: String) -> Data {
        message(.touchBundleMetadataChanged, ["version": version, "versionName": versionName])
    }

    mutating func completeMessageDialog(id: String, buttonIndex: Int) -> Data {
        transactionComplete(id: id, content: ["Result": buttonIndex])
    }

    private mutating func transactionComplete(id: String, content: [String: Any]) -> Data {
        encode([
            "type": MessageEnvelopeType.transactionComplete.rawValue,
            "id": id,
            "content": jsonString(content),
            "cv": nextCorrelationVector(),
        ])
    }

    mutating func completeKeyboard(id: String, text: String) -> Data {
        transactionComplete(id: id, content: ["Text": text])
    }

    mutating func cancel(id: String) -> Data {
        encode([
            "type": MessageEnvelopeType.receiverCancel.rawValue,
            "id": id,
            "cv": nextCorrelationVector(),
        ])
    }

    @discardableResult
    mutating func receive(_ data: Data) -> [MessageChannelEvent] {
        let withoutPadding = Data(data.filter { $0 != 0 })
        guard
            let envelope = try? JSONSerialization.jsonObject(with: withoutPadding)
                as? [String: Any],
            let type = (envelope["type"] as? String).flatMap(MessageEnvelopeType.init(rawValue:))
        else { return [] }

        let id = envelope["id"] as? String ?? ""
        let target = envelope["target"] as? String ?? ""
        return switch type {
        case .handshakeAcknowledgement: [.handshakeAcknowledged]
        case .senderCancel: [.dialogCancelled(id: id)]
        case .message, .transactionStart:
            receiveMessage(
                target: target,
                id: id,
                content: envelope["content"],
                isTransaction: type == .transactionStart
            )
        case .handshake, .transactionComplete, .receiverCancel, .unhandled: []
        }
    }

    private mutating func receiveMessage(
        target: String,
        id: String,
        content: Any?,
        isTransaction: Bool
    ) -> [MessageChannelEvent] {
        guard let messageTarget = MessageTarget(rawValue: target) else {
            return receiveUnknownMessage(target: target, id: id, isTransaction: isTransaction)
        }

        let object = self.content(of: content)

        return switch messageTarget {
        case .showMessageDialog:
            [.dialog(messageDialog(id: id, content: object))]
        case .showVirtualKeyboard:
            [.dialog(keyboardDialog(id: id, content: object))]
        case .serverInitiatedDisconnect where isTransaction:
            [.reply(transactionComplete(id: id, content: [:])), .serverDisconnect]
        case .serverInitiatedDisconnect:
            [.serverDisconnect]
        case .titleInfo:
            RunningTitle(content: object).map { [.runningTitle($0)] } ?? []
        case .showTouchLayoutV2, .showTouchLayout, .showTitleDefaultTouchLayout,
            .patchTouchLayoutState, .hideTouchLayout:
            receiveTouchControls(
                TouchControlsCommand(
                    target: messageTarget,
                    object: object,
                    text: content as? String
                ),
                id: id,
                isTransaction: isTransaction
            )
        case .systemUIConfiguration, .clientAppInstallIDChanged, .orientationChanged,
            .touchInputEnabledChanged, .clientDeviceCapabilities, .dimensionsChanged,
            .touchBundleMetadataChanged:
            receiveUnknownMessage(target: target, id: id, isTransaction: isTransaction)
        }
    }

    private mutating func receiveUnknownMessage(target: String, id: String, isTransaction: Bool)
        -> [MessageChannelEvent]
    {
        let touchControlsPrefix = "/streaming/touchcontrols/"
        let isTouchControls = target.hasPrefix(touchControlsPrefix)
        return switch (isTouchControls, isTransaction) {
        case (true, true): [.reply(cancel(id: id))]
        case (true, false): []
        case (false, _): [.reply(unhandled(id: id, target: target))]
        }
    }

    private mutating func unhandled(id: String, target: String) -> Data {
        encode([
            "type": MessageEnvelopeType.unhandled.rawValue,
            "id": id,
            "target": target,
            "cv": nextCorrelationVector(),
        ])
    }

    private func content(of value: Any?) -> [String: Any] {
        switch value {
        case let object as [String: Any]:
            return object
        case let text as String:
            guard let data = text.data(using: .utf8),
                let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            else { return [:] }

            return object
        default:
            return [:]
        }
    }

    private func messageDialog(id: String, content: [String: Any]) -> SystemDialogRequest {
        let buttons = ["CommandLabel1", "CommandLabel2", "CommandLabel3"]
            .compactMap { content[$0] as? String }
            .filter { !$0.isEmpty }
        let kind = SystemDialogRequest.Kind.message(
            title: content["TitleText"] as? String ?? "",
            text: content["ContentText"] as? String ?? "",
            buttons: buttons,
            defaultIndex: integer(content["DefaultIndex"]) ?? 0,
            cancelIndex: integer(content["CancelIndex"])
        )
        return .init(id: id, kind: kind)
    }

    private func integer(_ value: Any?) -> Int? {
        switch value {
        case let number as NSNumber: number.intValue
        case let text as String: Int(text)
        default: nil
        }
    }

    private func keyboardDialog(id: String, content: [String: Any]) -> SystemDialogRequest {
        let kind = SystemDialogRequest.Kind.keyboard(
            title: content["TitleText"] as? String ?? "",
            description: content["DescriptionText"] as? String ?? "",
            defaultText: content["DefaultText"] as? String ?? "",
            maxLength: integer(content["MaxLength"])
        )
        return .init(id: id, kind: kind)
    }

    private mutating func receiveTouchControls(
        _ command: TouchControlsCommand?,
        id: String,
        isTransaction: Bool
    ) -> [MessageChannelEvent] {
        let events = command.map { [MessageChannelEvent.touchControls($0)] } ?? []

        return isTransaction ? [.reply(cancel(id: id))] + events : events
    }
}
