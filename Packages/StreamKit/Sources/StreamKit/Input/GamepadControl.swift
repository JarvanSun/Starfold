//
//  GamepadControl.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

public enum GamepadControl: Equatable, Sendable {
    case button(GamepadButton)
    case leftStick(x: Float, y: Float)
    case rightStick(x: Float, y: Float)
    case leftTrigger
    case rightTrigger
}
