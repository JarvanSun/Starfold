//
//  ControllerInputDestination.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/12.
//

import GameController

enum ControllerInputDestination: Sendable {
    case router(GamepadRouter)
    case television(TVControllerInput)

    func prepare(_ gamepad: GCExtendedGamepad) {
        switch self {
        case .router:
            gamepad.buttonHome?.preferredSystemGestureState = .disabled
            gamepad.buttonMenu.preferredSystemGestureState = .disabled
            gamepad.buttonOptions?.preferredSystemGestureState = .disabled
        case .television:
            break
        }
    }

    func attach(slot: UInt8, gamepad: GCExtendedGamepad) {
        switch self {
        case .router(let router): router.update(slot: slot, state: GamepadState(reading: gamepad))
        case .television(let input): input.attach(slot: slot, gamepad: gamepad)
        }
    }

    func update(slot: UInt8, state: GamepadState?) {
        switch self {
        case .router(let router): router.update(slot: slot, state: state)
        case .television(let input): input.update(slot: slot, state: state)
        }
    }
}
