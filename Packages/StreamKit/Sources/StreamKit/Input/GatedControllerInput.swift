//
//  GatedControllerInput.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/30.
//

import Foundation
import GameController

final class GatedControllerInput: @unchecked Sendable {
    private let inputQueue: DispatchQueue
    private let gamepadRouter: GamepadRouter

    private var policy = GatedGamepadPolicy()
    private var gamepads: [UInt8: GCExtendedGamepad] = [:]
    private var touchProfile: GCPhysicalInputProfile?

    init(inputQueue: DispatchQueue, gamepadRouter: GamepadRouter) {
        self.inputQueue = inputQueue
        self.gamepadRouter = gamepadRouter
    }

    func setPlaying(_ isPlaying: Bool) {
        inputQueue.async {
            self.applyPlaying(isPlaying)
        }
    }

    private func applyPlaying(_ isPlaying: Bool) {
        let isResuming = isPlaying && !policy.isPlaying

        if isResuming {
            refreshHeldControls()
        }

        deliver(policy.setPlaying(isPlaying))

        for gamepad in gamepads.values {
            setSystemGestures(on: gamepad, isPlaying: isPlaying)
        }
    }

    private func refreshHeldControls() {
        for (slot, gamepad) in gamepads {
            deliver(policy.update(.slot(slot), state: GamepadState(reading: gamepad)))
        }

        if let touchProfile {
            deliver(policy.update(.touch, state: GamepadState(reading: touchProfile)))
        }
    }

    private func deliver(_ output: GatedGamepadPolicy.Output) {
        if output.shouldClearPendingInput {
            gamepadRouter.clearPendingInput(from: Array(output.states.keys))
        }

        for (source, state) in output.states.sorted(by: { $0.key < $1.key }) {
            gamepadRouter.update(source, state: state)
        }

        for source in output.removed {
            gamepadRouter.update(source, state: nil)
        }
    }

    private func setSystemGestures(on gamepad: GCExtendedGamepad, isPlaying: Bool) {
        let systemButtons = [gamepad.buttonMenu, gamepad.buttonOptions, gamepad.buttonHome]
            .compactMap { $0 }

        for button in systemButtons {
            button.preferredSystemGestureState = isPlaying ? .disabled : .enabled
        }
    }

    func attach(slot: UInt8, gamepad: GCExtendedGamepad) {
        gamepads[slot] = gamepad

        setSystemGestures(on: gamepad, isPlaying: policy.isPlaying)

        update(slot: slot, state: GamepadState(reading: gamepad))
    }

    func update(slot: UInt8, state: GamepadState?) {
        if state == nil {
            gamepads[slot] = nil
        }

        deliver(policy.update(.slot(slot), state: state))
    }

    func attachTouch(_ profile: GCPhysicalInputProfile) {
        touchProfile = profile

        updateTouch(GamepadState(reading: profile))
    }

    func updateTouch(_ state: GamepadState?) {
        if state == nil {
            touchProfile = nil
        }

        deliver(policy.update(.touch, state: state))
    }
}
