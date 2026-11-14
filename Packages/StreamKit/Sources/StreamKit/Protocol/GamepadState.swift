//
//  GamepadState.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public struct GamepadState: Equatable, Sendable {
    var buttons: GamepadButtons
    var leftStick: SIMD2<Float>
    var rightStick: SIMD2<Float>
    var leftTrigger: Float
    var rightTrigger: Float
    var mergedPhysicality: GamepadPhysicality?

    init(
        buttons: GamepadButtons = [],
        leftStick: SIMD2<Float> = .zero,
        rightStick: SIMD2<Float> = .zero,
        leftTrigger: Float = 0,
        rightTrigger: Float = 0
    ) {
        self.buttons = buttons
        self.leftStick = leftStick
        self.rightStick = rightStick
        self.leftTrigger = leftTrigger
        self.rightTrigger = rightTrigger
    }
}
