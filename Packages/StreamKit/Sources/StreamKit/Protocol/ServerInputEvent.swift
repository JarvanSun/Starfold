//
//  ServerInputEvent.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

enum ServerInputEvent: Equatable, Sendable {
    case videoSize(width: Int, height: Int)
    case vibration(VibrationEffect)
}
