//
//  TouchInputExtensions.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/14.
//

import StarfoldShared
import StreamKit
import TouchController

extension TouchInput {
    var controlLayer: Int {
        let stickLayer = 0
        let buttonLayer = 1

        return switch self {
        case .leftStick, .rightStick: stickLayer
        case .directionPad, .leftTrigger, .rightTrigger, .button: buttonLayer
        }
    }
}
