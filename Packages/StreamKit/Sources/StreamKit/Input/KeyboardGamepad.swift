//
//  KeyboardGamepad.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/28.
//

public struct KeyboardGamepad: Equatable, Sendable {
    private(set) var pressedKeys: Set<KeyboardKey> = []

    public var bindings: [KeyBinding] {
        [
            .init(key: .w, control: .leftStick(x: 0, y: 1)),
            .init(key: .a, control: .leftStick(x: -1, y: 0)),
            .init(key: .s, control: .leftStick(x: 0, y: -1)),
            .init(key: .d, control: .leftStick(x: 1, y: 0)),
            .init(key: .i, control: .rightStick(x: 0, y: 1)),
            .init(key: .j, control: .rightStick(x: -1, y: 0)),
            .init(key: .k, control: .rightStick(x: 0, y: -1)),
            .init(key: .l, control: .rightStick(x: 1, y: 0)),
            .init(key: .upArrow, control: .button(.dpadUp)),
            .init(key: .downArrow, control: .button(.dpadDown)),
            .init(key: .leftArrow, control: .button(.dpadLeft)),
            .init(key: .rightArrow, control: .button(.dpadRight)),
            .init(key: .space, control: .button(.a)),
            .init(key: .escape, control: .button(.b)),
            .init(key: .delete, control: .button(.b)),
            .init(key: .f, control: .button(.x)),
            .init(key: .r, control: .button(.y)),
            .init(key: .q, control: .button(.leftShoulder)),
            .init(key: .e, control: .button(.rightShoulder)),
            .init(key: .z, control: .leftTrigger),
            .init(key: .c, control: .rightTrigger),
            .init(key: .returnKey, control: .button(.menu)),
            .init(key: .tab, control: .button(.view)),
            .init(key: .leftShift, control: .button(.leftThumb)),
            .init(key: .v, control: .button(.rightThumb)),
        ]
    }

    public var state: GamepadState {
        var state = GamepadState()
        var left = SIMD2<Float>.zero
        var right = SIMD2<Float>.zero

        for control in pressedKeys.compactMap(control(for:)) {
            switch control {
            case .button(let button): state.buttons.insert(button)
            case .leftStick(let x, let y): left += SIMD2(x, y)
            case .rightStick(let x, let y): right += SIMD2(x, y)
            case .leftTrigger: state.leftTrigger = 1
            case .rightTrigger: state.rightTrigger = 1
            }
        }

        state.leftStick = normalized(left)
        state.rightStick = normalized(right)
        return state
    }

    private func control(for key: KeyboardKey) -> GamepadControl? {
        bindings.first { $0.key == key }?.control
    }

    private func normalized(_ vector: SIMD2<Float>) -> SIMD2<Float> {
        let clamped = SIMD2(max(-1, min(1, vector.x)), max(-1, min(1, vector.y)))
        let length = (clamped * clamped).sum().squareRoot()
        return length > 1 ? clamped / length : clamped
    }

    public init() {}

    @discardableResult
    public mutating func setKey(_ keyCode: UInt16, isDown: Bool) -> Bool {
        guard let key = KeyboardKey(rawValue: keyCode) else { return false }

        switch isDown {
        case true: pressedKeys.insert(key)
        case false: pressedKeys.remove(key)
        }

        return true
    }

    public mutating func releaseAll() {
        pressedKeys.removeAll()
    }
}
