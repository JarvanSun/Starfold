//
//  GamepadButtonExtensions.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/14.
//

import StarfoldShared
import StreamKit
import TouchController

extension GamepadButton {
    var controlLabel: TCControlLabel? {
        switch self {
        case .a: .buttonA
        case .b: .buttonB
        case .x: .buttonX
        case .y: .buttonY
        case .leftShoulder: .buttonLeftShoulder
        case .rightShoulder: .buttonRightShoulder
        case .leftThumb: .leftThumbstickButton
        case .rightThumb: .rightThumbstickButton
        case .menu: .buttonMenu
        case .view: .buttonOptions
        case .nexus, .dpadUp, .dpadDown, .dpadLeft, .dpadRight: nil
        }
    }

    var controlShape: TCControlContents.ButtonShape {
        switch self {
        case .leftShoulder, .rightShoulder: .rect
        default: .circle
        }
    }
}
