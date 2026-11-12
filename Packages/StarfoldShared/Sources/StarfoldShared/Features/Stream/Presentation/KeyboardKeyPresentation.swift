//
//  KeyboardKeyPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StreamKit

extension KeyboardKey {
    public var name: String {
        switch self {
        case .w: "W"
        case .a: "A"
        case .s: "S"
        case .d: "D"
        case .i: "I"
        case .j: "J"
        case .k: "K"
        case .l: "L"
        case .upArrow: "↑"
        case .downArrow: "↓"
        case .leftArrow: "←"
        case .rightArrow: "→"
        case .space: String(localized: "stream.keyboardKey.space", bundle: .module)
        case .escape: String(localized: "stream.keyboardKey.escape", bundle: .module)
        case .delete: String(localized: "stream.keyboardKey.delete", bundle: .module)
        case .f: "F"
        case .r: "R"
        case .q: "Q"
        case .e: "E"
        case .z: "Z"
        case .c: "C"
        case .returnKey: String(localized: "stream.keyboardKey.return", bundle: .module)
        case .tab: String(localized: "stream.keyboardKey.tab", bundle: .module)
        case .leftShift: String(localized: "stream.keyboardKey.leftShift", bundle: .module)
        case .v: "V"
        }
    }
}
