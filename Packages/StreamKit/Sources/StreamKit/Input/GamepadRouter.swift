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

    private let routing: ControllerRouting
    private let lock = NSLock()

    private var destination: Destination?
    private var pads: [UInt8: GamepadState] = [:]
    private var touch: GamepadState?
    private var keyboard = GamepadState()
    private var activeInput = ActiveInputSwitch()

    init(routing: ControllerRouting) {
        self.routing = routing
    }

    public func setDestination(_ destination: Destination?) {
        lock.withLock {
            self.destination = destination
            keyboard = GamepadState()

            guard let destination else { return }

            if pads[0] == nil {
                destination(0, state(for: 0) ?? keyboard)
            }

            for slot in pads.keys.sorted() {
                destination(slot, state(for: slot))
            }
        }
    }

    public func setKeyboard(_ state: GamepadState) {
        lock.withLock {
            keyboard = state

            destination?(0, self.state(for: 0))

            record(state, from: .controller)
        }
    }

    func setActiveInputHandler(_ handler: @escaping @Sendable (ActiveInput) -> Void) {
        lock.withLock { onActiveInputChange = handler }
    }

    func use(_ input: ActiveInput) {
        lock.withLock {
            if let flipped = activeInput.use(input) {
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
            pads[slot] = state

            destination?(slot, self.state(for: slot))

            if let state {
                record(state, from: .controller)
            }
        }
    }

    func updateTouch(_ state: GamepadState?) {
        lock.withLock {
            touch = state

            destination?(0, self.state(for: 0))

            if let state {
                record(state, from: .touch)
            }
        }
    }

    private func state(for slot: UInt8) -> GamepadState? {
        switch (slot, routing) {
        case (0, .direct): playerOne(pads[0] ?? GamepadState())
        case (0, .gated): gatedPlayerOne()
        default: pads[slot]
        }
    }

    private func gatedPlayerOne() -> GamepadState? {
        let hasPlayerOne = pads[0] != nil || touch != nil || keyboard != GamepadState()
        guard hasPlayerOne else { return nil }

        return playerOne(pads[0] ?? GamepadState())
    }

    private func playerOne(_ pad: GamepadState) -> GamepadState {
        let physical = pad.merged(with: keyboard)
        guard let touch else { return physical }

        return physical.merged(withTouch: touch)
    }

    private func record(_ state: GamepadState, from input: ActiveInput) {
        if let flipped = activeInput.record(state, from: input) {
            onActiveInputChange?(flipped)
        }
    }

    func clearPendingInput(from sources: [GamepadSource]) {
        lock.withLock {
            let slots = Set(sources.map(\.slot)).sorted()

            if slots.contains(0) {
                keyboard = GamepadState()
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
        case .slot(let slot): pads[slot] = GamepadState()
        case .touch: touch = GamepadState()
        }
    }
}
