//
//  GamepadButton.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum GamepadButton: UInt16, CaseIterable, Sendable {
    case nexus = 0x0002
    case menu = 0x0004
    case view = 0x0008
    case a = 0x0010
    case b = 0x0020
    case x = 0x0040
    case y = 0x0080
    case dpadUp = 0x0100
    case dpadDown = 0x0200
    case dpadLeft = 0x0400
    case dpadRight = 0x0800
    case leftShoulder = 0x1000
    case rightShoulder = 0x2000
    case leftThumb = 0x4000
    case rightThumb = 0x8000

    var physicalityFlag: UInt32 {
        switch self {
        case .dpadUp: 0x1
        case .dpadDown: 0x2
        case .dpadLeft: 0x4
        case .dpadRight: 0x8
        case .menu: 0x10
        case .view: 0x20
        case .leftThumb: 0x40
        case .rightThumb: 0x80
        case .leftShoulder: 0x100
        case .rightShoulder: 0x200
        case .nexus: 0x400
        case .a: 0x1000
        case .b: 0x2000
        case .x: 0x4000
        case .y: 0x8000
        }
    }
}
