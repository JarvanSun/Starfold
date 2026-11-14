//
//  ActiveInputSwitch.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

struct ActiveInputSwitch {
    private(set) var currentInput: ActiveInput = .touch

    private var deliberateInputThreshold: Float { 0.3 }

    @discardableResult
    mutating func record(_ state: GamepadState, from input: ActiveInput) -> ActiveInput? {
        guard isDeliberate(state) else { return nil }

        return use(input)
    }

    @discardableResult
    mutating func use(_ input: ActiveInput) -> ActiveInput? {
        guard currentInput != input else { return nil }

        currentInput = input
        return input
    }

    private func isDeliberate(_ state: GamepadState) -> Bool {
        let threshold = deliberateInputThreshold
        let isPressingButton = !state.buttons.isEmpty
        let isPushingStick = [state.leftStick, state.rightStick]
            .contains { ($0 * $0).sum().squareRoot() >= threshold }
        let isPullingTrigger = [state.leftTrigger, state.rightTrigger]
            .contains { $0 >= threshold }

        return isPressingButton || isPushingStick || isPullingTrigger
    }
}
