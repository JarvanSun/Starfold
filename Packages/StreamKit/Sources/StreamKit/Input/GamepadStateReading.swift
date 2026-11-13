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

    init(reading profile: GCPhysicalInputProfile) {
        let buttonNames: [(GamepadButton, String)] = [
            (.a, GCInputButtonA),
            (.b, GCInputButtonB),
            (.x, GCInputButtonX),
            (.y, GCInputButtonY),
            (.leftShoulder, GCInputLeftShoulder),
            (.rightShoulder, GCInputRightShoulder),
            (.leftThumb, GCInputLeftThumbstickButton),
            (.rightThumb, GCInputRightThumbstickButton),
            (.menu, GCInputButtonMenu),
            (.view, GCInputButtonOptions),
            (.nexus, GCInputButtonHome),
        ]
        let pressed = buttonNames.filter { profile.buttons[$0.1]?.isPressed == true }.map(\.0)
        let dpad = profile.dpads[GCInputDirectionPad]
        let dpadButtons: [(GamepadButton, GCControllerButtonInput?)] = [
            (.dpadUp, dpad?.up),
            (.dpadDown, dpad?.down),
            (.dpadLeft, dpad?.left),
            (.dpadRight, dpad?.right),
        ]
        let pressedDirections = dpadButtons.filter { $0.1?.isPressed == true }.map(\.0)
        let left = profile.dpads[GCInputLeftThumbstick]
        let right = profile.dpads[GCInputRightThumbstick]
        self.init(
            buttons: GamepadButtons(pressed + pressedDirections),
            leftStick: SIMD2(left?.xAxis.value ?? 0, left?.yAxis.value ?? 0),
            rightStick: SIMD2(right?.xAxis.value ?? 0, right?.yAxis.value ?? 0),
            leftTrigger: profile.buttons[GCInputLeftTrigger]?.value ?? 0,
            rightTrigger: profile.buttons[GCInputRightTrigger]?.value ?? 0
        )
    }
}
