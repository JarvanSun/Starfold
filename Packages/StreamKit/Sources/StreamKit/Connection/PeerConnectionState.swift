//
//  PeerConnectionState.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

enum PeerConnectionState: String, Sendable {
    case new
    case connecting
    case connected
    case disconnected
    case failed
    case closed
}
