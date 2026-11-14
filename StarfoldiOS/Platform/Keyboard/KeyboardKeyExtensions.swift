//
//  KeyboardKeyExtensions.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/13.
//

import GameController
import StreamKit

extension KeyboardKey {
    init?(keyCode: GCKeyCode) {
        switch keyCode {
        case .keyW: self = .w
        case .keyA: self = .a
        case .keyS: self = .s
        case .keyD: self = .d
        case .keyI: self = .i
        case .keyJ: self = .j
        case .keyK: self = .k
        case .keyL: self = .l
        case .upArrow: self = .upArrow
        case .downArrow: self = .downArrow
        case .leftArrow: self = .leftArrow
        case .rightArrow: self = .rightArrow
        case .spacebar: self = .space
        case .escape: self = .escape
        case .deleteOrBackspace: self = .delete
        case .keyF: self = .f
        case .keyR: self = .r
        case .keyQ: self = .q
        case .keyE: self = .e
        case .keyZ: self = .z
        case .keyC: self = .c
        case .returnOrEnter: self = .returnKey
        case .tab: self = .tab
        case .leftShift: self = .leftShift
        case .keyV: self = .v
        default: return nil
        }
    }
}
