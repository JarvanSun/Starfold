//
//  TouchInput.swift
//  StarfoldShared
//
//  Created by Jiawen Sun on 2026/11/13.
//

import StreamKit

public enum TouchInput: Hashable, Sendable {
    case button(GamepadButton)
    case leftTrigger
    case rightTrigger
    case leftStick
    case rightStick
    case directionPad
}
