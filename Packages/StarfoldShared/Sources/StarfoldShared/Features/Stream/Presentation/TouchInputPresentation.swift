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
        case .button(let button): title(of: button)
        case .leftTrigger: .init("touch.control.leftTrigger", bundle: .module)
        case .rightTrigger: .init("touch.control.rightTrigger", bundle: .module)
        case .leftStick: .init("touch.control.leftStick", bundle: .module)
        case .rightStick: .init("touch.control.rightStick", bundle: .module)
        case .directionPad: .init("touch.control.directionPad", bundle: .module)
        }
    }

    private func title(of button: GamepadButton) -> LocalizedStringResource {
        switch button {
        case .a: .init("touch.control.a", bundle: .module)
        case .b: .init("touch.control.b", bundle: .module)
        case .x: .init("touch.control.x", bundle: .module)
        case .y: .init("touch.control.y", bundle: .module)
        case .leftShoulder: .init("touch.control.leftBumper", bundle: .module)
        case .rightShoulder: .init("touch.control.rightBumper", bundle: .module)
        case .leftThumb: .init("touch.control.leftStickPress", bundle: .module)
        case .rightThumb: .init("touch.control.rightStickPress", bundle: .module)
        case .menu: .init("touch.control.menu", bundle: .module)
        case .view: .init("touch.control.view", bundle: .module)
        case .nexus: .init("touch.control.guide", bundle: .module)
        case .dpadUp, .dpadDown, .dpadLeft, .dpadRight:
            .init("touch.control.directionPad", bundle: .module)
        }
    }

    var symbol: String {
        switch self {
        case .button(let button): symbol(of: button)
        case .leftTrigger: "lt.rectangle.roundedtop"
        case .rightTrigger: "rt.rectangle.roundedtop"
        case .leftStick: "l.joystick"
        case .rightStick: "r.joystick"
        case .directionPad: "dpad"
        }
    }

    private func symbol(of button: GamepadButton) -> String {
        switch button {
        case .a: "a.circle"
        case .b: "b.circle"
        case .x: "x.circle"
        case .y: "y.circle"
        case .leftShoulder: "lb.rectangle.roundedbottom"
        case .rightShoulder: "rb.rectangle.roundedbottom"
        case .leftThumb: "l.joystick.press.down"
        case .rightThumb: "r.joystick.press.down"
        case .menu: "line.3.horizontal"
        case .view: "rectangle.on.rectangle"
        case .nexus: "xbox.logo"
        case .dpadUp: "dpad.up.filled"
        case .dpadDown: "dpad.down.filled"
        case .dpadLeft: "dpad.left.filled"
        case .dpadRight: "dpad.right.filled"
        }
    }
}
