//
//  GamepadButtonPresentation.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StreamKit

extension GamepadButton {
    var name: LocalizedStringResource {
        switch self {
        case .a: .init("settings.controls.mapping.a")
        case .b: .init("settings.controls.mapping.b")
        case .x: .init("settings.controls.mapping.x")
        case .y: .init("settings.controls.mapping.y")
        case .leftShoulder: .init("settings.controls.mapping.leftBumper")
        case .rightShoulder: .init("settings.controls.mapping.rightBumper")
        case .leftThumb: .init("settings.controls.mapping.leftStickPress")
        case .rightThumb: .init("settings.controls.mapping.rightStickPress")
        case .menu: .init("settings.controls.mapping.menu")
        case .view: .init("settings.controls.mapping.view")
        case .dpadUp: .init("settings.controls.mapping.dpadUp")
        case .dpadDown: .init("settings.controls.mapping.dpadDown")
        case .dpadLeft: .init("settings.controls.mapping.dpadLeft")
        case .dpadRight: .init("settings.controls.mapping.dpadRight")
        case .nexus: .init("settings.controls.mapping.xboxButton")
        }
    }
}
