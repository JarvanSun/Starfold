//
//  TouchControlsCommandParsing.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation

extension TouchControlsCommand {
    init?(target: MessageTarget, object: [String: Any], text: String?) {
        let payload = TouchControlsPayload(object: object, text: text)

        switch target {
        case .showTouchLayoutV2:
            self = .showLayout(
                payload.layout(id: payload.layoutID ?? ""),
                statePatch: payload.patch
            )
        case .showTouchLayout:
            guard let id = payload.layoutID ?? payload.rawLayoutID else { return nil }

            self = .showLayout(payload.layout(id: id), statePatch: nil)
        case .showTitleDefaultTouchLayout:
            self = .showLayout(.titleDefault, statePatch: nil)
        case .patchTouchLayoutState:
            guard let patch = payload.patch ?? payload.rawPatch else { return nil }

            self = .patchState(patch)
        case .hideTouchLayout:
            self = .hide
        case .systemUIConfiguration, .clientAppInstallIDChanged, .orientationChanged,
            .touchInputEnabledChanged, .clientDeviceCapabilities, .dimensionsChanged,
            .touchBundleMetadataChanged, .showMessageDialog, .showVirtualKeyboard,
            .serverInitiatedDisconnect, .titleInfo:
            return nil
        }
    }
}

private struct TouchControlsPayload {
    let object: [String: Any]
    let text: String?

    var layoutID: String? {
        object["layoutId"] as? String
    }

    var rawLayoutID: String? {
        guard let text else { return nil }

        return switch decodedText {
        case let id as String: id
        case is [Any], is [String: Any]: nil
        default: text
        }
    }

    var patch: Data? {
        switch object["patch"] {
        case let text as String: Data(text.utf8)
        case let document as [Any]: serialized(document)
        case let document as [String: Any]: serialized(document)
        default: nil
        }
    }

    private func serialized(_ document: Any) -> Data? {
        let options: JSONSerialization.WritingOptions = [.sortedKeys, .withoutEscapingSlashes]
        return try? JSONSerialization.data(withJSONObject: document, options: options)
    }

    var rawPatch: Data? {
        switch decodedText {
        case let document as [Any]: serialized(document)
        default: nil
        }
    }

    private var decodedText: Any? {
        guard let text else { return nil }

        return try? JSONSerialization.jsonObject(with: Data(text.utf8), options: .fragmentsAllowed)
    }

    func layout(id: String) -> TouchLayoutReference {
        id.isEmpty ? .standard : .named(id)
    }
}
