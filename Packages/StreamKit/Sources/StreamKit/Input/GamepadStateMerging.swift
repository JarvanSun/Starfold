//
//  GamepadStateMerging.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

extension GamepadState {
    func merged(with other: GamepadState) -> GamepadState {
        .init(
            buttons: buttons.union(other.buttons),
            leftStick: stronger(leftStick, other.leftStick),
            rightStick: stronger(rightStick, other.rightStick),
            leftTrigger: max(leftTrigger, other.leftTrigger),
            rightTrigger: max(rightTrigger, other.rightTrigger)
        )
    }
}

private extension GamepadState {
    func stronger(_ first: SIMD2<Float>, _ second: SIMD2<Float>) -> SIMD2<Float> {
        (first * first).sum() >= (second * second).sum() ? first : second
    }
}
