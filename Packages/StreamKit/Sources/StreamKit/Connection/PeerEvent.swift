//
//  PeerEvent.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import XboxKit

enum PeerEvent: Sendable {
    case localCandidate(LocalICECandidate)
    case gatheringComplete
    case connectionState(PeerConnectionState)
    case channelOpen(DataChannelLabel)
    case channelMessage(DataChannelLabel, Data)
    case channelClosed(DataChannelLabel)
    case mediaTracksReady
}
