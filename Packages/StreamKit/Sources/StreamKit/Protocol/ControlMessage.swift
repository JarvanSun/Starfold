//
//  ControlMessage.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

import Foundation

enum ControlMessage: Equatable, Sendable {
    case authorizationRequest
    case gamepadChanged(index: Int, isAdded: Bool)
    case keyframeRequest

    var json: Data {
        let object: [String: Any] =
            switch self {
            case .authorizationRequest:
                ["message": "authorizationRequest", "accessKey": accessKey]
            case .gamepadChanged(let index, let isAdded):
                ["message": "gamepadChanged", "gamepadIndex": index, "wasAdded": isAdded]
            case .keyframeRequest:
                ["message": "videoKeyframeRequested", "ifrRequested": false]
            }
        return (try? JSONSerialization.data(withJSONObject: object, options: [.sortedKeys]))
            ?? Data()
    }
}

private extension ControlMessage {
    var accessKey: String { "4BDB3609-C1F1-4195-9B37-FEFF45DA8B8E" }
}
