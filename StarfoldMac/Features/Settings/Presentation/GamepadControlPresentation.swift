//
//  GamepadControlPresentation.swift
//  Starfold
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import StreamKit

extension GamepadControl {
    var name: LocalizedStringResource {
        switch self {
        case .leftStick(let x, let y):
            .init("settings.controls.mapping.leftStick \(arrow(x: x, y: y))")
        case .rightStick(let x, let y):
            .init("settings.controls.mapping.rightStick \(arrow(x: x, y: y))")
        case .leftTrigger: .init("settings.controls.mapping.leftTrigger")
        case .rightTrigger: .init("settings.controls.mapping.rightTrigger")
        case .button(let button): button.name
        }
    }
}

private extension GamepadControl {
    func arrow(x: Float, y: Float) -> String {
        switch (y > 0, y < 0) {
        case (true, _): "↑"
        case (false, true): "↓"
        case (false, false): x < 0 ? "←" : "→"
        }
    }
}
