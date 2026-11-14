//
//  TouchInputPresentation.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import Foundation
import StreamKit

extension TouchInput {
    public var title: LocalizedStringResource {
        switch self {
        case .button(let button): button.title
        case .leftTrigger: .init("touch.control.leftTrigger", bundle: .module)
        case .rightTrigger: .init("touch.control.rightTrigger", bundle: .module)
        case .leftStick: .init("touch.control.leftStick", bundle: .module)
        case .rightStick: .init("touch.control.rightStick", bundle: .module)
        case .directionPad: .init("touch.control.directionPad", bundle: .module)
        }
    }

    var symbol: String {
        switch self {
        case .button(let button): button.symbol
        case .leftTrigger: "lt.rectangle.roundedtop"
        case .rightTrigger: "rt.rectangle.roundedtop"
        case .leftStick: "l.joystick"
        case .rightStick: "r.joystick"
        case .directionPad: "dpad"
        }
    }
}
