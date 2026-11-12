//
//  DataChannelLabel.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

enum DataChannelLabel: String, CaseIterable, Sendable {
    case input
    case chat
    case control
    case message

    var protocolName: String {
        switch self {
        case .input: "1.0"
        case .chat: "chatV1"
        case .control: "controlV1"
        case .message: "messageV1"
        }
    }
}
