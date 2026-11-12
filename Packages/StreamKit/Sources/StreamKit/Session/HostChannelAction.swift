//
//  HostChannelAction.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

enum HostChannelAction: Equatable, Sendable {
    case send(Data, on: DataChannelLabel)
    case update(StreamUpdate)
    case announceGamepad
    case end(StreamEndReason)
    case trace(String)
}
