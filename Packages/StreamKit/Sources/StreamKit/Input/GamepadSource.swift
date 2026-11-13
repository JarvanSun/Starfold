//
//  GamepadSource.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

enum GamepadSource: Hashable, Comparable, Sendable {
    case slot(UInt8)
    case touch

    var slot: UInt8 {
        switch self {
        case .slot(let slot): slot
        case .touch: playerOneSlot
        }
    }

    private var playerOneSlot: UInt8 { 0 }
}
