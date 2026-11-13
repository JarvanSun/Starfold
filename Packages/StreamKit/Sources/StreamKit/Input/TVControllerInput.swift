//
//  TVControllerInput.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/30.
//

import Foundation
import GameController

final class TVControllerInput: @unchecked Sendable {
    private let queue: DispatchQueue
    private let router: GamepadRouter

    private var policy = TVGamepadPolicy()
    private var gamepads: [UInt8: GCExtendedGamepad] = [:]

    init(queue: DispatchQueue, router: GamepadRouter) {
        self.queue = queue
        self.router = router
    }

    func setPlaying(_ isPlaying: Bool) {
        queue.async {
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
            deliver(policy.update(slot: slot, state: GamepadState(reading: gamepad)))
        }
    }

    private func deliver(_ output: TVGamepadPolicy.Output) {
        if output.shouldClearPendingInput {
            router.clearPendingPhysicalInput(slots: Array(output.states.keys))
        }

        for (slot, state) in output.states.sorted(by: { $0.key < $1.key }) {
            router.update(slot: slot, state: state)
        }

        for slot in output.removedSlots {
            router.update(slot: slot, state: nil)
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

        deliver(policy.update(slot: slot, state: state))
    }
}
