//
//  RumbleTarget.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/11/13.
//

enum RumbleTarget: Equatable {
    case controllers(slot: UInt8)
    case device
    case nowhere

    init(effect: VibrationEffect, controllerSlots: Set<UInt8>, isDeviceRumbleEnabled: Bool) {
        let slot = effect.gamepadIndex
        let hasController = controllerSlots.contains(slot)
        let isTouchOnlyPlayerOne = controllerSlots.isEmpty && slot == 0

        switch (hasController, isTouchOnlyPlayerOne && isDeviceRumbleEnabled) {
        case (true, _): self = .controllers(slot: slot)
        case (false, true): self = .device
        case (false, false): self = .nowhere
        }
    }
}
