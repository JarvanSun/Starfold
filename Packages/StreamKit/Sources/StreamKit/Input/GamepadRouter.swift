//
//  GamepadRouter.swift
//  StreamKit
//
//  Created by Jiawen Sun on 2026/09/30.
//

import Foundation

public final class GamepadRouter: @unchecked Sendable {
    public typealias Destination = @Sendable (_ slot: UInt8, _ state: GamepadState?) -> Void

    private var onActiveInputChange: (@Sendable (ActiveInput) -> Void)?

    private let controllerRouting: ControllerRouting
    private let lock = NSLock()

    private var destination: Destination?
    private var gamepadStates: [UInt8: GamepadState] = [:]
    private var touchGamepadState: GamepadState?
    private var keyboardGamepadState = GamepadState()
    private var activeInputSwitch = ActiveInputSwitch()

    init(controllerRouting: ControllerRouting) {
        self.controllerRouting = controllerRouting
    }

    public func setDestination(_ destination: Destination?) {
        lock.withLock {
            self.destination = destination
            keyboardGamepadState = GamepadState()

            guard let destination else { return }

            if gamepadStates[0] == nil {
                destination(0, state(for: 0) ?? keyboardGamepadState)
            }

            for slot in gamepadStates.keys.sorted() {
                destination(slot, state(for: slot))
            }
        }
    }

    private func state(for slot: UInt8) -> GamepadState? {
        switch (slot, controllerRouting) {
        case (0, .direct): playerOne(gamepadStates[0] ?? GamepadState())
        case (0, .gated): gatedPlayerOne()
        default: gamepadStates[slot]
        }
    }

    private func playerOne(_ pad: GamepadState) -> GamepadState {
        let physical = pad.merged(with: keyboardGamepadState)
        guard let touchGamepadState else { return physical }

        return physical.merged(withTouch: touchGamepadState)
    }

    private func gatedPlayerOne() -> GamepadState? {
        let hasPlayerOne =
            gamepadStates[0] != nil || touchGamepadState != nil
            || keyboardGamepadState != GamepadState()
        guard hasPlayerOne else { return nil }

        return playerOne(gamepadStates[0] ?? GamepadState())
    }

    public func setKeyboard(_ state: GamepadState) {
        lock.withLock {
            keyboardGamepadState = state

            destination?(0, self.state(for: 0))

            record(state, from: .controller)
        }
    }

    private func record(_ state: GamepadState, from input: ActiveInput) {
        if let flipped = activeInputSwitch.record(state, from: input) {
            onActiveInputChange?(flipped)
        }
    }

    func setActiveInputHandler(_ handler: @escaping @Sendable (ActiveInput) -> Void) {
        lock.withLock { onActiveInputChange = handler }
    }

    func use(_ input: ActiveInput) {
        lock.withLock {
            if let flipped = activeInputSwitch.use(input) {
                onActiveInputChange?(flipped)
            }
        }
    }

    func update(_ source: GamepadSource, state: GamepadState?) {
        switch source {
        case .slot(let slot): update(slot: slot, state: state)
        case .touch: updateTouch(state)
        }
    }

    func update(slot: UInt8, state: GamepadState?) {
        lock.withLock {
            gamepadStates[slot] = state

            destination?(slot, self.state(for: slot))

            if let state {
                record(state, from: .controller)
            }
        }
    }

    func updateTouch(_ state: GamepadState?) {
        lock.withLock {
            touchGamepadState = state

            destination?(0, self.state(for: 0))

            if let state {
                record(state, from: .touch)
            }
        }
    }

    func clearPendingInput(from sources: [GamepadSource]) {
        lock.withLock {
            let slots = Set(sources.map(\.slot)).sorted()

            if slots.contains(0) {
                keyboardGamepadState = GamepadState()
            }

            for slot in slots {
                destination?(slot, nil)
            }

            for source in sources {
                reset(source)
            }
        }
    }

    private func reset(_ source: GamepadSource) {
        switch source {
        case .slot(let slot): gamepadStates[slot] = GamepadState()
        case .touch: touchGamepadState = GamepadState()
        }
    }
}
