//
//  GamepadStateReading.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import GameController

extension GamepadState {
    init(reading gamepad: GCExtendedGamepad) {
        let elements: [(GamepadButton, GCControllerButtonInput?)] = [
            (.a, gamepad.buttonA),
            (.b, gamepad.buttonB),
            (.x, gamepad.buttonX),
            (.y, gamepad.buttonY),
            (.leftShoulder, gamepad.leftShoulder),
            (.rightShoulder, gamepad.rightShoulder),
            (.leftThumb, gamepad.leftThumbstickButton),
            (.rightThumb, gamepad.rightThumbstickButton),
            (.menu, gamepad.buttonMenu),
            (.view, gamepad.buttonOptions),
            (.nexus, gamepad.buttonHome),
            (.dpadUp, gamepad.dpad.up),
            (.dpadDown, gamepad.dpad.down),
            (.dpadLeft, gamepad.dpad.left),
            (.dpadRight, gamepad.dpad.right),
        ]
        self.init(
            buttons: GamepadButtons(elements.filter { $0.1?.isPressed == true }.map(\.0)),
            leftStick: SIMD2(
                gamepad.leftThumbstick.xAxis.value,
                gamepad.leftThumbstick.yAxis.value
            ),
            rightStick: SIMD2(
                gamepad.rightThumbstick.xAxis.value,
                gamepad.rightThumbstick.yAxis.value
            ),
            leftTrigger: gamepad.leftTrigger.value,
            rightTrigger: gamepad.rightTrigger.value
        )
    }
}
