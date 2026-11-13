//
//  TouchInput.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StreamKit
import XboxKit

public enum TouchInput: Hashable, Sendable {
    case button(GamepadButton)
    case leftTrigger
    case rightTrigger
    case leftStick
    case rightStick
    case directionPad

    init?(kind: TouchControlKind) {
        switch kind {
        case .button(let button): self.init(actions: button.actions)
        case .joystick(let joystick): self.init(axes: joystick.axes)
        case .directionalPad: self = .directionPad
        case .throttle, .touchpad, .arcadeButtons, .blank, .unsupported: return nil
        }
    }

    private init?(actions: [TouchAction]) {
        guard actions.count == 1, case .output(.gamepad(let output)) = actions[0] else {
            return nil
        }

        self.init(output: output)
    }

    private init?(axes: [TouchAxisMapping]) {
        guard axes.count == 1, axes[0].input == .xy else { return nil }

        switch axes[0].output {
        case .gamepad(.leftJoystick): self = .leftStick
        case .gamepad(.rightJoystick): self = .rightStick
        default: return nil
        }
    }

    private init?(output: TouchGamepadOutput) {
        switch output {
        case .gamepadA: self = .button(.a)
        case .gamepadB: self = .button(.b)
        case .gamepadX: self = .button(.x)
        case .gamepadY: self = .button(.y)
        case .view: self = .button(.view)
        case .menu: self = .button(.menu)
        case .leftBumper: self = .button(.leftShoulder)
        case .rightBumper: self = .button(.rightShoulder)
        case .leftThumb: self = .button(.leftThumb)
        case .rightThumb: self = .button(.rightThumb)
        case .leftTrigger: self = .leftTrigger
        case .rightTrigger: self = .rightTrigger
        default: return nil
        }
    }
}
